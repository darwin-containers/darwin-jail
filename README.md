# macos-jail

[![GitHub Actions](https://github.com/slonopotamus/macos-jail/workflows/CI/badge.svg?branch=master)](https://github.com/slonopotamus/macos-jail/actions/workflows/ci.yml?query=branch%3Amaster)

## Usage

```bash
$ cd <repo root>
$ sudo python3 -m macosjail <jail dir> # this will prepare chroot dir contents
$ sudo chroot <jail dir>
```
