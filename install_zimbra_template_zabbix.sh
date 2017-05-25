#!/bin/bash

set -e

# script que instala o template do zimbra para monitoramento zabbix
# from: https://github.com/gatespb/zabbix_templates

#scripts necessarios

echo -e "\n#### Instalação do template de zimbra para monitoramento via zabbix ####\n"

cd /usr/local/sbin

echo -n "Baixando scripts..."

wget -q -N https://raw.githubusercontent.com/rafael747/zabbix-postfix/master/zimbra_postfix.sh >/dev/null
wget -q -N https://raw.githubusercontent.com/gatespb/zabbix_templates/237d38961a541ba3ab76def95669a500c20ebf55/templates/Zimbra/client/scripts/pygtail.py > /dev/null

echo  "OK!"


chmod +x pygtail.py
chmod +x zimbra_postfix.sh

# regra permitindo zabbix executar comandos

cd /etc/sudoers.d/

echo -n "Baixando regra de sudors..."

wget -q -N https://raw.githubusercontent.com/gatespb/zabbix_templates/237d38961a541ba3ab76def95669a500c20ebf55/templates/Zimbra/client/sudoers.d/zabbix_zimbra >/dev/null

echo "OK!"

chmod 440 zabbix_zimbra

# Configuracao do zabbix (mailq infomacao)

cd /etc/zabbix/zabbix_agentd.conf.d/

echo -n "Baixando configuração do zabbix..."

wget -q -N https://raw.githubusercontent.com/gatespb/zabbix_templates/237d38961a541ba3ab76def95669a500c20ebf55/templates/Zimbra/client/zabbix_agentd.conf.d/zimbra_postfix.conf >/dev/null

echo "OK!"
# verificar tarefa na cron
echo -n "Verificando tarefa na cron..."

if cat /var/spool/cron/crontabs/root |grep "Zabbix check" > /dev/null
then
	echo "Tarefa já agendada"
else
	echo "Não instalada!"
	echo -n "Instalando tafera na cron..."
	echo '# Zabbix check' >> /var/spool/cron/crontabs/root
	echo '*/5 * * * * root /usr/local/sbin/zimbra_postfix.sh 1>/dev/null 2>/dev/null' >> /var/spool/cron/crontabs/root
	echo "OK!"
fi


echo -n "Reiniciando serviços..."
service sudo restart >/dev/null
service zabbix-agent restart >/dev/null

echo "OK!"

echo "Instalando pflogsumm (visualizador de log do postfix)..."
apt-get install pflogsumm
echo "OK!"
