{ vimUtils, vimPlugins, ... }:

vimUtils.buildVimPlugin {
  pname = "remote-text-nvim";
  version = "0.1";
  src = ./.;
  meta.homepage = "https://github.com/Remote-Text/remote-text-neovim-client";
  dependencies = with vimPlugins; [ plenary-nvim ];
}
