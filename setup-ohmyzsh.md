## Setup oh-my-zsh

Set zsh as the default shell. On macOS start with the command below from a terminal and answer "y" if prompted to change your default shell to zsh. The same thing should work in an Ubuntu shell in WSL2

`chsh -s $(which zsh)`

## Install Meslo Nerd Font 

Follow instructions at the link below:

https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

Run the commands below to install some useful plugins.

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions;
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting;
git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k;
git clone git://github.com/wting/autojump.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump;
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump;
./install.py
cd -
```

Install the `powerlevel10k` theme:

```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Use VSCode, or another text editor, to make a few changes to the `.zshrc` file

```
code ~/.zshrc
```

Replace the `plugins` section in the .zshrc file with the code below

```
plugins=(
  git
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  autojump
  k
)
```

Then set `ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc and type ` source ~/.zshrc` in the terminal to start the configuration wizard. 
