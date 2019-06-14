#!/bin/bash

mkdir -p ~/.rsm-msba/share/code-server/User
cp /opt/code-server/settings.json ~/.rsm-msba/share/code-server/User/settings.json

# extension available in code-server market place
extensions="vscode-icons-team.vscode-icons coenraads.bracket-pair-colorizer"

for ext in $extensions; do
  echo "Installing extension: $ext"
  code-server --extensions-dir  $CODE_EXTENSIONS_DIR --install-extension "$ext" > /dev/null 2>&1
done

for file in /opt/code-server/extensions/*.vsix; do
  f=$(basename "$file" .vsix)
  echo "Installing extension: $f"
  code-server --extensions-dir  $CODE_EXTENSIONS_DIR --install-extension "$file" > /dev/null 2>&1
done
