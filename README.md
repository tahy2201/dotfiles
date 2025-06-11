# zsh
zshrc

## vscode

**extensions**

以下で生成.
```sh
code --list-extensions > extensions
```

以下で一括installできる.
```
cat extensions | while read line
do
 code --install-extension $line
done
```

## dotfiles

```sh
mkdir ~/.config/wezterm
ln -s ~/work/tahy/dotfiles/dotfiles/wezterm.lua wezterm.lua
```

## wezterm

```sh
# 直接installの場合
sudo ln -sf /Applications/WezTerm.app/Contents/MacOS/wezterm-gui /opt/homebrew/bin/wezterm-gui
sudo ln -sf /Applications/WezTerm.app/Contents/MacOS/wezterm /opt/homebrew/bin/wezterm
```

