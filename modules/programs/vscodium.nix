{ pkgs, user, ... }:

{
  home-manager.users.${user} = {
    programs = {
      vscode = {
        enable = true;
        package = pkgs.vscodium.fhsWithPackages (ps: with ps; [ python3Minimal libusb1 ]);
      };
    };
  };
}
