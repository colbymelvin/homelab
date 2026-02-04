## Description

A repository containing the monitoring stack for my personal, Raspberry Pi based homelab.

The monitoring stack is run via [Podman](https://podman.io/) using systemd units via [rootless Podman Quadlets](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path).

See also [documentation regarding running Podman in a rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md).

## Requirements

1. A Linux distribution with systemd, git, and internet access.
2. Podman v4.4.0+ is required because Quadlet support shipped with Podman v4.4.0.

### A note about Debian

> [!NOTE]
> It can be difficult to get Podman v4.4.0+ on Debian (stable). You have a few options here: switch to Debian testing or unstable, build Podman from source, install and manage Podman via Homebrew, or install and manage Podman via Nix.
> Personally, I have chosen the latter in favor of Nix's ease of use and broad package support. To install Podman v4.4.0+ via Nix on Debian, run:

```bash
$ sudo apt-get install passt uidmap
$ sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
$ nix-env --install --attr nixpkgs.podman
```

I also had to do the following:

```bash
sudo cp ~/.nix-profile/lib/systemd/system-generators/podman-system-generator /usr/lib/systemd/system-generators/
sudo cp ~/.nix-profile/lib/systemd/user-generators/podman-user-generator /usr/lib/systemd/user-generators/
```

## Suggestions

In the case of a Raspberry Pi, it is optional but preferred to serve the root filesystem on something other than the SD card. The intention of this repo is to stand up a robust monitoring stack with reasonably long data retention, i.e. lots of filesystem operations that are prone to corrupting an SD card.

## Instructions

- Clone this repo
- `./install.sh` to move .container, .network, and .volume files into the expected location, and start the systemd services.

## Goals

- Lightweight with minimal bloat / configuration
- Ease of use
- Maintainability
- Set it and forget it (services automatically run on system boot / restart)
