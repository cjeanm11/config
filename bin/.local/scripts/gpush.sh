#!/bin/bash

gpush() {
    git reset
    git remote -v
    git pull --rebase
    git init
    git add -A
    git commit -m "-"
    git branch -M main
    git push origin main --force
}
