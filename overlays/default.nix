final: prev: {
  agentic-nvim = prev.vimUtils.buildVimPlugin {
    pname = "agentic-nvim";
    version = "0-unstable";
    src = prev.fetchFromGitHub {
      owner = "carlos-algms";
      repo = "agentic.nvim";
      rev = "main";
      sha256 = "sha256-eRQjzn60q6oiw6gyXEt9t44TeJQLm0yNX75sjt3jQgs=";
    };
    doCheck = false;
  };

  zellij-vim = prev.vimUtils.buildVimPlugin {
    pname = "zellij-vim";
    version = "0-unstable";
    src = prev.fetchFromGitHub {
      owner = "fresh2dev";
      repo = "zellij.vim";
      rev = "main";
      sha256 = "sha256-R4BYJNYwg4IpP06UcMN7ZbxbpiF711scuOZKBCDYwcs=";
    };
    doCheck = false;
  };

  claudecode-nvim = prev.vimUtils.buildVimPlugin {
    pname = "claudecode-nvim";
    version = "0-unstable";
    src = prev.fetchFromGitHub {
      owner = "coder";
      repo = "claudecode.nvim";
      rev = "main";
      sha256 = "sha256-oMBPSRQFDmJ9Lq+ZP8vFMHaocm4sPX3D/orVMNwVXuM=";
    };
    doCheck = false;
  };
}
