{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  security = {
    pam.services.login.kwallet.enable = true;
    pam.services.sddm.kwallet.enable = true;
    rtkit.enable = true;
    polkit.enable = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [ pkgs.apparmor-profiles ];
    };

    # Prevent replacing the running kernel without a reboot
    protectKernelImage = true;
    acme.acceptTerms = true;
  };
}
