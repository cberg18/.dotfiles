#!/bin/bash

export VAULT_ADDR="https://vault.hcmsgroup.com"
docker_ssl_path="secrets/certs/docker/ssl/"
docker_cert_dir="$HOME/.dockercert"

if [ -d "$docker_cert_dir" ]; then
    echo "Cert dir '$docker_cert_dir' exists, removing it for clean start"
    rm -rf $docker_cert_dir
fi

echo "Creating cert dir '$docker_cert_dir'"
mkdir -p $docker_cert_dir

echo "Authing to vault"
vault login $(cat /etc/vault/agent-token) > /dev/null

vault list -format=json $docker_ssl_path | jq '.[]' | while read -r row; do
    row=$(echo $row | tr -d '"')
    echo "Retrieving certs for $row"
    certs=$(vault read -format=json $docker_ssl_path$row | jq .data.data)
    echo "Creating host '$row' cert dir"
    mkdir -p "$docker_cert_dir/$row"
    echo $certs | \
        jq .key | \
        sed -e 's/"//g' -e 's/-----BEGIN PRIVATE KEY-----/\n&\n/g' -e 's/-----END PRIVATE KEY-----/\n&\n/g' | sed '/^$/d' \
        > "$docker_cert_dir/$row/key.pem"

    echo $certs | \
        jq .ca | \
        sed -e 's/"//g' -e 's/-----BEGIN CERTIFICATE-----/\n&\n/g' -e 's/-----END CERTIFICATE-----/\n&\n/g' | sed '/^$/d' \
        > "$docker_cert_dir/$row/ca.pem"

    echo $certs | \
        jq .cert | \
        sed -e 's/"//g' -e 's/-----BEGIN CERTIFICATE-----/\n&\n/g' -e 's/-----END CERTIFICATE-----/\n&\n/g' | sed '/^$/d' \
        > "$docker_cert_dir/$row/cert.pem"
    #echo $certs | jq .key | tr -d '"' > "$docker_cert_dir/$row/key.pem"
    #echo $certs | jq .ca | tr -d '"' > "$docker_cert_dir/$row/ca.pem"
    #echo $certs | jq .cert | tr -d '"' > "$docker_cert_dir/$row/cert.pem"

    echo "Creating context for docker host $row"
    docker context create \
        --docker "host=tcp://$row.hcmsgroup.com:2376,ca=$docker_cert_dir/$row/ca.pem,cert=$docker_cert_dir/$row/cert.pem,key=$docker_cert_dir/$row/key.pem" \
        --description="$row docker engine" \
        $row
done
