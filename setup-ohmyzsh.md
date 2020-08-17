## Setup oh-my-zsh

Set zsh as the default shell

`chsh -s $(which zsh)`

On macOS start with the command below from a terminal and answer "y" if prompted to change your default shell to zsh

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions;
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting;
```

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
)
```

I would also recommend adding a "right prompt" to the .zshrc file at the very bottom

```
## right prompt
RPROMPT="%F{green}%n@%m%f"
```