# abs-rsync

This is slightly modified version of [rsync](https://rsync.samba.org/) that is employed in [ABS (Advance Batch System)](https://github.com/kulhanek/abs). ABS copies data between an input directory, which can be either on an input machine or storage machine, and a working directory, which is on a working node. Due to heterogeneity in gid namespaces and filesystems employed on input, storage, and working machines, ABS employs a sofisticated gid mapping using the *--chown=* option of the rsync command. This works except of *nfs4* filesystems with the *krb5\** security favour and the [metanfs4](https://github.com/kulhanek/metanfs4) nfsidmap and nsswitch services. On such filesystems, user can change a group of file/directory even to a group, which is not not listed in user groups (this is because the validity of such change is not tested locally but on a NFS server).

Examples:
```bash
[kulhanek@pes tmp]$ ls -l
total 540
-rw-r----- 1 kulhanek@META kulhanek@META 403841 Feb  2 18:34 dna_only.parm7
-rw-r--r-- 1 kulhanek@META kulhanek@META  34659 Feb  2 21:38 Gau-67402.EIn.rst7
[kulhanek@pes tmp]$ id
uid=1001(kulhanek) gid=1001(kulhanek) groups=1001(kulhanek),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd),115(lpadmin),116(sambashare),131(vboxusers),132(libvirtd),133(kvm),999(infinity)
[kulhanek@pes tmp]$ chgrp  ncbr@META dna_only.parm7
[kulhanek@pes tmp]$ ls -l
total 540
-rw-r----- 1 kulhanek@META ncbr@META     403841 Feb  2 18:34 dna_only.parm7
-rw-r--r-- 1 kulhanek@META kulhanek@META  34659 Feb  2 21:38 Gau-67402.EIn.rst7
```

Due to rsync internal checks on a receiving side the request for the group change via *--chown=:ncbr@META* is ignored. This problem is solved by this rsync modification.

    
## Modification
*  uidlist.c - skip testing of group membership in user groups

## Instalation
This software can be installed into the Infinity software repository employing the following procedure: 
```bash
$ git clone https://github.com/kulhanek/abs-rsync.git
$ cd abs-rsync
$ ./10.build-final.sh
```

