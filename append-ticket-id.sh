#!/bin/bash

# Function to get the current branch name
get_current_branch() {
    git branch --show-current
}

# Function to get the commit message
get_commit_message() {
    cat "$1"
}

# Function to write the commit message
write_commit_message() {
    echo "$2" > "$1"
}

# Function to extract the ticket ID from the branch name
extract_ticket_id() {
    echo "$1" | grep -o -E '(acq|da|data|dec|devop|ds|it|mlops|nerds|qa|sec|spe|ss)-[0-9]+' | tr '[:lower:]' '[:upper:]'
}

# Main script
main() {
    if [ $# -eq 0 ]; then
        echo "commit message file not found, are you sure you set the stage for this hook to be in stages: [ commit-msg ]?"
        exit 1
    fi

    commit_message_file="$1"
    branch_name=$(get_current_branch)
    ticket_id=$(extract_ticket_id "$branch_name")

    if [ -z "$ticket_id" ]; then
        echo "Warning: No ticket ID found in branch name '$branch_name'"
        exit 0
    fi

    commit_message=$(get_commit_message "$commit_message_file")
    first_line=$(echo "$commit_message" | head -n 1)

    # Check if the first line already contains the ticket_id
    if ! echo "$first_line" | grep -qi "$ticket_id"; then
        first_line="$first_line [$ticket_id]"
        commit_message="$first_line$(echo "$commit_message" | tail -n +2)"
        write_commit_message "$commit_message_file" "$commit_message"
    fi
}

main "$@"
