#!/bin/bash

HOMEDIR="/home/${NB_USER}"

function show_links() {
  echo "Vim tutorials:"
  echo "- https://www.openvim.com/"
  echo "- http://www.vimgenius.com/"
  echo "- http://yannesposito.com/Scratch/en/blog/Learn-Vim-Progressively/"
  echo ""
  echo "Spacevim documentation:"
  echo "- https://spacevim.org/documentation/"
  echo "- https://spacevim.org/layers/lang/python/"
  echo "- https://spacevim.org/layers/lang/r/"
  echo "- https://raw.githubusercontent.com/jalvesaq/Nvim-R/master/doc/Nvim-R.txt"
  echo "- https://spacevim.org/layers/git/"
  echo ""
  echo "Quick tips:"
  echo "- Use :q to close vim"
  echo "- Use h j k and l to navitate left, down, up, and right"
  echo "- Press esc to enter normal mode and i to enter insert mode"
  echo ""
}

if [ ! -d "${HOMEDIR}/.SpaceVim.d" ]; then

  echo ""
  echo "-----------------------------------------------------"
  echo "Starting SPACEVIM setup"
  echo "-----------------------------------------------------"
  echo ""
  show_links

  curl -fLo "$HOMEDIR/.SpaceVim.d/init.toml" --create-dirs \
    https://raw.githubusercontent.com/radiant-rstats/docker/master/rsm-msba/spacevim/init.toml
  curl -sLf https://spacevim.org/install.sh | bash

  ## needed so you can use space vim both in- and outside the
  ## docker container
  cd
  rm .vim
  ln -s .SpaceVim .vim
  cd -
  clear
  echo ""
  echo "-----------------------------------------------------"
  echo "Starting SPACEVIM"
  echo "-----------------------------------------------------"
  echo ""
  vim
else
  echo ""
  echo "-----------------------------------------------------"
  echo "Now that spacevim has been installed you should use"
  echo "'vim' to start the spacevim application"
  echo "'svim' will now only show links to learn more about"
  echo "vim and spacevim"
  echo "-----------------------------------------------------"
  echo ""

  show_links
fi
