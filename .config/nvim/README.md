# Neovim Configuration

Requires neovim > 0.8.
<https://github.com/neovim/neovim/releases/latest>

```
sudo dpkg -i nvim-linux64.deb
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 10
sudo update-alternatives --config vi
```

## Terminal Configuration
Patch font use for terminal: 
<https://www.nerdfonts.com/font-downloads> 
or use termux styling

```
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d ~/.local/share/fonts
fc-cache -fv
```

## Development Environment
Install node.js installed for the LSP.


### node.js
```
curl https://get.volta.sh | bash
volta install node
```

### python
```
apt install python3 python3-venv python3-neovim

```
