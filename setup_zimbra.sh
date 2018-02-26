#!/bin/bash
readonly DOMAIN_NAME=""
readonly IP_ADDRESS=$(ip -4 addr show eth0 |grep "global" | awk '{print $2}' | cut -d "/" -f 1)

## Check if another mail server is running
if lsof -Pi :25 -sTCP:LISTEN -t >/dev/null ; then
    systemctl stop postfix
    systemctl disable postfix
    ## Check again
    if lsof -Pi :25 -sTCP:LISTEN -t >/dev/null ; then
        echo "Another mail service is running. Please shutdown/disable mail service first."
        exit 1
    fi
fi

## Preparing all the variables like IP, Hostname, etc, all of them from the container
echo "mail" > /etc/hostname
hostname $(cat /etc/hostname)
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)
ADMINPASS=$(date +%s|sha256sum|base64|head -c 10)
HOSTNAME=$(hostname -s)
echo "$IP_ADDRESS $HOSTNAME.$DOMAIN_NAME $HOSTNAME" >> /etc/hosts

#Install a DNS Server
if [[ -e /etc/debian_version ]]; then
    apt-get update && apt-get install -y dnsmasq
fi
if [[ -e /etc/redhat-release ]]; then
    yum -y update && yum install -y dnsmasq
fi
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
cat <<EOF >>/etc/dnsmasq.conf
server=8.8.8.8
listen-address=127.0.0.1
domain=$DOMAIN_NAME
mx-host=$DOMAIN_NAME,$HOSTNAME.$DOMAIN_NAME,0
address=/$HOSTNAME.$DOMAIN_NAME/$IP_ADDRESS
EOF
service dnsmasq restart

##Preparing the config files to inject
mkdir /tmp/zcs && cd /tmp/zcs
touch /tmp/zcs/installZimbraScript
cat <<EOF >/tmp/zcs/installZimbraScript
AVDOMAIN="$DOMAIN_NAME"
AVUSER="admin@$DOMAIN_NAME"
CREATEADMIN="admin@$DOMAIN_NAME"
CREATEADMINPASS="$ADMINPASS"
CREATEDOMAIN="$DOMAIN_NAME"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOSTNAME.$DOMAIN_NAME"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPAMAVISPASS="$ADMINPASS"
LDAPPOSTPASS="$ADMINPASS"
LDAPROOTPASS="$ADMINPASS"
LDAPADMINPASS="$ADMINPASS"
LDAPREPPASS="$ADMINPASS"
LDAPBESSEARCHSET="set"
LDAPDEFAULTSLOADED="1"
LDAPHOST="$HOSTNAME.$DOMAIN_NAME"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="512"
MAILPROXY="TRUE"
MODE="https"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="https"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN_NAME"
SMTPHOST="$HOSTNAME.$DOMAIN_NAME"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN_NAME"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN_NAME"
SPELLURL="http://$HOSTNAME.$DOMAIN_NAME:7780/aspell.php"
STARTSERVERS="yes"
SYSTEMMEMORY="3.8"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN_NAME"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN_NAME"
UIWEBAPPS="yes"
UPGRADE="yes"
USEKBSHORTCUTS="TRUE"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN_NAME"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$ADMINPASS"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$ADMINPASS"
ldap_url="ldap://$HOSTNAME.$DOMAIN_NAME:389"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$ADMINPASS"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/jre/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraDNSMasterIP=""
zimbraDNSTCPUpstream="no"
zimbraDNSUseTCP="yes"
zimbraDNSUseUDP="yes"
zimbraDefaultDomainName="$DOMAIN_NAME"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMailProxy="FALSE"
zimbraMtaMyNetworks="127.0.0.0/8 $IP_ADDRESS/32 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="America/Los_Angeles"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckInterval="1d"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN_NAME"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN_NAME"
zimbraVersionCheckSendNotifications="TRUE"
zimbraWebProxy="FALSE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbra_server_hostname="$HOSTNAME.$DOMAIN_NAME"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy"
EOF
touch /tmp/zcs/installZimbra-keystrokes
cat <<EOF >/tmp/zcs/installZimbra-keystrokes
y
y
y
y
y
n
y
y
y
y
y
y
y
y
y
EOF
systemctl disable firewalld
systemctl stop firewalld
wget https://files.zimbra.com/downloads/8.7.11_GA/zcs-8.7.11_GA_1854.RHEL7_64.20170531151956.tgz
tar xzvf zcs-*
cd /tmp/zcs/zcs-* && ./install.sh -s < /tmp/zcs/installZimbra-keystrokes
/opt/zimbra/libexec/zmsetup.pl -c /tmp/zcs/installZimbraScript
su - zimbra -c 'zmcontrol restart'

{
    echo "======================================================"
    echo "Admin Console: https://"$HOSTNAME.$DOMAIN_NAME":7071"
    echo "Username: admin@$DOMAIN_NAME"
    echo "Password: $ADMINPASS"
    echo "WebMail: https://"$HOSTNAME.$DOMAIN_NAME
    echo ""
    echo "To delete this message: rm -f /etc/motd"
    echo "======================================================"
} >> /etc/motd

reboot