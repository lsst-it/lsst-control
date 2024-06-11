## This file is managed by Puppet; changes may be overwritten.
# shellcheck shell=bash

[ $UID -ge 1000 ] || return

# Stop python OpenBLAS running amok.
export OMP_NUM_THREADS=1

# Add some directories to PATH if not present, eg
# /usr/local/bin can be missing inside sudo -u ccs.
for _dir in /opt/lsst/ccs/prod/bin /usr/local/bin; do
    [ -e $_dir ] && [[ $PATH != *$_dir* ]] && PATH=$_dir:$PATH
done
unset _dir

# shellcheck disable=SC1091
[ ! -e /opt/rh/rh-git218 ] || source scl_source enable rh-git218
