## Setup oh-my-zsh

Set zsh as the default shell. On macOS start with the command below from a terminal and answer "y" if prompted to change your default shell to zsh. The same thing should work in an Ubuntu shell in WSL2

`chsh -s $(which zsh)`

## Install Meslo Nerd Font 

Follow instructions at the link below:

<a href="https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k" target="_blank">Install Meslo Nerd Font</a>

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

Then set `ZSH_THEME="powerlevel10k/powerlevel10k"` in ~/.zshrc and type `source ~/.zshrc` in the terminal to start the configuration wizard. Follow the prompts and select the setup you prefer. You can always update and change the configuration by using `p10k configure`. 

<!--
Use the below if you want this to work with the terminal from the docker menu as well

export ZSH="$HOME/.oh-my-zsh"
-->

For macOS, <a href="https://releases.hyper.is/download/mac" target="_blank">Hyper</a> is a very nice terminal. To use fonts and icons in the Hyper terminal with ZSH, change the terminal settings as follows: 

> Hyper: Open Hyper → Edit → Preferences and change the value of fontFamily under module.exports.config to "MesloLGS NF".

To use fonts and icons in the Windows Terminal change the terminal settings as follows: 

> Windows Terminal: Open Settings (Ctrl+,), search for fontFace and set value to MesloLGS NF for every profile.

If you want to have access to the same icons in the terminal in VSCode change the settings as follows:

> Visual Studio Code: Open File → Preferences → Settings, enter terminal.integrated.fontFamily in the search box and set the value to "MesloLGS NF".
