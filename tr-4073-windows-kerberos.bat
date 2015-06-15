# This is a sample batch file for creating Kerberos principals and DNS records for use with Kerberized NFS in clustered Data ONTAP. 
# Some modifications may be needed depending on version of clustered Data ONTAP being used. 
# PowerShell 2.0 or later is recommended. 
#
# Instructions for use:
#	Copy, paste, and modify the following into a file on a Windows KDC.
#	Replace the entries in <brackets> with the necessary information. The first section defines variables.
#	Save the file as “filename.bat.” 
#	Run the file from cmd.
#	The file is not supported by NetApp and does not cover every use case.
PowerShell.exe -noninteractive -command "set-variable -name strhostnamelong -value "<fqdn.domain.netapp.com>";  set-variable -name strhostnameshort -value "<shortname> "; set-variable -name strdc -value "<dc name>"; $strfqdn; $strhostnameshort; $strdc; $strhostnamelong; import-module activedirectory; New-ADComputer -Name $strhostnameshort -SAMAccountName $strhostnameshort -DNSHostName $strhostnamelong -OtherAttributes @{'userAccountControl'=2097152;'msDS-SupportedEncryptionTypes'=27}; exit"
ktpass -princ <root/host.domain.netapp.com@DOMAIN.NETAPP.COM> -mapuser <DOMAIN\host$> -crypto ALL +rndpass -ptype KRB5_NT_PRINCIPAL +Answer -out <host>.keytab
dnscmd /RecordAdd <domain.netapp.com> <hostname> /CreatePTR A <IP>
dnscmd /RecordAdd <domain.netapp.com> _kerberos-master._tcp SRV 0 100 88 <win2k8DC.domain.netapp.com>
dnscmd /RecordAdd <domain.netapp.com> _kerberos-master._udp SRV 0 100 88 <win2k8DC.domain.netapp.com>
dnscmd /RecordAdd <domain.netapp.com> @ /CreatePTR A <DC1 IP>
dnscmd /RecordAdd <domain.netapp.com> @ /CreatePTR A <DC2 IP>
