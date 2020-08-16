## Setup oh-my-zsh

Set zsh as the default shell. On macOS start with the command below from a terminal and answer "y" if prompted to change your default shell to zsh

`chsh -s $(which zsh)`

Run the commands below to install some useful plugins.

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions;
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting;
git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k;
git clone git://github.com/wting/autojump.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump;
sudo ln -s /usr/bin/python3 /usr/bin/python;
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump;
./install.py
cd -
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

I would also recommend adding a "right prompt" to the .zshrc file at the very bottom

```
## right prompt
RPROMPT="%F{green}%n@%m%f"
```