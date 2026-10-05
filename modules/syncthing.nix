{ ... }: {
  services.syncthing = {
    enable = true;
    user = "nmurray";
    dataDir = "/home/nmurray";
    configDir = "/home/nmurray/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
  };
}
