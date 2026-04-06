{ config, pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting ""
    '';
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";
    terminal = "tmux-256color";
    tmuxinator.enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };
}
