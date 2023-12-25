if command -v zsh >/dev/null 2>&1; then
    if [ -t 1 ]; then
        exec zsh;
        chsh -s $(which zsh);
    fi
fi
