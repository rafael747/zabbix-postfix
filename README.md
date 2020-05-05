# zabbix-postfix
Postfix template for Zabbix

On Server:
 * Import **template_postfix.xml** template
    
On client: 

    # Install the following packages
    
    # Debian/Ubuntu
    apt install pflogsumm bc zabbix-agent zabbix-sender
    
    # RHEL/Centos (replace the zabbix version with the one your using)
    yum install https://repo.zabbix.com/zabbix/4.2/rhel/6/x86_64/zabbix-release-4.2-1.el6.noarch.rpm
    yum install postfix-perl-scripts bc zabbix-agent zabbix-sender

    cp zabbix_postfix.sh /usr/local/sbin/
    cp pygtail.py /usr/local/sbin/
    chmod +x /usr/local/sbin/pygtail.py
    chmod +x /usr/local/sbin/zabbix_postfix.sh
    
    cp zabbix_postfix /etc/sudoers.d/
    chmod 440 /etc/sudoers.d/zabbix_postfix
    
    # Zabbix agent config dir may change, see https://github.com/rafael747/zabbix-postfix/issues/3#issuecomment-623629611
    # Debian/Ubuntu
    cp zabbix_postfix.conf /etc/zabbix/zabbix_agentd.conf.d/
    
    # RHEL/Centos
    cp zabbix_postfix.conf /etc/zabbix/zabbix_agentd.d/
    
    service sudo restart
    service zabbix-agent restart
    
 * Add crontab entry
 
    ```
    # Zabbix check
    */5 * * * * /usr/local/sbin/zabbix_postfix.sh 1>/dev/null 2>/dev/null'
    ```

 ### or

 * Install **zabbix-agent** and **zabbix-sender**
 
 * Use **install_postfix_template_zabbix.sh** script (tested only in Ubuntu 16.04/18.04 )
 
