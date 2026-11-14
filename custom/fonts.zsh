#!/usr/bin/env zsh

link_fonts() {
    local if_changed=0
    if [[ "${1:-}" == "--if-changed" ]]; then
        if_changed=1
    fi

    if ! command -v fc-cache >/dev/null 2>&1; then
        echo "[!] fontconfig is not installed. Please install fontconfig (e.g. sudo apt install fontconfig) and run link_fonts."
        return 1
    fi

    local fonts_src="$HOME/.dotfiles/custom/fonts"
    local fonts_dst="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"

    if [[ ! -d "$fonts_src" ]]; then
        echo "[!] Fonts source directory not found: $fonts_src"
        return 1
    fi

    local -a font_files
    font_files=("$fonts_src"/**/*(.N))
    if (( ${#font_files} == 0 )); then
        if (( ! if_changed )); then
            echo "[!] No font files found in $fonts_src"
        fi
        return 0
    fi

    mkdir -p "$fonts_dst" || return 1

    local has_zstat=0
    if zmodload -F zsh/stat b:zstat 2>/dev/null; then
        has_zstat=1
    fi

    local backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/fonts-backup-$(date +%Y%m%d-%H%M%S)"
    local backup_used=0
    local linked_count=0
    local conflict_count=0
    local src rel dst dst_dir link_target
    local -A st

    for src in "${font_files[@]}"; do
        rel="${src#$fonts_src/}"
        dst="$fonts_dst/$rel"
        dst_dir="${dst:h}"

        if [[ -L "$dst" ]]; then
            if (( has_zstat )) && zstat -L -H st "$dst" 2>/dev/null; then
                link_target="${st[link]}"
            else
                link_target="$(readlink "$dst")"
            fi

            if [[ "$link_target" == "$src" ]]; then
                continue
            fi

            echo "[!] Preserving existing symlink: $dst -> $link_target"
            (( conflict_count++ ))
            continue
        fi

        if [[ -d "$dst" ]]; then
            echo "[!] Preserving conflicting directory: $dst"
            (( conflict_count++ ))
            continue
        fi

        if [[ -f "$dst" ]]; then
            if cmp -s "$src" "$dst"; then
                if ! mkdir -p "$backup_root/${rel:h}"; then
                    echo "[x] Failed to create backup directory for $dst"
                    return 1
                fi
                mv "$dst" "$backup_root/$rel" || return 1
                backup_used=1
                ln -s "$src" "$dst" || return 1
                (( linked_count++ ))
            else
                echo "[!] Preserving conflicting font file: $dst"
                (( conflict_count++ ))
            fi
            continue
        fi

        mkdir -p "$dst_dir" || return 1
        ln -s "$src" "$dst" || return 1
        (( linked_count++ ))
    done

    if (( backup_used )); then
        echo "[] Backed up identical existing font files to $backup_root"
    fi

    if (( linked_count > 0 )); then
        echo "[] Linked $linked_count font file(s) into $fonts_dst"
    fi

    if (( ! if_changed || linked_count > 0 )); then
        fc-cache -fv
    fi

    return 0
}

link_fonts --if-changed
