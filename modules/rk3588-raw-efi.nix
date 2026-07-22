{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  # A raw, EFI-bootable disk image for RK3588 UEFI systems.
  #
  # This reproduces nixos-generators' `raw-efi` format directly on top of
  # nixpkgs' `lib/make-disk-image.nix`, so no external `nixos-generators`
  # input is required. Build via `config.system.build.raw`.

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  boot = {
    growPartition = true;
    loader.timeout = lib.mkDefault 0;
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  system.build.raw = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "efi";
    diskSize = "auto";
    format = "raw";
  };
}
