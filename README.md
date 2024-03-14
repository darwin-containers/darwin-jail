# darwin-jail

[![Build Status](https://github.com/darwin-containers/darwin-jail/workflows/CI/badge.svg?branch=main)](https://github.com/darwin-containers/darwin-jail/actions?query=branch:main)

## Prerequisites

* macOS Ventura or newer
* Disable [System Identity Protection](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection).
SIP [doesn't allow](https://github.com/containerd/containerd/discussions/5525#discussioncomment-2685649) to `chroot` (not needed for building though).

## Usage

```shell
cd "$repo_root"
sudo python3 -m darwinjail "$jail_dir" # prepare chroot dir contents
sudo chroot "$jail_dir" # enter chroot
```

In order to make DNS work in chroot, run:

```shell
sudo mkdir -p "$jail_dir/var/run"
sudo link -f /var/run/mDNSResponder "$jail_dir/var/run/mDNSResponder"
```

## Uploading Darwin rootfs as Docker image

```shell
brew install crane

# You might first need to authenticate using
# sudo crane auth login "$registry" -u "$username" -p "$password"

sudo bash -c 'crane append --oci-empty-base -t "$image_tag" -f <(tar -f - -c -C "$jail_dir" .)'
```

If you want to run Darwin image using containerd or Docker, see [instructions](https://github.com/darwin-containers/homebrew-formula#darwin-native-containers).
