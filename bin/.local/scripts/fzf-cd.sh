#!/bin/bash

declare -a directory_stack
declare -a bookmarks

# Push the current directory onto the stack
pushd() {
    local absolute_path="$(realpath "$PWD")"
    directory_stack+=("$absolute_path")
    cd "$1"
}

# Pop the top directory from the stack and navigate to it
popd() {
    if [ ${#directory_stack[@]} -gt 0 ]; then
        local target_dir="${directory_stack[-1]}"
        directory_stack=("${directory_stack[@]:0:(${#directory_stack[@]}-1)}")
        cd "$target_dir"
    else
        echo "Directory stack is empty."
    fi
}

fcd() {
    if [[ "$1" == "-l" || "$1" == "-ls" || "$1" == "-list" ]]; then # list
        list_bookmarks
    elif [[ "$1" == "-add" || "$1" == "-a" ]]; then # add to bookmarks
        if [ -z "$2" ]; then
            echo "Usage: fcd add <directory>"
        else
            add_to_bookmarks "$2"
        fi
    elif [[ "$1" == "-remove" || "$1" == "-r" || "$1" == "-rm" ]]; then # rm from bookmarks
        if [ -z "$2" ]; then
            echo "Usage: fcd remove <directory>"
            if [ ! ${#bookmarks[@]} -eq 0 ]; then
                list_bookmarks
            fi
        else
            remove_from_bookmarks "$2"
        fi
    elif [[ "$1" == "-push" || "$1" == "-pu" ]]; then # add to dir. stack
        if pushd "$PWD"; then
            echo "Pushed current directory onto the stack."
        else
            echo "Failed to push current directory onto the stack."
        fi
    elif [[ "$1" == "-pop" || "$1" == "-pp" ]]; then # rm from dir. stack
        if popd >/dev/null 2>&1; then
            echo "Popped and navigated to the top directory on the stack."
        else
            echo "Directory stack is empty or an error occurred while popping."
        fi
    else
        # fuzzy find and change dir.
        local target_dir="$(find ~/. -type d -print | fzf)"
        if [ -n "$target_dir" ]; then
            pushd "$target_dir"
        else
            echo "Invalid directory or command. Use 'ls' to list bookmarks, 'add' or 'a' to add a bookmark, 'remove' or 'r' to remove a bookmark."
            return 1
        fi
    fi
}


# Add a directory to bookmarks
add_to_bookmarks() {
    local target_dir="$1"
    local absolute_path="$(realpath "$target_dir")"
    bookmarks+=("$absolute_path")
    echo "Added $absolute_path to bookmarks."
}

# List bookmarks
list_bookmarks() {
    local bookmark_count=${#bookmarks[@]}
    if [ $bookmark_count -eq 0 ]; then
        echo "No bookmarks found."
    else
        echo "Bookmarked Directories:"
        for dir in "${bookmarks[@]}"; do
            echo "  $dir"
        done
    fi
}


# Remove a directory from bookmarks
remove_from_bookmarks() {
    local target_dir="$1"
    local absolute_path="$(realpath "$target_dir")"
    local new_bookmarks=()

    for bookmark in "${bookmarks[@]}"; do
        if [[ "$bookmark" != "$absolute_path" ]]; then
            new_bookmarks+=("$bookmark")
        fi
    done

    if [ ${#new_bookmarks[@]} -eq ${#bookmarks[@]} ]; then
        echo "Directory $absolute_path is not in bookmarks."
    else
        bookmarks=("${new_bookmarks[@]}")
        echo "Removed $absolute_path from bookmarks."
    fi
}
