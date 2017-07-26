# zabbix-postfix
Postfix template for Zabbix

On Server:
 * Import **template_postfix.xml** template
    
On client:

    apt-get install pflogsumm bc

    cp zabbix_postfix.sh /usr/local/sbin/
    cp pygtail.py /usr/local/sbin/
    chmod +x /usr/local/sbin/pygtail.py
    chmod +x /usr/local/sbin/zabbix_postfix.sh
    
    cp zabbix_postfix /etc/sudoers.d/
    chmod 440 /etc/sudoers.d/zabbix_postfix
    
    cp zabbix_postfix.conf /etc/zabbix/zabbix_agentd.conf.d/
    
    service sudo restart
    service zabbix-agent restart
    
 * Add crontab entry
 
    ```
    # Zabbix check
    */5 * * * * /usr/local/sbin/zabbix_postfix.sh 1>/dev/null 2>/dev/null'
    ```


