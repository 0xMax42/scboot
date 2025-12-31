# scboot

`scboot` is a small set of scripts and configuration to support Secure Boot signing workflows on Debian/Ubuntu systems.

It provides:

* A `scboot` CLI entrypoint.
* Helpers to re-sign GRUB and Linux kernel images using a local signing key.
* APT hooks that automatically run the signing helpers after package operations.
* DKMS framework configuration synchronization for automatic kernel module signing.
* A systemd path/service pair that updates the DKMS configuration when `scboot` configuration changes.

## Requirements

Runtime dependencies (see Debian control file):

* `bash`, `coreutils`, `grep`, `sed`, `mawk` (or `gawk`), `findutils`
* `sbsigntool` (provides `sbsign`, `sbverify`, `sbattach`)
* `grub-common`
* `shim-scboot`

`scboot` is intended to run with root privileges because it writes to `/boot`, the EFI system partition, and system configuration paths.

## Installation

### Install from Debian package

Install the built package (example):

```bash
sudo apt install ./scboot_*.deb
```

### Install from source

This repository uses a simple Makefile that templates files into `build/` and supports `DESTDIR` installs.

```bash
make
sudo make install
```

To uninstall:

```bash
sudo make uninstall
```

## Installed files

Main locations:

* CLI: `/usr/sbin/scboot` (symlink)
* Library/scripts: `/usr/lib/scboot/`
* Helper symlinks:

  * `/usr/libexec/scboot-resign-grub`
  * `/usr/libexec/scboot-resign-kernel`
* Configuration: `/etc/scboot/scboot.conf`
* APT hooks:

  * `/etc/apt/apt.conf.d/99-apt-secureboot-grub-resign`
  * `/etc/apt/apt.conf.d/99-apt-secureboot-kernel-resign`
* DKMS framework configuration: `/etc/dkms/framework.conf.d/99-scboot.conf`
* systemd units:

  * `/usr/lib/systemd/system/scboot-reload.service`
  * `/usr/lib/systemd/system/scboot-reload.path`

## Configuration

The main configuration file is:

* `/etc/scboot/scboot.conf`

It is a simple `key=value` file. Comments starting with `#` or `;` are ignored.

Default configuration template:

```ini
# ==== Key configuration ====
KEY=/etc/scboot/keys/DB.key
CRT=/etc/scboot/keys/DB.crt
DER=/etc/scboot/keys/DB.der

# ==== GRUB configuration ====
GRUB_SRC=/boot/efi/EFI/ubuntu/grubx64.efi
GRUB_DST=/boot/efi/EFI/scboot/grubx64.efi
GRUB_HASH=/var/lib/scboot/grub.sha256

# ==== Kernel configuration ====
KERNEL_DST_DIR=/boot
KERNEL_HASH_DIR=/var/lib/scboot/kernels

# ==== DKMS configuration file ====
DKMS_CONFIG_FILE=/etc/dkms/framework.conf.d/99-scboot.conf
```

You must provide the signing key and certificate files referenced by `KEY`, `CRT`, and `DER`.

Recommended file permissions (example):

```bash
sudo chown -R root:root /etc/scboot
sudo chmod 0700 /etc/scboot/keys
sudo chmod 0600 /etc/scboot/keys/*
```

## DKMS integration

`scboot` maintains a DKMS framework config file at:

* `/etc/dkms/framework.conf.d/99-scboot.conf`

The script `/usr/lib/scboot/sync-dkms.sh` writes the configured key/certificate paths into that file. The systemd unit `scboot-reload.path` watches `/etc/scboot/scboot.conf` and triggers `scboot-reload.service` to run `sync-dkms.sh` whenever the configuration changes.

## Automatic signing (APT hooks)

Two APT hooks are installed under `/etc/apt/apt.conf.d/`. They run after dpkg operations:

* `scboot-resign-grub` re-signs the configured GRUB EFI binary when it changes.
* `scboot-resign-kernel` re-signs kernel images under `/boot`.

The scripts maintain hash files under `/var/lib/scboot/` to avoid unnecessary re-signing.

## CLI usage

Show help:

```bash
scboot --help
```

Show version:

```bash
scboot --version
```

Manual signing:

```bash
sudo scboot sign all
sudo scboot sign grub
sudo scboot sign kernel
```

Force re-signing even if artifacts appear unchanged:

```bash
sudo scboot --force sign all
```

## Logging and troubleshooting

Scripts log primarily to the system journal with tag `scboot`.

Follow logs:

```bash
sudo journalctl -t scboot -f
```

Common checks:

* Verify `KEY`, `CRT`, and `DER` paths exist and are readable by root.
* Verify `GRUB_SRC` exists and `GRUB_DST` is on the EFI system partition.
* Verify `/boot` contains `vmlinuz-*` images.
* Use `--force` to re-sign when debugging.

## Development notes

* `make build` templates files into `build/` using `sed` replacements.
* CI builds a Debian package using `debcrafter` and uploads via `tea-pkg`.

## License

MIT License. See `LICENSE`.
