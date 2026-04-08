{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zed-editor
    nil
    nixd
    nixfmt-tree
  ];
}
