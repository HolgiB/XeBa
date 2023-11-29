# XeBa
## XeBa - The Xen / XCP-ng backup tool

XeBa is an AutoIt script automatically creates backups based on a list of VMs using the provided XE tool, which is included with Xen-Center / XCP-ng center. 
XeBa accesses non-modified Xen & XCP-ng hosts from a Windows host for centralized backups. It makes sense to use a physical server with Windows Server operating system with fast network connection.
Backups can be either store locally or to any supported network shares (SMB / NFS / WebDAV). Since export speeds from Xen / XCP-ng are rather slow, using network share do not result in a big performance hit.

I did not "invent" the functionality in the first place since there are tons of scripts for Windows and Linux as well doing the same thing. 

## Usage
XeBa is controlled via CLI invocation with three parameters:
XeBa.exe *Xen Server IP* *VMs List* *Backup Mode*

*Xen Server IP*

Simply enter the IP of the management interface of the Xen hosts to be backed up. For Xen servers in a pool, enter the IP of the pool master here.

*VMs List*

Simply specify the path and filename of a text file containing the names of the VMs to be backed up.

*Backup Mode*

This is one of the following parameters controlling what XeBa does.


SNAPSHOT: 

A snapshot of the VM is created and exported as a template in an XVA file. The VM itself is briefly unreachable during this process. This method is recommended for VMs that can tolerate a hard shutdown easily (JBoss hosts, load balancers, third-party components). Explicitly excluded are database hosts or domain controllers. The snapshot itself is modified by XeBa which enables you to import the backup to a Xen-Server as VM, which is ready to boot instead of a template (which is the standard behaviour of Xen).

SHUTDOWN: 

The VM is shut down before export and restarted after the export is completed. The VM is not available during the export period but is exported in a consistent state. This method is recommended for database hosts, domain controllers, and similar systems. The prerequisite is that hosted services come up cleanly after the restart.

NOPOWERON: 

Similar to SHUTDOWN, but the VM remains off after shutdown. This method is recommended for exporting VMs during migration to another Xen server.

EXPORTONLY: 

The VM is only exported, and the power state is not changed. VMs on a server should be shut down.

MIGRATE: 

Similar to NOPOWERON, but the VM is re-imported after export on a configurable target Xen server. Both VMs remain powered off without user interaction. After migration, the VM can be configured and started on the target server. 
Important: The import occurs on the target server's configured default storage destination. If, for example, you want to import to local storage, you must select this as the default before migration.

## Initial configuration
XeBa is essentially controlled by three parameters in the XeBa.ini file:
```
[Common]
rootPW="Root password for Xen"
OutputDir="D:\XeBa-Backups"
xe="C:\Program Files (x86)\Citrix\XenCenter\xe.exe"
TargetServer="<your_xenserver_ip_for_migration>"
```

rootPW: Specify the root password for the XenServer to be backed up.

OutputDir: Set the output path for the XVA files.

xe: Set the path to the XE tool, which is installed with XenCenter.

TargetServer: IP of the target server used for the MIGRATE mode.

## Scheduled execution
You can easily use the standard task scheduler included with Windows for this or grab one of the many freeware schedulers out there. Either put your backup jobs into separate batch files or put the complete XeBa command in your task scheduler.

## Points to consider
XeBa does not any sophisticated things like adding timestamps to your backup files or keeping track only to backup three versions of a certain VM. You will have either to modify the source code for this by yourself or do some scripting magic outisde XeBa for copying and renaming files. It should not be too complicated to build a full automated backup solution with XeBa for your homelab. We have used XeBa in the past in a rather big Xen infrastructure (25+ XenServer) but recently move away to XCP-ng as virtualisation platform and Xen Orchestra for backing up our VMs.

