#!/bin/bash

set -e

# Installation script for zabbix-postfix client scripts and configuration
# Based on: https://github.com/gatespb/zabbix_templates

echo -e "\n#### Installing zabbix-postfix client scripts and configs ####\n"

cd /usr/local/sbin

echo -n "Downloading scripts..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zabbix_postfix.sh >/dev/null
wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/pygtail.py > /dev/null

echo  "OK!"

chmod +x pygtail.py
chmod +x zabbix_postfix.sh

# sudoers rule to allow zabbix-client runnung required commands

cd /etc/sudoers.d/

echo -n "Downloading sudoers rules..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zabbix_postfix >/dev/null

echo "OK!"

chmod 440 zabbix_postfix

# Zabbix client configuration (mailq command, postfix queue size)

# For Debian/Ubuntu
[ -d /etc/zabbix/zabbix_agentd.conf.d/ ] && cd /etc/zabbix/zabbix_agentd.conf.d/
# For RHEL/Centos
[ -d /etc/zabbix/zabbix_agentd.d/ ] && cd /etc/zabbix/zabbix_agentd.d/

echo -n "Downloading zabbix agent configuration..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zabbix_postfix.conf >/dev/null

echo "OK!"

echo -n "Restarting services..."
service sudo restart >/dev/null
service zabbix-agent restart >/dev/null

echo "OK!"

echo '# Install the following packages'
echo '# Debian/Ubuntu'
echo 'apt install pflogsumm bc zabbix-sender'
echo ''
echo '# RHEL/Centos'
echo 'yum install postfix-perl-scripts bc zabbix-sender'

echo -e "\nAdd the following crontab entry:\n"

echo '# Zabbix check'
echo '*/5 * * * * /usr/local/sbin/zabbix_postfix.sh 1>/dev/null 2>/dev/null'
