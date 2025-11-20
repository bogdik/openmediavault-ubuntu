# openmediavault ubuntu installer

Unofficial **direct installer** for [openmediavault 8](https://www.openmediavault.org/) on Ubuntu.

The goal of this project is simple:  
clone the repo, run `./install.sh`, get a working openmediavault web UI on Ubuntu without manual patching, Salt fixes, or PHP-PAM gymnastics.

> ⚠️ This project is **not** affiliated with or supported by the official openmediavault project.  
> Use at your own risk and only on systems where you are comfortable experimenting.

---

## What this repository provides

- A ready-to-use **installer**:  
  `install.sh` prepares the system, installs required packages and configures openmediavault on top of Ubuntu.

- Bundled openmediavault 8 packages:
  - `openmediavault_8.0-7_all.deb` and core plugins (apt, bcache, diskstats, ftp, hosts, k8s, lvm2, md, nut, onedrive, owntone, photoprism, podman, s3, shairport, sharerootfs, snmp, tftp, usbbackup, wetty, etc.)
  - openmediavault installer and keyring `.udeb` packages

- Prebuilt **php-pam** and **openmediavault-salt** packages for:
  - `amd64`
  - `arm64`
  - `armhf`

- A vendored `jc-1.25.6.tar.gz` used to make system info / statistics in the OMV web UI work correctly on Ubuntu.

---

## Requirements

- Ubuntu (systemd-based; Server/Desktop)
- Root access (`sudo` or direct root)
- Internet access for pulling dependencies from Ubuntu and Debian repositories

It is strongly recommended to start from a **clean** Ubuntu installation.

---

## Tested

- On Ubuntu 22.04.5 LTS (**Luckfox Pico Max**)
  - `FTP`
  - `SFTP`
  - `TFTP`
  - `SMB`
  - `NFS`
  - `Rsync`

Package openmediavault-filebrowser_8.0-2_all.deb need docker (don't requment install this)

It is strongly recommended to start from a **clean** Ubuntu installation.

---

## Quick start

```bash
git clone https://github.com/bogdik/openmediavault-ubuntu.git
cd openmediavault-ubuntu

chmod +x install.sh
sudo ./install.sh

```
After install plugin maybe need launch 
```
chmod +x ./fix_plugin&&./fix_plugin
```

## P.S.

This project was originally created **just for fun** - a personal experiment to see whether the tiny **Luckfox Pico Max** could run a full OpenMediaVault setup on Ubuntu.

Surprisingly, it works.  
The repository contains all necessary adjustments, patches and workarounds to make OMV 8 boot and operate correctly on such minimal hardware.

A prepared Luckfox Pico Max firmware image (with unnecessary components removed and all required kernel modules enabled for OMV) can be downloaded here:

👉 **[Download custom Luckfox Pico Max firmware](https://mega.nz/file/I5VHzQSD#PCYd_8qKtv1LefM6lOAEhJJCBtf_c46-kEeAw5NMFS4)**

Feel free to use it, modify it, or treat this whole project as a playground for hacking around with OMV on unconventional hardware.

Enjoy experimenting.

[![FastPic.Org](https://i126.fastpic.org/thumb/2025/1118/76/_b8cc834e5cb625a6a4c1507cc4eb5b76.jpeg)](https://fastpic.org/view/126/2025/1118/_b8cc834e5cb625a6a4c1507cc4eb5b76.png.html)

