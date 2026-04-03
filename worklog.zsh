function new_worklog_day() {
    # Default to your worklog path, but allow overriding via argument
    local log_file="${1:-$HOME/.dotfiles/worklog.txt}"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: Worklog file not found at $log_file"
        return 1
    fi

    local current_date=$(date "+%m.%d.%Y")
    local new_header="########################## $current_date ##########################"

    # Check if a header for today already exists at the top to prevent duplicates
    if head -n 1 "$log_file" | grep -q "$current_date"; then
        echo "A log entry for today ($current_date) already exists."
        return 0
    fi

    local unfinished_entries=$(awk '
        /^##########################/ {
            header_count++
            if (header_count == 2) exit
            next
        }
        header_count == 1 {
            if (NF == 0) next

            line = $0

            # 1. Skip if the original task from yesterday is already marked finished
            if (line ~ /^\[finished\]/) next

            # 2. Check for a new status appended at the end (e.g., "; holding" or "; [holding]")
            if (match(line, /;[ \t]*\[?[A-Za-z0-9 _-]+\]?[ \t]*$/)) {
                suffix_start = RSTART
                new_status = substr(line, suffix_start)

                # Clean up the parsed status text (strip semicolon, brackets, and spaces)
                sub(/^;[ \t]*\[?/, "", new_status)
                sub(/\]?[ \t]*$/, "", new_status)

                # Strip the suffix from the task description
                line = substr(line, 1, suffix_start - 1)
                sub(/[ \t]+$/, "", line)

                # Replace the existing status bracket or prepend the new one
                if (line ~ /^\[[^\]]+\]/) {
                    sub(/^\[[^\]]+\][ \t]*/, "[" new_status "] ", line)
                } else {
                    line = "[" new_status "] " line
                }
            }

            print line
        }
    ' "$log_file")

    local temp_file=$(mktemp)

    # 1. Write the new day's header
    echo "$new_header\n" > "$temp_file"

    # 2. Write the entries if there are any
    if [[ -n "$unfinished_entries" ]]; then
        echo "$unfinished_entries\n" >> "$temp_file"
    fi

    # 3. Append the rest of the original log file
    cat "$log_file" >> "$temp_file"

    # 4. Replace the old log with the newly built log
    mv "$temp_file" "$log_file"

    echo "Successfully rolled over unfinished tasks to $current_date in $log_file"
}


function normalize_worklog_status() {
    # Default to your worklog path, but allow overriding via argument
    local log_file="${1:-$HOME/.dotfiles/worklog.txt}"

    if [[ ! -f "$log_file" ]]; then
        echo "Error: Worklog file not found at $log_file"
        return 1
    fi

    local temp_file=$(mktemp)

    awk '
        # 1. Print empty lines exactly as they are
        /^[ \t]*$/ { print; next }

        # 2. Print date headers exactly as they are
        /^[ \t]*#/ { print; next }

        # 3. Print tasks that already start with a bracketed status
        /^[ \t]*\[/ { print; next }

        # 4. For any other line, strip leading spaces and prepend [not started]
        {
            sub(/^[ \t]+/, "")
            print "[not started] " $0
        }
    ' "$log_file" > "$temp_file"

    # Replace the old log with the normalized log
    mv "$temp_file" "$log_file"

    echo "Successfully normalized statuses in $log_file"
}
