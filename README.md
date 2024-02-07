# remote-text.nvim

This is a Neovim plugin for [RemoteText](https://github.com/Remote-Text).

## Prerequisites

- A running version of [the server](https://github.com/Remote-Text/remote-text-server). You need an unencrypted, pre-user version of the server (currently, this is the only one that exists, so if you don't know what this means, the latest verison is probably fine).
- `plenary.nvim`

## Installation

### Nix with flakes and home-manager

This repository is a Nix flake that provides the plugin as an output. Here's an example module that you can use in your home-manager configuration, provided that your flake `inputs` are available:

```nix
{ config, inputs, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraLuaConfig = ''
      vim.g.RemoteText = {
        api_url = "https://my.remote-text-instance.com/api"
      }

      vim.api.nvim_create_user_command('RemoteText', require("remote-text").run, {})
    '';
    plugins = with pkgs.vimPlugins; [
      inputs.remote-text-neovim.packages.${pkgs.system}.default
    ];
  };
}
```

### (Neo)Vim Package Managers

I'll be honest, I've only used one of these, and it's been too long, so I don't remember the instructions. I think what you need to know is:
- this plugin depends on `plenary.nvim`
- you don't need to call `setup()` (lazy.nvim users, this function is called by default, you'll want to disable it)
- you need to set `vim.g.RemoteText` (aka `g:RemoteText`) to a table containing the API URL of your server instance
- the plugin doesn't provide any commands or keybindings. See the example above for how to create a command

## Usage

Call `require("remote-text").run()`. If you've set up a command as in the example above, you can do this with `:RemoteText`.

This will prompt you to select a file to edit, which will be downloaded and opened in a new buffer. `:w`riting the buffer will save a new version to RemoteText.
