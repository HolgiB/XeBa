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



