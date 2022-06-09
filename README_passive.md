# zabbix-postfix-template
Zabbix template for Postfix SMTP server

Tested on zabbix 5.4.3 and Python3

originally orked from http://admin.shamot.cz/?p=424 , I forked it from kstka/zabbix-postfix-template

# Requirements
* [pflogsum](http://jimsun.linxnet.com/postfix_contrib.html)
* [pygtail](https://pypi.org/project/pygtail/)

# Using Installer
Before using the installer, make sure you have your zabbix-agent installed, set up and checked the connection to the zabbix-server!

    # Clone Repo
    git clone https://github.com/Kreibich-xyz/zabbix-postfix-integration/
    
    cd zabbix-postfix-integration
    
    # Make sure, you run the script as root!
    chmod +x ./install.sh
    ./install.sh
    
    # Now follow the instructions in the script.
    # If the script runs into a problem, fall back to the corrosponding step in Manual Installation and report the error and some system-information to info@kreibich.xyz.
   
Now download the template_app_zabbix.xml, import it into zabbix and attach it to your host. 
To see if everything works fine, wait a few minutes, go to the latest data of your host and search for 'postfix'. The line 'Postfix data update request' should show the error if there is one.

# Manual Installation
    # for Ubuntu / Debian
    apt-get install pflogsumm
    
    # for CentOS
    yum install postfix-perl-scripts
    
    # install pygtail using pip
    # alternatively you can manually install pygtail and specify the executable-path in zabbix-postfix-status.sh
    pip install pygtail
    
    #Change into installation-directory
    cd ./lib/install/
    
    # ! check MAILLOG path in zabbix-postfix-stats.sh
    # ! check path for pygtail executable
    cp zabbix-postfix-stats.sh /usr/bin/
    chmod +x /usr/bin/zabbix-postfix-stats.sh

    #Check for right config-path of zabbix-agent
    cp userparameter_postfix.conf /etc/zabbix/zabbix_agentd.d/
    
    # run visudo as root
    zabbix ALL=(ALL) NOPASSWD: /usr/bin/zabbix-postfix-stats.sh
    
    systemctl restart zabbix-agent

Now download the template_app_zabbix.xml, import it into zabbix and attach it to your host. 
To see if everything works fine, wait a few minutes, go to the latest data of your host and search for 'postfix'. The line 'Postfix data update request' should show the error if there is one.
