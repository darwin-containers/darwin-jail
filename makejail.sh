#!/bin/bash

# RUN AS SUPER USER

# Use Homebrew's rsync (3.x) in Monterey to prevent issues with /var/db
os_version=$(sw_vers -productVersion)
if [ "${os_version%%.*}" -eq 12 ]; then
    rsync='/usr/local/bin/rsync'
elif [ "${os_version%%.*}" -ge 13 ]; then
    rsync='/usr/bin/rsync'
else
    echo "Unsupported OS version [${os_version}]"
    exit 1
fi

options='--archive --human-readable --relative --progress'
jail_dir=$1

# devices
${rsync} ${options} /dev/null     ${jail_dir}/
${rsync} ${options} /dev/ptmx     ${jail_dir}/
${rsync} ${options} /dev/random   ${jail_dir}/
${rsync} ${options} /dev/urandom  ${jail_dir}/
${rsync} ${options} /dev/zero     ${jail_dir}/

if [ "${os_version%%.*}" -eq 12 ]; then
    ${rsync} ${options} /System/Library/dyld/ ${jail_dir}/
elif [ "${os_version%%.*}" -ge 13 ]; then
    ${rsync} -ah --progress /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld ${jail_dir}/System/Library/
else
    echo "Unsupported OS version [${os_version}]"
    exit 1
fi

# binaries
${rsync} ${options} /bin/                                   ${jail_dir}/
${rsync} ${options} /Library/Developer/CommandLineTools/    ${jail_dir}/
${rsync} ${options} /sbin/                                  ${jail_dir}/
${rsync} ${options} /System/Library/Frameworks/             ${jail_dir}/
${rsync} ${options} /System/Library/Perl/                   ${jail_dir}/
${rsync} ${options} /usr/bin/                               ${jail_dir}/
${rsync} ${options} /usr/lib/                               ${jail_dir}/
${rsync} ${options} /usr/libexec/                           ${jail_dir}/
${rsync} ${options} /usr/sbin/                              ${jail_dir}/

# configs
${rsync} ${options} /etc/pam.d/                                               ${jail_dir}/
${rsync} ${options} /etc/ssl/                                                 ${jail_dir}/
${rsync} ${options} /etc/sudoers                                              ${jail_dir}/
${rsync} ${options} /System/Library/CoreServices/SystemVersion.plist          ${jail_dir}/
${rsync} ${options} /System/Library/CoreServices/SystemVersionCompat.plist    ${jail_dir}/
${rsync} ${options} /usr/share/                                               ${jail_dir}/
${rsync} ${options} /var/db/timezone/                                         ${jail_dir}/

# Chroot sentinel file
mkdir -p ${jail_dir}/AppleInternal/XBS
touch ${jail_dir}/AppleInternal/XBS/.isChrooted
