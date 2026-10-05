_: {
  networking.hostName = "vps";
  services.openssh.ports = [ 8888 ];
  system.activationScripts.retireSshPortMigration.text = ''
    for service in sshd forgejo firewall; do
      rm -f "/etc/systemd/system.control/$service.service.d/nix-config-ssh-port.conf"
    done
  '';
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      7000
    ];
    extraCommands = ''
      iptables -I nixos-fw 1 -s 10.89.0.0/16 -j nixos-fw-accept
    '';
  };
}
