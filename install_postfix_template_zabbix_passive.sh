#!/usr/bin/env bash
. ./lib/tech.sh
## Variables

# visual stuff
COL_ESCAPE="\033[0m"
GREEN="\033[30;32m"
RED="\033[30;31m"
ERR_HIGHLIGHT="\033[1;37;101m"
OK_HIGHLIGHT="\033[1;30;102m"
INFO_HIGHLIGHT="\033[1;30;104m"

# text & art
BANNER_FILE="./lib/banner.txt"

clear
echo -e $RED
cat $BANNER_FILE
echo "https://kreibich.xyz/ - Open Source projects"
echo "https://github.com/Kreibich-xyz/zabbix-postfix-integration"
echo "Help and Support on info@kreibich.xyz"
echo -e $COL_ESCAPE
echo -e $INFO_HIGHLIGHT
echo "................................................................................"
echo ". zabbix-postfix-integration is maintained by Kreibich.xyz OpenSource-Projects ."
echo ". Original Credits go to GitHub/kstka and http://admin.shamot.cz/?p=424        ."
echo "................................................................................"
echo -e $COL_ESCAPE

while true; do
    read -p "Do you wish to install postfix-integration for zabbix? (Y/n) " yn
    case $yn in
        [Yy]* ) echo -e "Starting install process."; break;;
        [Nn]* ) echo -e "\n";echo -e $ERR_HIGHLIGHT"You aborted the installation process.\nGoodbye." $COL_ESCAPE "\n\n"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [[ `id -u` -ne 0 ]] ; then echo -e "\n";echo -e $ERR_HIGHLIGHT"ERROR: Please run the installer-script as root!\nExiting." $COL_ESCAPE "\n\n" ; exit 1 ; fi

echo -e "\nChecking for dependencies..."

echo -n "Checking for python3. "
python_avl=$(checkforDep "python3")
if [ $python_avl -eq 0 ]; then
echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
echo -e "["$RED"MISSING"$COL_ESCAPE"]"
fi

echo -n "Checking for pip3. "
pip_avl=$(checkforDep "pip3")
if [ "$pip_avl" -eq 0 ];
then
echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
echo -e "["$RED"MISSING"$COL_ESCAPE"]"
fi

echo -n "Checking for pflogsumm. "
pflsumm_avl=$(checkforDep "pflogsumm")
if [ $pflsumm_avl -eq 0 ]; then 
echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
echo -e "["$RED"MISSING"$COL_ESCAPE"]"
fi

echo -n "Checking for pygtail. "
pygtail_avl=$(checkforDep "pygtail")
if [ $pygtail_avl -eq 0 ]; then
echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
echo -e "["$RED"MISSING"$COL_ESCAPE"]"
fi

mis_sys_dep_sum=$(( $python_avl + $pip_avl + $pflsumm_avl ))

if [ $mis_sys_dep_sum -gt 0 ]; then
    echo -e $RED"Detected missing system dependencies."$COL_ESCAPE
    
    # Support for apt-get
    if [ -x "$(command -v apt-get)" ]; then
        while true; do
            read -p "It seems like you're using apt as package manager. Do you want to install missing Dependencies via apt? (Y/n) " yn
            case $yn in
                [Yy]* ) installDepsAPT;break;;
                [Nn]* ) echo -e "\n";echo -e $ERR_HIGHLIGHT"Please manually install all Dependencies an re-run the script.\nGoodbye." $COL_ESCAPE "\n\n"; exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        echo -e "\n";echo -e $ERR_HIGHLIGHT"You don't have a supported package manager installed. Please install the missing dependencies manually an re-run the script. \n Goodbye." $COL_ESCAPE "\n\n"
        exit 1
    fi

    #TODO Add Support for more package managers
fi

if [ $pygtail_avl -gt 0 ]; then
    echo -e "Detected missing python-dependencies."

    if [ -x "$(command -v pip3)" ]; then
        while true; do
            read -p "You have pip3 installed. Do you want to install missing python-dependencies via pip? (Y/n) " yn
            case $yn in
                [Yy]* ) installDepsPIP;break;;
                [Nn]* ) echo -e "\n";echo -e $ERR_HIGHLIGHT"Please manually install pygtail and add enter the executable-path in the next step. You can stop and re-run the script to do this." $COL_ESCAPE "\n\n"; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        echo -e "\n"
        echo -e $ERR_HIGHLIGHT"It seems like you don't have pip installed. Please manually install pygtail and add enter the executable-path in the next step. You can stop and re-run the script to do this."$COL_ESCAPE"\n\n"
    fi
fi

if [ -x "$(command -v pygtail)" ]; then
echo -e "Found pygtail executabe."
else
    echo -e "The pygtail executable is not specified in path. Please provide the path to the pygtail-executable."
    read -p "Path to pygtail: " pigpath
    while true; do
        if [ -x ! "(command -v $pigpath)" ]; then
            echo -e $RED"The path you provided is incorrect. "$COL_ESCAPE
            read -p "Path to pygtail: " pigpath
        else
            echo -e "Found pygtail executabe."
            break
        fi
    done
fi

echo -e $OK_HIGHLIGHT"\nFinished installing dependencies.\n\n"$COL_ESCAPE

echo -e "Installing scripts and config-files."
echo -n "Install /usr/bin/zabbix-postfix-stats.sh"
if cp ./lib/install/zabbix-postfix-stats.sh /usr/bin/ && chmod +x /usr/bin/zabbix-postfix-stats.sh; then
    echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
    echo -e "["$RED"FAILED"$COL_ESCAPE"]"
    echo -e "\n"
    echo -e $ERR_HIGHLIGHT"Could not install file. Please check file-permissions or use the manual installation."$COL_ESCAPE
    echo -e "\n\n"
    exit 1
fi

# Check for zabbix config-dir
if [ -d "/etc/zabbix/zabbix_agentd.conf.d/" ]; then
    zbx_conf_dir="/etc/zabbix/zabbix_agentd.conf.d"
    echo -e "Found zabbix configuration directory: "$zbx_conf_dir
elif [ -d "/etc/zabbix/zabbix_agentd.d/" ]; then
    zbx_conf_dir="/etc/zabbix/zabbix_agentd.d/"
    echo -e "Found zabbix configuration directory: "$zbx_conf_dir
else
    echo -e $ERR_HIGHLIGHT"Error finding zabbix-agent configuration directory. Please copy userparameter_postfix.conf manually."$COL_ESCAPE
fi

if ! [[ -z "$zbx_conf_dir" ]] ; then
    echo -n "Install $zbx_conf_dir userparameter_postfix.conf"
    if cp ./lib/install/userparameter_postfix.conf $zbx_conf_dir; then
        echo -e "["$GREEN"OK"$COL_ESCAPE"]"
    else
        echo -e "["$RED"FAILED"$COL_ESCAPE"]"
        echo -e "\n"
        echo -e $ERR_HIGHLIGHT"Could not install file. Please check file-permissions or use the manual installation."$COL_ESCAPE
        echo -e "\n\n"
        exit 1
    fi
fi

echo -n "Setting user privileges."
if echo -e '#Created by zabbix-postfix-integration installer script\nzabbix ALL=(ALL) NOPASSWD: /usr/bin/zabbix-postfix-stats.sh' | EDITOR='tee -a' visudo > ./visudo.log; then
    echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
    echo -e "["$RED"FAILED"$COL_ESCAPE"]"
    echo -e "\n"
    echo -e $ERR_HIGHLIGHT"Could set user privileges. Please use the manual installation."$COL_ESCAPE
    echo -e "\n\n"
    exit 1
fi

echo -n "Restarting zabbix-agent"
if systemctl restart zabbix-agent; then
    echo -e "["$GREEN"OK"$COL_ESCAPE"]"
else
    echo -e "["$RED"FAILED"$COL_ESCAPE"]"
    echo -e "\n"
    echo -e $ERR_HIGHLIGHT"There was an Error restarting zabbix-agent. Please try to manually fix this error. \n If the Error persists, please feel free to contact us."$COL_ESCAPE
    echo -e "\n\n"
    exit 1
fi

echo -e "\n\n"
echo -e $OK_HIGHLIGHT"Installation done. Please check zabbix for receiving correct data like shown in the installation menu. \n Goodbye."$COL_ESCAPE"\n\n"

exit 1