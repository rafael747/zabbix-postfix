# zabbix-postfix-template

Zabbix template for Postfix SMTP server as passive agent check:

https://blog.zabbix.com/zabbix-agent-active-vs-passive/

Tested on zabbix 5.4.3 and Python3

Merged from http://admin.shamot.cz/?p=424 , kstka/zabbix-postfix-template & Kreibich-xyz/zabbix-postfix-integration

# Requirements
* [pflogsum](http://jimsun.linxnet.com/postfix_contrib.html)
* [pygtail](https://pypi.org/project/pygtail/)

# Using Installer
Before using the installer, make sure you have your zabbix-agent installed, set up and checked the connection to the zabbix-server!

    # Clone Repo
    git clone https://github.com/rafael747/zabbix-postfix
    
    cd zabbix-postfix
    
    # Make sure, you run the script as root!
    chmod +x ./install_postfix_template_zabbix_passive.sh
    ./install_postfix_template_zabbix_passive.sh
    
    # Now follow the instructions in the script.
    # If the script runs into a problem, fall back to the corrosponding step in Manual Installation and report the error and some system-information to info@kreibich.xyz.
   
Now download the template_postfix_passive.xml, import it into zabbix and attach it to your host. 
To see if everything works fine, wait a few minutes, go to the latest data of your host and search for 'postfix'. The line 'Postfix data update request' should show the error if there is one.

# Manual Installation
    # for Ubuntu / Debian
    apt-get install pflogsumm
    
    # for CentOS
    yum install postfix-perl-scripts
    
    # install pygtail using pip
    # alternatively you can manually install pygtail and specify the executable-path in zabbix_postfix_passive.sh
    pip install pygtail
        
    # ! check MAILLOG path in zabbix_postfix_passive.sh
    # ! check path for pygtail executable
    cp zabbix_postfix_passive.sh /usr/local/sbin/
    chmod +x /usr/local/sbin/zabbix_postfix_passive.sh

    #Check for right config-path of zabbix-agent
    cp zabbix_postfix_passive.conf /etc/zabbix/zabbix_agentd.d/
    
    # run visudo as root
    zabbix ALL=(ALL) NOPASSWD: /usr/local/sbin/zabbix_postfix_passive.sh
    
    systemctl restart zabbix-agent

Now download the template_postfix_passive.xml, import it into zabbix and attach it to your host. 
To see if everything works fine, wait a few minutes, go to the latest data of your host and search for 'postfix'. The line 'Postfix data update request' should show the error if there is one.
