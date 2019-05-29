#!/bin/bash

set -e

# script que instala o template para monitoramento do postfix no zabbix agent
# Baseado em: https://github.com/gatespb/zabbix_templates

# scripts necessarios

echo -e "\n#### Instalação do template para monitoramento do postfix via zabbix ####\n"

cd /usr/local/sbin

echo -n "Baixando scripts..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zabbix_postfix.sh >/dev/null
wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/pygtail.py > /dev/null

echo  "OK!"

chmod +x pygtail.py
chmod +x zabbix_postfix.sh

# regra permitindo zabbix executar comandos

cd /etc/sudoers.d/

echo -n "Baixando regra de sudors..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zabbix_postfix >/dev/null

echo "OK!"

chmod 440 zabbix_postfix

# Configuracao do zabbix (mailq infomacao)

cd /etc/zabbix/zabbix_agentd.conf.d/

echo -n "Baixando configuração do zabbix..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zabbix_postfix.conf >/dev/null

echo "OK!"

echo -n "Reiniciando serviços..."
service sudo restart >/dev/null
service zabbix-agent restart >/dev/null

echo "OK!"

echo "Instale os seguintes pacotes: pflogsumm (visualizador de log do postfix) e bc ..."
echo "Debian/Ubuntu"
echo "apt-get install pflogsumm bc"
echo ""
echo "RHEL/Centos"
echo "yum install postfix-perl-scripts bc"

echo -e "\nInsira a entrada a seguir na cron:\n"

echo '# Zabbix check'
echo '*/5 * * * * /usr/local/sbin/zabbix_postfix.sh 1>/dev/null 2>/dev/null'
