{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    eza          # ls replacement
    bat          # cat replacement with syntax highlighting
    fd           # find replacement
    ripgrep      # grep replacement (rg)
    lf           # terminal file manager
    yq           # YAML/JSON processor
    tealdeer     # tldr client (quick command examples)
    trash-cli    # safe rm — moves to trash instead of permanent delete
    gum          # pretty terminal prompts and UI components
    chafa        # image rendering in the terminal
    w3m          # terminal web browser
    television   # fuzzy finder / picker with previews
    fastfetch    # system info display
  ];

  # Aliases extend the fish config declared in shell.nix — HM merges these automatically
  programs.fish.shellAliases = {
    ls   = "eza --icons";
    ll   = "eza -la --icons";
    lt   = "eza --tree --icons";
    cat  = "bat";
    find = "fd";
    grep = "rg";
    rm   = "trash";
  };
}
