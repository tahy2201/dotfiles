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
