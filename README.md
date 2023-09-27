# macos-jail

[![Build Status](https://github.com/macOScontainers/macos-jail/workflows/CI/badge.svg?branch=main)](https://github.com/macOScontainers/macos-jail/actions?query=branch:main)

> **Note**
> Artifacts published in this repo contain software covered by [macOS EULA](https://www.apple.com/legal/sla/) and are only intended to be run on Apple hardware.

## Prerequisites

* MacOS Catalina or newer
* Disable [System Identity Protection](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection).
SIP [doesn't allow](https://github.com/containerd/containerd/discussions/5525#discussioncomment-2685649) to `chroot` (not needed for building though).

## Usage

```shell
cd "$repo_root"
sudo python3 -m macosjail "$jail_dir" # prepare chroot dir contents
sudo chroot "$jail_dir" # enter chroot
```

In order to make DNS work in chroot, run:

```shell
sudo mkdir -p "$jail_dir/var/run"
sudo link -f /var/run/mDNSResponder "$jail_dir/var/run/mDNSResponder"
```

## Uploading macOS rootfs as Docker image

```shell
brew install crane

# You might first need to authenticate using
# sudo crane auth login "$registry" -u "$username" -p "$password"

sudo bash -c 'crane append --oci-empty-base --platform darwin -t "$image_tag" -f <(tar -f - -c -C "$jail_dir" .)'
```

If you want to run macOS image in [containerd](https://containerd.io), see [rund](https://github.com/macOScontainers/rund) project.
