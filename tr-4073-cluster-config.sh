# The following shell script can be run from any client that supports shell scripts using SSH key–based login. 
# The script does not include CIFS setup.
# This script works for clustered Data ONTAP 8.1 and 8.2. 
#	The script requires some interaction (such as user name/password for the user to create the machine account). 
#	Replace the entries in {brackets} with the necessary information and save as Kerberos_setup.sh. 
#	The script can be modified to include commands to modify rather than create DNS/NFS and so on by commenting/uncommenting the line.
#	This script is not supported by NetApp and does not cover every use case.

#!/bin/bash
# Linux/UNIX box with ssh key based login enabled
###########################
# Define script variables #
###########################
cluster="{10.10.10.10}"
# SSH User name
USR="ssh"
vserver="{vserver}"
#Kerberos
realm="{REALM.NETAPP.COM}"
fqdn="{host.domain.netapp.com}"
dns="{domain.netapp.com}"
domain="{domain.netapp.com}"
nameservers="{ns1,ns2..}"
v3enable="{enabled|disabled}"
v4enable="{enabled|disabled}"
v41enable="{enabled|disabled}"
realmconfigname="{Realm config name}"
kdcip="{KDC IP}"
adminserver="{Admin server IP}"
passwdserver="{Passwd server IP}"
kdcname="{DC Name}"
lif="{lif name}"
spn="{nfs/fqdn@REALM.NETAPP.COM}"
#Export policy
policyname="{Kerberos policy}"
clientmatch="{IP|host|subnet|netgroup}"
rorule="{sys,krb5|all|none}"
rwrule="{sys,krb5|all|none}"
anonid="{UID}"
superuser="{any|none|never|sys|krb5}"
protocol="{any|cifs|nfs|nfs3|nfs4}"
#name-mapping rule/unix user create
nfsid="{nfs UID}"
username="{Username to replace SPN}"
#LDAP config
ldapconfigname="{LDAP config name}"
ldapaddress="{LDAP1,LDAP2..}"
schema="{AD-IDMU|AD-SFU|AD-SFU-Deprecated|RFC-2307|custom schema}"
bindlevel="{anonymous|sasl|simple}"
basedn="{dc=domain,dc=netapp,dc=com}"
userdn="{dc=domain,dc=netapp,dc=com}"
groupdn="{dc=domain,dc=netapp,dc=com}"
binddn="{bind username}"
basescope="{base|onelevel|subtree}"
userscope="{base|onelevel|subtree}"
groupscope="{base|onelevel|subtree}"
netgroupscope="{base|onelevel|subtree}"
nsswitchdb=”{group,hosts,namemap,netgroup,passwd}
#CIFS config (optional)
cifserver="{CIFS server name}"
##########################################
# DNS - remove comment (#) to include line
##########################################
#ssh $USR@$cluster dns create -vserver $vserver -domains $dns -name-servers $nameservers -state enabled
#ssh $USR@$cluster dns modify -vserver $vserver -domains $dns -name-servers $nameservers -state enabled
##########################################
# NFS - remove comment (#) to include line
##########################################
#ssh $USR@$cluster nfs create -vserver $vserver -access true -v3 $v3enable -v4.0 $v4enable -v4.1 $enable
#ssh $USR@$cluster nfs modify -vserver $vserver -access true -v3 $v3enable -v4.0 $v4enable -v4.1 $v41enable
##########################################
# Default Unix Users - remove comment (#) to include line
##########################################
#ssh $USR@$cluster unix-user create -vserver $vserver -user root -id 0 -primary-gid 0
#ssh $USR@$cluster unix-user create -vserver $vserver -user pcuser -id 65534 -primary-gid 65534
#ssh $USR@$cluster unix-user create -vserver $vserver -user nobody -id 65535 -primary-gid 65535
#ssh $USR@$cluster unix-group create -vserver $vserver -name root -id 0
#ssh $USR@$cluster unix-group create -vserver $vserver -name pcuser -id 65534
#ssh $USR@$cluster unix-group create -vserver $vserver -name nobody -id 65535
##########################################
# Kerberos - remove comment (#) to include line
##########################################
#ssh $USR@$cluster kerberos-realm create -configname $realmconfigname -realm $realm -kdc-vendor Microsoft -kdc-ip $kdcip -kdc-port 88 -clock-skew 5 -adminserver-ip $adminserver -adminserver-port 749 -passwordserver-ip $passwdserver -passwordserver-port 464 -adserver-name $kdcname -adserver-ip $kdcip
##########################################
# Export Policy - remove comment (#) to include line
##########################################
#ssh $USR@$cluster export-policy create -vserver $vserver -policyname $policyname
#ssh $USR@$cluster export-policy rule create -vserver $vserver -policyname $policyname -clientmatch $clientmatch -rorule $rorule -rwrule $rwrule -anon $anonid -superuser $superuser -ruleindex 1 -protocol $protocol
##########################################
# Enable Kerberos - remove comment (#) to include line
##########################################
#ssh $USR@$cluster kerberos-config modify -vserver $vserver -lif $lif -kerberos enabled -spn $spn
####################################################################################
# Create Unix User or Name mapping rule - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster unix-user create -vserver $vserver -user nfs -id $nfsid -primary-gid 65534
#ssh $USR@$cluster vserver name-mapping create -vserver $vserver -direction krb-unix -position 1 -pattern $spn -replacement $username
####################################################################################
# Create LDAP client - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster "set advanced; ldap client create -client-config $ldapconfigname -servers $ldapaddress -schema $schema -port 389 -query-timeout 3 -min-bind-level $bindlevel -base-dn $basedn -base-scope $basescope -user-scope $userscope -group-scope $groupscope -netgroup-scope $netgroupscope -bind-dn $binddn -user-dn $userdn -group-dn $groupdn -vserver $vserver"
####################################################################################
#Create CIFS server (optional) - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster cifs server create -vserver $vserver -cifs-server $cifserver -domain $domain -ou CN=Computers
####################################################################################
# Modify LDAP client if using CIFS as well - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster "set advanced; ldap client modify -client-config $ldapconfigname -vserver $vserver -bind-as-cifs-server true -ad-domain $domain -preferred-ad-servers $ldapaddress"
####################################################################################
# Create LDAP config - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster ldap create -vserver $vserver -client-config $ldapconfigname -client-enabled true
####################################################################################
# Modify SVM to use LDAP in 8.2.x and earlier - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster vserver modify -vserver $vserver -ns-switch file,ldap -nm-switch [file,ldap]
####################################################################################
# Modify SVM to use LDAP in 8.3 and later - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster name-service ns-switch modify -vserver $vserver -database $nsswitchdb -sources file,ldap
####################################################################################
# NFSv4 Config - remove comment (#) to include line
####################################################################################
#ssh $USR@$cluster nfs modify -vserver $vserver -v4.0 $v4enable -v4.1 $v41enable -v4-id-domain $domain
