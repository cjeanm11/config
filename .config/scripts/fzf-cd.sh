#!/bin/bash


################# fcd function with options and behavior ####################

declare -a directory_stack
declare -a bookmarks
shell_name=$(basename $SHELL)
setopt KSH_ARRAYS 2>/dev/null

# TAG --help: output brief documentation for how to invoke the program
show_help() {
    echo "Usage: fcd [OPTIONS] [PATH]"
    echo "Navigate directories with fuzzy search and manage bookmarks."
    echo ""
    echo "Options:"
    echo "  -l, -ls, -list       List all bookmarked directories."
    echo "  -g, -go, -goto <NUM> Navigate to a bookmarked directory by number."
    echo "  -a, -add <PATH>      Add the current directory or the specified PATH to bookmarks."
    echo "                       If no argument is provided, the current directory is used."
    echo "  -r, -rm, -remove <PATH>   Remove a specific bookmarked directory by PATH."
    echo "  -r, -rm, -remove --all    Remove all bookmarks."
    echo "  -push, -pu           Push the current directory onto the directory stack."
    echo "  -pop, -pp            Pop and navigate to the top directory on the directory stack."
    echo "  --help               Show this help message."
    echo ""
    echo "If no options or PATH is provided, fcd initiates fuzzy search to navigate interactively."
}

# OPTION -pu: Push the current directory onto the stack
pushd() {
    local absolute_path="$(realpath "$PWD")"
    directory_stack+=("$absolute_path")
    cd "$1"
}

# OPTION -pp: Pop the top directory from the stack and navigate to it
popd() {
    if [[ ${#directory_stack[@]} -gt 0 ]]; then
        local target_dir="${directory_stack[-1]}"
        directory_stack=("${directory_stack[@]:0:(${#directory_stack[@]}-1)}")
        cd "$target_dir"
    else
        echo "Directory stack is empty."
    fi
}

# fzf-cd: Main function
fcd() {
    # Parse command line options
    if [[ "$1" == "--help" || "$1" == "--h" ]]; then
      show_help
    elif [[ "$1" == "-l" || "$1" == "-ls" || "$1" == "-list" ]]; then # list
        list_bookmarks
    elif [[ "$1" == "-g" || "$1" == "-go" || "$1" == "-goto" ]]; then
        goto_bookmark "$2"
    elif [[ "$1" == "-add" || "$1" == "-a" ]]; then
        add_bookmark "$2"
    elif [[ "$1" == "-remove" || "$1" == "-r" || "$1" == "-rm" ]]; then

        if [[ "$2" == "--all" ]]; then
            remove_all_bookmarks
        elif [[ -z "$2" ]]; then
            echo "Usage: fcd remove <directory-path>"
            if [[ ! ${#bookmarks[@]} -eq 0 ]]; then
                list_bookmarks
            fi
        else
            remove_bookmark "$2"
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
        if [[ -n "$1" ]]; then
            cd "$1"
        else
            local target_dir="$(find ~/. -type d -print | fzf)"
            if [[ -n "$target_dir" ]]; then
                pushd "$target_dir"
            else
                echo "Invalid directory or command. Use '-ls' to list bookmarks, 'add' or '-a' to add a bookmark, 'remove' or '-r' to remove a bookmark."
                return 1
            fi
        fi
    fi
}


# OPTION -a: Add a directory to bookmarks
add_bookmark() {
    local target_dir="$1"

    if [[ -z "$target_dir" ]]; then
        target_dir="$(pwd)"
    fi

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

    bm_to_add="fcd -a \"${absolute_path}\" 1>/dev/null"
    if ! grep "$bm_to_add" ~/.${shell_name}rc; then
        {
            chmod +w ~/.${shell_name}rc
            echo "$bm_to_add" >> ~/.${shell_name}rc
            chmod -w ~/.${shell_name}rc
        }
    fi

}

# OPTION -l: List bookmarks
list_bookmarks() {
    local bookmark_count=${#bookmarks[@]}
    if [[ $bookmark_count -eq 0 ]]; then
        echo "No bookmarks found."
        return
    fi

    echo "Bookmarked Directories:"
    for ((i = 0; i < $bookmark_count; i++)); do
        local bookmarked_dir="${bookmarks[i]}"

        if [[ -d "$bookmarked_dir" ]]; then
            echo "  [$((i))] - $bookmarked_dir"
        else
            echo "  [$((i))] - $bookmarked_dir (Invalid path)"
        fi
    done
}


# OPTION -r: Remove a directory from bookmarks
remove_bookmark() {
    local target_dir="$1"
    local absolute_path=$(realpath "$target_dir" 2>/dev/null)
    local new_bookmarks=()

    for bm in "${bookmarks[@]}"; do
        if [[ "$bm" != "$absolute_path" ]]; then
            new_bookmarks+=("$bm")
        fi
    done

    if [[ ${#new_bookmarks[@]} -eq ${#bookmarks[@]} ]]; then
        echo "Directory $absolute_path is not a bookmark."
    else
        bookmarks=("${new_bookmarks[@]}")
        bm_to_remove="fcd -a \"$absolute_path\""
        if grep "$bm_to_remove" ~/.${shell_name}rc 1>/dev/null; then
            {
                chmod +w ~/.${shell_name}rc
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "\#${bm_to_remove}#d" ~/.${shell_name}rc 1>/dev/null
                else
                    sed -i "\#${bm_to_remove}#d" ~/.${shell_name}rc 1>/dev/null
                fi
                chmod -w ~/.${shell_name}rc
                echo "Removed $absolute_path from bookmarks."
            }
        fi
        #
    fi
}

# OPTION -g: Go to bookmark path based on input (bookmark numbers)
goto_bookmark() {
    local choice="$1"

    if [[ -z "$choice" ]]; then
        list_bookmarks
        echo "Enter the number of the bookmarked path you want to navigate to: "
        read -r choice
    fi


    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid number."
        return 1
    fi


    local index=$((choice))

    local selected_path="${bookmarks[index]}"
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

# OPTION -r TAG --all: Remove bookmarks
remove_all_bookmarks() {
    local option="$1"
    bookmarks=()

    if [[ -f ~/.${shell_name}rc ]]; then
        {
            chmod +w ~/.${shell_name}rc
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "\#fcd -a#d" ~/.${shell_name}rc 1>/dev/null
            else
                sed -i "\#fcd -a#d" ~/.${shell_name}rc 1>/dev/null
            fi
            chmod -w ~/.${shell_name}rc
        }
    fi

    echo "All bookmarks removed."
}
