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
    elif [[ "$1" == "-g" || "$1" == "-go" || "$1" == "-goto" ]]; then # goto to a bookmarked path
        goto_bookmark
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
    local absolute_path=$(realpath "$target_dir" 2>/dev/null) # Resolve the absolute path

    if [[ -z "$absolute_path" || ! -d "$absolute_path" ]]; then
        echo "Error: Invalid directory: $target_dir"
        return
    fi

    if [[ " ${bookmarks[@]} " =~ " $absolute_path " ]]; then
        echo "Error: Directory is already in bookmarks: $absolute_path"
        return
    fi

    bookmarks+=("$absolute_path")
    echo "Added $absolute_path to bookmarks."
}

# List bookmarks
list_bookmarks() {
    local bookmark_count=${#bookmarks[@]}
    if [ $bookmark_count -eq 0 ]; then
        echo "No bookmarks found."
        return
    fi

    echo "Bookmarked Directories:"
    for ((i = 0; i < $bookmark_count; i++)); do
        local bookmarked_dir="${bookmarks[i+1]}"
        
        if [[ -d "$bookmarked_dir" ]]; then
            echo "  [$((i + 1))] - $bookmarked_dir"
        else
            echo "  [$((i + 1))] - $bookmarked_dir (Invalid path)"
        fi
    done
}


# Remove a directory from bookmarks
remove_from_bookmarks() {
    local target_dir="$1"
    local absolute_path=$(realpath "$target_dir" 2>/dev/null)
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

# Go to bookmark path based on input (bookmark numbers)
goto_bookmark() {
    list_bookmarks  # list bookmark numbers

    echo "Enter the number of the bookmarked path you want to navigate to: "
    read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number."
        return 1
    fi

    local index=$((choice - 1))

    # Valid the index 
    if [[ $index -lt 0 || $index -ge ${#bookmarks[@]} ]]; then
        echo "Invalid choice. Please select a valid bookmark number."
        return 1
    fi

    local selected_path="${bookmarks[index+1]}"
    selected_path=$(eval echo "$selected_path")

    if [[ ! -d "$selected_path" ]]; then
        echo "Error: The selected bookmark is not a valid directory."
        return 1
    fi

    cd "$selected_path" || {
        echo "Error: Could not navigate to $selected_path"
        return 1
    }
    echo "Navigated to $(pwd)"
}

