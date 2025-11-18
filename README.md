# openmediavault-ubuntu

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
  - `armhf`

- A helper script `build_packs.sh` to (re)build packages for your architecture if prebuilt ones are missing.

- A vendored `jc-1.25.6.tar.gz` used to make system info / statistics in the OMV web UI work correctly on Ubuntu.

---

## Requirements

- Ubuntu (systemd-based; Server/Desktop, amd64 or armhf)
- Root access (`sudo` or direct root)
- Internet access for pulling dependencies from Ubuntu and Debian repositories

It is strongly recommended to start from a **clean** Ubuntu installation.

---

## Quick start

```bash
git clone https://github.com/bogdik/openmediavault-ubuntu.git
cd openmediavault-ubuntu

chmod +x install.sh
sudo ./install.sh
