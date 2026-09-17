# pop-os: manual system setup

Root-level bits stow can't manage. Companion to `pop-os.conf`.

## Lid: don't suspend while on external power

The UGREEN CM558 dock powers the laptop over USB-C, so "on AC" covers "docked"
without depending on which monitors are connected. Default logind is
`HandleLidSwitch=suspend` with `ExternalPower` inheriting it.

```sh
sudo mkdir -p /etc/systemd/logind.conf.d && printf '[Login]\nHandleLidSwitchExternalPower=ignore\n' | sudo tee /etc/systemd/logind.conf.d/lid.conf && sudo systemctl reload systemd-logind
```

Verify:

```sh
busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager HandleLidSwitchExternalPower
# s "ignore"
```

## DisplayLink (UGREEN CM558 video out)

apt's `evdi-dkms` (1.14.2) is too old for kernel 6.17; use the Synaptics
installer (6.3.0-48 ships evdi 1.14.14-5). Installs `/opt/displaylink`,
`displaylink-driver.service` and `/etc/modprobe.d/evdi.conf`.

```sh
# https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu
sudo ./displaylink-driver-6.3.0-48.run --accept
```

Hotplug needs the patched aquamarine from nixos-config (`pkgs/overlay.nix`):
evdi has no render node, and stock aquamarine drops such monitors on connect.
