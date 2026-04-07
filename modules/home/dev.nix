{ config, pkgs, inputs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # LazyVim config — placed at ~/.config/nvim by home-manager
  # Plugins are downloaded automatically on first launch by lazy.nvim
  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    userName = "luke";
    userEmail = "you@example.com";  # Update with your real email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  # Claude Code global settings
  home.file.".claude/settings.json".text = builtins.toJSON {
    skipDangerousModePermissionPrompt = true;
  };

  # Gemini CLI global settings
  home.file.".gemini/settings.json".text = builtins.toJSON {
    mcpServers = {
      nixos = {
        command = "${inputs.mcp-nixos.packages.${pkgs.system}.default}/bin/mcp-nixos";
      };
    };
  };

  home.packages = with pkgs; [
    glab        # GitLab CLI
    shellcheck  # Shell script linter
    nodejs      # Node.js runtime
    python3     # Python 3
    uv          # Fast Python package/project manager
    claude-code # Agentic coding tool (Anthropic)
    gemini-cli  # Google Gemini AI in the terminal
    inputs.mcp-nixos.packages.${pkgs.system}.default  # MCP server for NixOS
  ];
}
