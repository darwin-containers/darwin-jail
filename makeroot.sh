#!/bin/bash

# RUN AS SUPER USER

# Use Homebrew's rsync (3.x) in Monterey to prevent issues with /var/db
rsync='/usr/local/bin/rsync'
options='-a -h -R --progress'
jail_dir=$1

# # devices
# ${rsync} ${options} /dev/null     ${jail_dir}/
# ${rsync} ${options} /dev/ptmx     ${jail_dir}/
# ${rsync} ${options} /dev/random   ${jail_dir}/
# ${rsync} ${options} /dev/urandom  ${jail_dir}/
# ${rsync} ${options} /dev/zero     ${jail_dir}/

# # Monterey+ dyld
# ${rsync} ${options} /System/Library/dyld/ ${jail_dir}/

# # Ventura+ dyld
# #/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_* /System/Library/dyld/

# # binaries
# ${rsync} ${options} /bin/                                   ${jail_dir}/
# ${rsync} ${options} /Library/Developer/CommandLineTools/    ${jail_dir}/
# ${rsync} ${options} /sbin/                                  ${jail_dir}/
# ${rsync} ${options} /System/Library/Frameworks/             ${jail_dir}/
# ${rsync} ${options} /System/Library/Perl/                   ${jail_dir}/
# ${rsync} ${options} /usr/bin/                               ${jail_dir}/
# ${rsync} ${options} /usr/lib/                               ${jail_dir}/
# ${rsync} ${options} /usr/libexec/                           ${jail_dir}/
# ${rsync} ${options} /usr/sbin/                              ${jail_dir}/

# # configs
# ${rsync} ${options} /etc/pam.d/                                               ${jail_dir}/
# ${rsync} ${options} /etc/ssl/                                                 ${jail_dir}/
# ${rsync} ${options} /etc/sudoers                                              ${jail_dir}/
# ${rsync} ${options} /System/Library/CoreServices/SystemVersion.plist          ${jail_dir}/
# ${rsync} ${options} /System/Library/CoreServices/SystemVersionCompat.plist    ${jail_dir}/
# ${rsync} ${options} /usr/share/                                               ${jail_dir}/
# ${rsync} ${options} /var/db/timezone/                                         ${jail_dir}/

# # Chroot sentinel file
# mkdir -p ${jail_dir}/AppleInternal/XBS
# touch ${jail_dir}/AppleInternal/XBS/.isChrooted

os_version=$(sw_vers -productVersion)
if [ "${os_version%%.*}" -eq 12 ]; then
    echo "monterey"
elif [ "${os_version%%.*}" -ge 13 ]; then
    echo "ventura and later"
else
    echo "unsupported os version"
    exit 1
fi
