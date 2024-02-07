{ buildVimPlugin, buildNeovimPlugin, ... }:

buildNeovimPlugin {
  pname = "rmeote-text-nvim";
  version = "0.1";
  src = ./.;
  meta.homepage = "https://github.com/Remote-Text/remote-text-neovim-client";
}
