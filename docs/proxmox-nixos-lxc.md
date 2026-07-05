# NixOS LXC on Proxmox

## Required LXC Configuration

After every `pct create` for a NixOS container, add these lines to the container config:

```bash
cat >> /etc/pve/lxc/<VMID>.conf << 'CONF'
lxc.apparmor.profile: unconfined
lxc.cap.drop:
lxc.cgroup2.devices.allow: a
lxc.mount.auto: proc:rw sys:rw cgroup:rw
CONF
```

## Create NixOS LXC Template

```bash
# On titan
cd ~/nixos-config
nix build .#nixosConfigurations.lxc-base.config.system.build.tarball

# Copy to Proxmox
scp result/tarball/nixos-image-lxc-proxmox-*.tar.xz \
  root@10.10.40.5:/var/lib/vz/template/cache/nixos-lxc-base.tar.xz
```

## Deploy NixOS LXC

```bash
pct create <VMID> /var/lib/vz/template/cache/nixos-lxc-base.tar.xz \
  --hostname <name> \
  --storage ssd-lxc \
  --rootfs ssd-lxc:4 \
  --memory 256 \
  --cores 1 \
  --net0 name=eth0,bridge=vmbr0,ip=10.10.40.<IP>/24,gw=10.10.40.1 \
  --onboot 1

# Add required NixOS config
cat >> /etc/pve/lxc/<VMID>.conf << 'CONF'
lxc.apparmor.profile: unconfined
lxc.cap.drop:
lxc.cgroup2.devices.allow: a
lxc.mount.auto: proc:rw sys:rw cgroup:rw
CONF

pct start <VMID>
```

## LXC Numbering Scheme

| Range | Purpose |
|-------|---------|
| 1xx | Infrastructure (Nebula, Caddy, Vaultwarden) |
| 2xx | Data/Storage (Nextcloud) |
| 3xx | Media/Personal (Immich) |
| 4xx | Monitoring (InfluxDB, Grafana) |
| 5xx | IoT/Home Automation (MQTT) |
| 9xx | VMs |

## Deployed LXCs

| VMID | Hostname | IP | Purpose |
|------|----------|----|---------|
| 101 | caddy | 10.10.40.101 | Reverse proxy + SSL |
| 500 | mqtt | 10.10.40.50 | MQTT broker |
