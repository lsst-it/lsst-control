## This file is managed by Puppet; changes may be overwritten.
# shellcheck shell=bash

[ $UID -ge 1000 ] || return

# Stop python OpenBLAS running amok.
export OMP_NUM_THREADS=1

# Add /lsst/ccs/prod/bin to PATH if not present.
_dir=/lsst/ccs/prod/bin
[ -e $_dir ] && [[ $PATH != *$_dir* ]] && PATH=$_dir:$PATH
unset _dir

[ ! -e /opt/rh/rh-git218 ] || source scl_source enable rh-git218
