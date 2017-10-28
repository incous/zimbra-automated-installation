# Zimbra
In this Repository you will find different Zimbra Scripts for install Zimbra Collaboration on an automated way

# ZimbraEasyInstall
##What is the ZimbraEasyInstall
The ZimbraEasyInstall Script is an easy way to install Zimbra Collaboration, without be worry of the DNS configuration, OS depencies, etc. Just execute it and after a few minutes have Zimbra up and running.
This Script install and configures dnsmasq with the domain that is defined while invoke the command and the current public IP of system (get by dig command, query to OpenDNS). After that, the Scripts prepare the keystroke script with a default installation of Zimbra Collaboration 8.7.11 (without dnscache) and the config.defaults script, using the domain, IP and generate admin password. Once everything is ready, the Script download the latest version of Zimbra Collaboration 8.7.11, uncompress it and install it using the keystrokes script and the config script.

##Advantages of use the Script
 * Time saving
 * Fully automated
 * Easy to use
 * Good for a quick Zimbra Preview

##Usage and Example
The ZimbraEasyInstall Script is an easy way to install Zimbra Collaboration, without be worry of the DNS configuration, OS depencies, etc. Just execute it and after a few minutes have Zimbra up and running.

Just run the Script adding the TLD domain for your Zimbra Collaboration server, the server public IP address will be automatically detect by a dig command (so it need bind-utils installed as prerequisites), and the admin account password will be generated.
```bash
./ZimbraEasyInstall domain.com
```

##Access to the Web Client and Admin Console
The Script will take care of everything and after a few minutes you can go to the IP of your server and use the next URL:
 * Web Client - https://YOURIP
 * Admin Console - https://YOURIP:7071
 
## ToDo
- [ ] Prepare and configure automatically the Reverse DNS Zone
- [ ] Make it multi-platform to use it in RedHat, Suse and Ubuntu 12.04
- [ ] Make it Multi-Server, to install in each server only the rol that selects (LDAP, Mailbox, MTA, PROXY, UI)
- [ ] Have the option to select the Timezone, the default one is Los Angeles
