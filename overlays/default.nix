final: prev: {
  slack-mcp-server = prev.buildGoModule {
    pname = "slack-mcp-server";
    version = "1.3.0";
    src = prev.fetchFromGitHub {
      owner = "korotovsky";
      repo = "slack-mcp-server";
      tag = "v1.3.0";
      hash = "sha256-I4f6yKV0BXtaxnqi/XNID+Pwl2mWjSqxIHhb07U7sc4=";
    };
    vendorHash = "sha256-+uQRODO9oL8mGKBmdghTxE6R9Fz+3GJFVTi17306gT8=";
    subPackages = [ "cmd/slack-mcp-server" ];
    meta = {
      description = "MCP server for Slack workspaces";
      homepage = "https://github.com/korotovsky/slack-mcp-server";
      license = prev.lib.licenses.mit;
      mainProgram = "slack-mcp-server";
    };
  };

  azure-devops-mcp = prev.buildNpmPackage {
    pname = "azure-devops-mcp";
    version = "2.8.0";
    src = prev.fetchFromGitHub {
      owner = "microsoft";
      repo = "azure-devops-mcp";
      rev = "v2.8.0";
      hash = "sha256-Ds/Kcr4xb9f7i9hPiunSTfn8rwgorqzpWvT1jIoSIYk=";
    };
    npmDepsHash = "sha256-tqAHcEl3mjHY5cI5rhSJa0SSvyvUHrwVxyN2CFdNMK4=";
    postInstall = ''
      mv $out/bin/mcp-server-azuredevops $out/bin/azure-devops-mcp
    '';
    meta = {
      description = "Azure DevOps MCP Server (complement to FundGuard proxy)";
      homepage = "https://github.com/microsoft/azure-devops-mcp";
      license = prev.lib.licenses.mit;
      mainProgram = "azure-devops-mcp";
    };
  };

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
