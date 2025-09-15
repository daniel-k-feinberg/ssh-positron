#!/bin/bash

echo "Installing extensions for Positron..."

extensions=(
# Infra
    "donjayamanne.githistory"
    "GitHub.vscode-github-actions"
    "vsls-contrib.codetour"
# Conveniences
    "mechatroner.rainbow-csv"
    "redhat.vscode-yaml"
    "oderwat.indent-rainbow"
    "BriteSnow.vscode-toggle-quotes"
# Lang Support
    "brunnerh.insert-unicode"
    "yzhang.markdown-all-in-one"
    "TakumiI.markdowntable"
# Themes
    "GitHub.github-vscode-theme"
    "PKief.material-icon-theme"
    "daylerees.rainglow"
# Fun
    "tonybaloney.vscode-pets"
# Unused
    #"ltex-plus.vscode-ltex-plus"
    #"james-yu.latex-workshop"
)

# Loop through the array and install each extension
for extension in "${extensions[@]}"; do
    echo "Installing $extension..."
    positron --install-extension "$extension"
done

echo "Positron extension installation complete."
