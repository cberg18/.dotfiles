#!/bin/bash

if nslookup $OP_HOST > /dev/null 2>&1; then
    source <(age -d -i $HOME/.ssh/id_ed25519 $HOME/.dotfiles/custom/pg_pass.zsh.age) $OP_HOST
    echo "[] creds sourced"
else
    echo "[x] Network or DB not reachable."
    return
fi

encrypt_secrets() {
    # Configuration
    KEY_PUB="$HOME/.ssh/id_ed25519.pub"
    KEY_PRIV="$HOME/.ssh/id_ed25519"
    INPUT_FILE="$HOME/.dotfiles/custom/pg_pass.zsh"
    OUTPUT_FILE="$HOME/.dotfiles/custom/pg_pass.zsh.age"

    # Check for age utility
    if ! command -v age &> /dev/null; then
        echo "Error: 'age' utility is not installed."
        echo "You can install it using: sudo apt install age"
        return
    fi

    # Check for public key
    if [[ ! -f "$KEY_PUB" ]]; then
        echo "Error: Public key not found at $KEY_PUB"
        return
    fi

    # Check for input file
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Input file $INPUT_FILE not found."
        return
    fi

    echo "Encrypting $INPUT_FILE using $KEY_PUB..."

    # Encrypt the file
    # age supports SSH public keys directly as recipients
    age -r "$(cat "$KEY_PUB")" -o "$OUTPUT_FILE" "$INPUT_FILE"

    if [[ $? -eq 0 ]]; then
        echo "Success! File encrypted to: $OUTPUT_FILE"
        echo ""
        echo "To decrypt this file, use the following command:"
        echo " age -d -i $KEY_PRIV $OUTPUT_FILE > $INPUT_FILE"
        echo ""
        echo "NOTE: Remember to secure or remove the original $INPUT_FILE if it contains sensitive data."
    else
        echo "Error: Encryption failed."
        return
    fi
}

decrypt_secrets() {
    # Configuration
    KEY_PRIV="$HOME/.ssh/id_ed25519"
    INPUT_FILE="$HOME/.dotfiles/custom/pg_pass.zsh.age"
    OUTPUT_FILE="$HOME/.dotfiles/custom/pg_pass.zsh"

    # Check for age utility
    if ! command -v age &> /dev/null; then
        echo "Error: 'age' utility is not installed."
        echo "You can install it using: sudo apt install age"
        return 1
    fi

    # Check for private key
    if [[ ! -f "$KEY_PRIV" ]]; then
        echo "Error: Private key not found at $KEY_PRIV"
        return 1
    fi

    # Check for input file
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Encrypted file $INPUT_FILE not found."
        return 1
    fi

    echo "Decrypting $INPUT_FILE using $KEY_PRIV..."

    # Decrypt the file
    age -d -i "$KEY_PRIV" -o "$OUTPUT_FILE" "$INPUT_FILE"

    if [[ $? -eq 0 ]]; then
        echo "Success! File decrypted to: $OUTPUT_FILE"
        chmod +x "$OUTPUT_FILE"
    else
        echo "Error: Decryption failed. Make sure your SSH key is correct and not passphrase protected (or provide it when prompted)."
        return 1
    fi
}
