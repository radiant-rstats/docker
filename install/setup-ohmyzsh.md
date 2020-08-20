## Setup oh-my-zsh

Set `ZSH` as the default shell. On macOS start with the command below from a terminal and answer "y" if prompted to change your default shell to zsh. The same command work on Linux or in an Ubuntu shell in WSL2 (Windows).

`chsh -s $(which zsh)`

## Install Meslo Nerd Font 

Follow the linked instructions to install the <a href="https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k" target="_blank">Meslo Nerd Font</a>. Then run the commands below to install some useful plugins and the `powerlevel10k` theme:

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions;
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting;
git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k;
git clone git://github.com/wting/autojump.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump;
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autojump;
./install.py;
cd -;
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k;
```

Now use VSCode, or another text editor, to make a few changes to the `.zshrc` file. For example, if you have VSCode installed you can use it from a macOS or Windows Terminal by typing: 

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

Then replace `ZSH_THEME="robbyrussell"` with `ZSH_THEME="powerlevel10k/powerlevel10k"` in `~/.zshrc`. Save the changes and type `source ~/.zshrc` in the terminal to start the configuration wizard. Follow the prompts and select the setup you prefer. You can always update and change the configuration by running `p10k configure` in a terminal. 

<!--
Use the below if you want this to work with the terminal from the docker menu as well

export ZSH="$HOME/.oh-my-zsh"
-->

For macOS, <a href="https://releases.hyper.is/download/mac" target="_blank">Hyper</a> is a very nice terminal. To use fonts and icons in the Hyper terminal with ZSH, change the terminal settings as follows: 

> Hyper: Open Hyper → Edit → Preferences and change the value of fontFamily under module.exports.config to "MesloLGS NF".

To use fonts and icons in the Standard macOS terminal with ZSH, change the terminal settings as follows: 

> Apple Terminal: Open Terminal → Preferences → Profiles → Text, click Change under Font and select MesloLGS NF family.

To use fonts and icons in the Windows Terminal change the terminal settings as follows: 

> Windows Terminal: Open Settings (Ctrl+,), search for fontFace and set value to "MesloLGS NF" for every profile.

To use fonts and icons in the Windows Console Host (i.e., CMD) change the terminal settings as follows: 

> Windows Console Host: Click the icon in the top left corner, then Properties → Font and set Font to "MesloLGS NF".

If you want to have access to the same icons in the terminal in VSCode change the settings as follows:

> Visual Studio Code: Open File → Preferences → Settings, enter terminal.integrated.fontFamily in the search box and set the value to "MesloLGS NF".
