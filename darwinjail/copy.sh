#!/bin/bash

# RUN AS SUPER USER

rsync='/usr/local/bin/rsync'
options='-a -h -R --progress'
target='/Volumes/ram/fs'

# devices
${rsync} ${options} /dev/null     ${target}/
${rsync} ${options} /dev/ptmx     ${target}/
${rsync} ${options} /dev/random   ${target}/
${rsync} ${options} /dev/urandom  ${target}/
${rsync} ${options} /dev/zero     ${target}/

# Monterey+ dyld
${rsync} ${options} /System/Library/dyld/ ${target}/

# Ventura+ dyld
#/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_* /System/Library/dyld/

# binaries
${rsync} ${options} /bin/                                   ${target}/
${rsync} ${options} /Library/Developer/CommandLineTools/    ${target}/
${rsync} ${options} /sbin/                                  ${target}/
${rsync} ${options} /System/Library/Frameworks/             ${target}/
${rsync} ${options} /System/Library/Perl/                   ${target}/
${rsync} ${options} /usr/bin/                               ${target}/
${rsync} ${options} /usr/lib/                               ${target}/
${rsync} ${options} /usr/libexec/                           ${target}/
${rsync} ${options} /usr/sbin/                              ${target}/

# configs
${rsync} ${options} /etc/pam.d/                                               ${target}/
${rsync} ${options} /etc/ssl/                                                 ${target}/
${rsync} ${options} /etc/sudoers                                              ${target}/
${rsync} ${options} /System/Library/CoreServices/SystemVersion.plist          ${target}/
${rsync} ${options} /System/Library/CoreServices/SystemVersionCompat.plist    ${target}/
${rsync} ${options} /usr/share/                                               ${target}/
${rsync} ${options} /var/db/timezone/                                         ${target}/

# Chroot sentinel file
mkdir -p ${target}/AppleInternal/XBS
touch ${target}/AppleInternal/XBS/.isChrooted
