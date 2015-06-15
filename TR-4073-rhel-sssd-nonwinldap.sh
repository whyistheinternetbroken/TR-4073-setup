# The following shell script has been tested with RHEL6.x/CentOS6.x/Fedora13 clients. Newer clients may need adjustments to this script.
# This script is intended to setup and configure clients for SSSD LDAP, Kerberized NFS and NFSv4.x with non-Windows LDAP. Anonymous bind is used.
# To use SASL or more secure binds, please see the vendor product documentation for configuration.
# 
# Instructions for use:
#	Copy, paste, and modify the following into a file on an NFS client to be used with Kerberos. 
#	Replace the variables at the beginning of the script with the necessary values.
#	Uncomment out the entries intended for use.
#	The file is not supported by NetApp and does not cover every use case.
#	Split the script into sections and run each section separately so that you can troubleshoot issues more easily.
*
*
###################################
####  Define variables below!  ####
###################################
#!/bin/bash
# Linux/UNIX box with ssh key based login enabled
linuxhost={hostname}
dnsIP1={IP}
###Add Additional DNS servers if desired
#dnsIP2={IP}
#dnsIP3={IP}
fqdn={domain.netapp.com}
domain={DOMAIN}
realm={DOMAIN.NETAPP.COM}
defaultdomain={netapp.com}
userdn={cn=People,dc=domain,dc=netapp,dc=com}
groupdn={cn=Groups,dc=domain,dc=netapp,dc=com}
basedn={dc=domain,dc=netapp,dc=com}
###################################
####  Define variables above!  ####
###################################
## Script backs files up to ensure config can be reverted easily
######################
### Network config ###
######################
### Modify the network config to include the hostname
## NOTE: Review the contents of the network file before modifying
#mv /etc/sysconfig/network /etc/sysconfig/network-original
#echo NETWORKING=yes > /etc/sysconfig/network; echo HOSTNAME=$linuxhost.$fqdn >> /etc/sysconfig/network
#hostname $linuxhost.$fqdn
#echo #######################
#echo Hostname configured!
#echo #######################
#cat /etc/sysconfig/network
### Configure DNS
#mv /etc/resolv.conf /etc/resolv.conf-old
#echo search $fqdn > /etc/resolv.conf; echo nameserver $dnsIP1 >> /etc/resolv.conf
###Add additional DNS servers if desired
#echo nameserver $dnsIP2 >> /etc/resolv.conf
#echo nameserver $dnsIP3 >> /etc/resolv.conf
#echo #######################
#echo DNS is configured!
#echo #######################
#cat /etc/resolv.conf
#nslookup $linuxhost
### modify /etc/resolv.conf to prevent overwrite
#chattr -i /etc/resolv.conf
######################
###  Install pkgs  ###
######################
### Install/Update Kerberos packages
#yum install krb5-workstation -y
#yum install pam_krb5 -y
#yum install krb5-appl-clients -y
#### Install/update NFSv4
#yum install nfs-utils -y
#### Install/update SSSD
#yum install sssd -y
# yum remove nscd
######################
## Kerberos Config ###
######################
#### Allow MD5 in RHEL 6.4
#echo NSS_HASH_ALG_SUPPORT=+MD5 > /etc/environment
## Allow secure NFS
#sed -i 's/#SECURE_NFS/SECURE_NFS/g' /etc/sysconfig/nfs
#echo #######################
# echo Secure NFS configured!
#echo #######################
#cat /etc/sysconfig/nfs | grep SECURE_NFS
###Configure /etc/krb5.conf
#mv /etc/krb5.conf /etc/krb5.default
#echo [libdefaults]> /etc/krb5.conf
#echo  default_realm = $realm>> /etc/krb5.conf
#echo  dns_lookup_realm = true>> /etc/krb5.conf
#echo  dns_lookup_kdc = true>> /etc/krb5.conf
#### DES ONLY ####
#echo  allow_weak_crypto = true>> /etc/krb5.conf
#### AES ONLY ####
#echo  allow_weak_crypto = false>> /etc/krb5.conf
#echo  >> /etc/krb5.conf
#echo [realms]>> /etc/krb5.conf
#echo        $realm = {>> /etc/krb5.conf
#echo   kdc = $fqdn:88>> /etc/krb5.conf
#echo            default_domain = $fqdn>> /etc/krb5.conf
#echo        }>> /etc/krb5.conf
#echo  >> /etc/krb5.conf
#echo [logging]>> /etc/krb5.conf
#echo        kdc = FILE:/var/log/krb5kdc.log>> /etc/krb5.conf
#echo        admin_server = FILE:/var/log/kadmin.log>> /etc/krb5.conf
#echo        default = FILE:/var/log/krb5lib.log>> /etc/krb5.conf
#echo  >> /etc/krb5.conf
#echo [domain_realm]>> /etc/krb5.conf
#echo        .$defaultdomain = $realm>> /etc/krb5.conf
#echo        .$fqdn = $realm>> /etc/krb5.conf
#echo #######################
#echo Kerberos file is configured!
#echo #######################
#cat /etc/krb5.conf
#### Create Keytab file
### Keytab file must be moved from KDC before this step
#ktutil <<EOF
#rkt /$linuxhost.keytab
#wkt /etc/krb5.keytab
#list
#exit
#EOF
#### Restart Kerberos service
#service rpcgssd restart
########################
##### NFSv4 Config #####
########################
#### Configure /etc/idmpad.conf (if not already configured)
#mv /etc/idmapd.conf /etc/idmapd.default; echo [General] > /etc/idmapd.conf; echo Domain = $fqdn >> /etc/idmapd.conf; echo [Mapping] >> /etc/idmapd.conf; echo Nobody-User = nobody >> /etc/idmapd.conf; echo Nobody-Group = nobody >> /etc/idmapd.conf; echo [Translation] >> /etc/idmapd.conf; echo Method = nsswitch >> /etc/idmapd.conf; chmod 0600 /etc/idmapd.conf; chown root:root /etc/idmapd.conf
#echo #######################
#echo NFSv4 domain configured!
#echo #######################
#cat /etc/idmapd.conf
#### Restart idmapd
#service rpcidmapd restart
######################################################
##### SSSD Config Non-Windows LDAP (anon bind)   #####
######################################################
#### Configure the /etc/sssd/sssd.conf file
#mv /etc/sssd/sssd.conf /etc/sssd/sssd.default
#echo [domain/default] > /etc/sssd/sssd.conf
#echo cache_credentials = True >> /etc/sssd/sssd.conf
#echo case_sensitive = False >> /etc/sssd/sssd.conf
#echo [sssd] >> /etc/sssd/sssd.conf
#echo config_file_version = 2 >> /etc/sssd/sssd.conf
#echo services = nss, pam >> /etc/sssd/sssd.conf
#echo domains = $domain >> /etc/sssd/sssd.conf
#echo debug_level = 7 >> /etc/sssd/sssd.conf
#echo [nss] >> /etc/sssd/sssd.conf
#echo filter_users = root,ldap,named,avahi,haldaemon,dbus,radiusd,news,nscd >> /etc/sssd/sssd.conf
#echo filter_groups = root >> /etc/sssd/sssd.conf
#echo [pam] >> /etc/sssd/sssd.conf
#echo [domain/$domain] >> /etc/sssd/sssd.conf
#echo id_provider = ldap >> /etc/sssd/sssd.conf
#echo case_sensitive = false >> /etc/sssd/sssd.conf
#echo cache_credentials = false >> /etc/sssd/sssd.conf
#echo ldap_uri = _srv_,ldap://$fqdn >> /etc/sssd/sssd.conf
#echo ldap_search_base = $basedn >> /etc/sssd/sssd.conf
#echo ldap_schema = rfc2307 >> /etc/sssd/sssd.conf
#echo ldap_user_object_class = posixAccount >> /etc/sssd/sssd.conf
#echo ldap_group_object_class = posixGroup >> /etc/sssd/sssd.conf
#echo ldap_user_home_directory = homeDirectory >> /etc/sssd/sssd.conf
#echo ldap_force_upper_case_realm = true >> /etc/sssd/sssd.conf
#echo ldap_group_search_base = $groupdn >> /etc/sssd/sssd.conf
#echo #######################
#echo SSSD conf file created!
#echo #######################
#cat /etc/sssd/sssd.conf
#### Ensure /etc/sssd/sssd.conf is 0600 perms
#chmod 0600 /etc/sssd/sssd.conf
#chown root:root /etc/sssd/sssd.conf
#### Enable SSSD and SSSD auth
#authconfig --enablesssd --enablesssdauth --updateall
#### Restart SSSD
#service sssd restart
