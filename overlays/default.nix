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
}
