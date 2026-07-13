final: prev: {
  agentic-nvim = prev.vimUtils.buildVimPlugin {
    name = "agentic-nvim";
    src = prev.fetchFromGitHub {
      owner = "carlos-algms";
      repo = "agentic.nvim";
      rev = "main";
      sha256 = "sha256-eRQjzn60q6oiw6gyXEt9t44TeJQLm0yNX75sjt3jQgs=";
    };
    doCheck = false;
  };

  claudecode-nvim = prev.vimUtils.buildVimPlugin {
    name = "claudecode-nvim";
    src = prev.fetchFromGitHub {
      owner = "coder";
      repo = "claudecode.nvim";
      rev = "main";
      sha256 = "sha256-oMBPSRQFDmJ9Lq+ZP8vFMHaocm4sPX3D/orVMNwVXuM=";
    };
    doCheck = false;
  };
}
