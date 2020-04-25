## This file is managed by Puppet; changes may be overwritten.

[ $UID -ge 1000 ] || return

# Stop python OpenBLAS running amok.
export OMP_NUM_THREADS=1

# Add /lsst/ccs/prod/bin to PATH if not present.
_dir=/lsst/ccs/prod/bin
[ -e $dir ] && [[ $PATH != *$_dir* ]] && PATH=$_dir:$PATH
unset _dir
