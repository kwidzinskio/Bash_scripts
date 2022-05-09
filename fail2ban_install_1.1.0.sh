#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                     Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of installing fail2ban service on Odoo servers with nginx service
# All required packages are installed via Advanced Packaging Tool - using apt-get command

#-----------------------------------------------------------------------------------------------------------
#                                                Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp fail2ban_install_1.1.0.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x fail2ban_install_1.1.0.sh
# Execute the file:
# sudo ./fail2ban_install_1.1.0.sh

#-----------------------------------------------------------------------------------------------------------
#                                               Script version
#-----------------------------------------------------------------------------------------------------------

# version 1.0 [2021-08-23]
# version 1.1.0 [2022-01-14]
# automatic 'is nginx installed' check

#-----------------------------------------------------------------------------------------------------------
#                                       Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_NAME="fail2ban_install_1.1.0.sh"
SCRIPT_VERSION="1.1.0"
SCRIPT_AUTHOR="Oskar Kwidziński"

NGINX_RESPONSE=$(systemctl is-active nginx)
NGINX_STATEMENT="active"
UPDATE=y
MAXRETRY=666
BANTIME=666m

#-----------------------------------------------------------------------------------------------------------
#                                              Script launch
#-----------------------------------------------------------------------------------------------------------

echo -e "\n=============================================================================="
echo "                      Launch: ${SCRIPT_NAME}                "
echo "                              version ${SCRIPT_VERSION}            "
echo "                            $(date +"%Y.%m.%d %H:%M:%S")             "
echo "                          Created by: ${SCRIPT_AUTHOR}            "
echo -e "==============================================================================\n"

echo -e "**************************************************************************"
echo -e ">                             SERVER UPDATE                    "
echo -e "**************************************************************************\n"

# server update
while [ $UPDATE != n ] && [ $UPDATE != N ]; do

    read -p "Do you want to update UNIX packages? (y/n) " UPDATE

    if [ "$UPDATE" == "y" ] || [ $UPDATE == Y ]  ; then
	    sudo apt update -y && sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get upgrade -y && sudo apt dist-upgrade -y && sudo apt-get dist-upgrade -y
            sudo apt-get autoremove -y
            UPDATE=n
    fi

done

#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------



# fail2ban installation
installation () {

    # installation
    sudo apt-get install fail2ban -y
    sleep 1
    echo -e "\n* Fail2ban has been installed *"

    # jail.local creation
    echo -e "\n**************************************************************************"
    echo -e ">                     COPYING jail.conf -> jail.local "
    echo -e "**************************************************************************\n"
    
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    sleep 1    
    echo "* jail.conf has been copied to jail.local *"

    # jail.local configuration
    echo -e "\n**************************************************************************"
    echo -e ">                    CREATING CONF FILE FOR SSH BANNING  "
    echo -e "**************************************************************************\n"

    echo -e "[sshd]\nenabled = true\nport = ssh\naction = iptables-multiport\nlogpath = /var/log/secure\nmaxretry = 5\nbantime = 600" > /etc/fail2ban/filter.d/sshd.local
    sed -i 's+logpath = %(sshd_log)s+logpath = /var/log/fail2ban.log+' /etc/fail2ban/jail.local
    sed -i '281 i enabled = true'  /etc/fail2ban/jail.local
    sed -i "s/bantime  = 10m/bantime = ${BANTIME}/" /etc/fail2ban/jail.local
    sed -i "s/maxretry = 3/maxretry = $MAXRETRY/" /etc/fail2ban/jail.local

}



# fail2ban realoading
reloading() {

echo -e "\n**************************************************************************"
echo -e "			       FAIL2BAN RELOADING		    	"
echo -e "**************************************************************************\n"

# realoading
echo -e "* Fail2ban reload: *"
sleep 1
sudo fail2ban-client reload
sleep 1

echo -e "\n* Fail2ban sshd status: *"
sleep 1
sudo fail2ban-client status sshd

echo -e "\n* Fail2ban nginx-http-auth status: *"
sleep 1
sudo fail2ban-client status nginx-http-auth

#-----------------------------------------------------------------------------------------------------------
#                                           End of script
#-----------------------------------------------------------------------------------------------------------

echo -e "\n**************************************************************************"
echo -e ">                               END OF SCRPIT       "
echo -e "**************************************************************************\n"

echo -e "The commands from the script were executed $(date +"%Y.%m.%d %H:%M:%S")\n" 

echo "* To reload fail2ban, run the command: *"
echo -e "fail2ban-client reload\n"

echo "* To show sshd jail status, run the command: *"
echo -e "fail2ban-client status sshd\n"

echo "* To show nginx-http-auth jail status, run the command: *"
echo -e "fail2ban-client status nginx-http-auth\n"

}



# main
echo -e "\n**************************************************************************"
echo -e ">                          FAIL2BAN INSTALLATION "
echo -e "**************************************************************************\n"

# test if nginx is active
echo "Performing nginx test:"
sleep 1
echo -e "$NGINX_RESPONSE\n"

# nginx is active
if [[ ${NGINX_RESPONSE} == ${NGINX_STATEMENT} ]];then
 
    installation

    # jail.local configuration for active nginx
    sed -i '381 i enabled = true'  /etc/fail2ban/jail.local
	sed -i '382 i filter = nginx-http-auth' /etc/fail2ban/jail.local
    sed -i 's+logpath = %(nginx_error_log)s+path = /var/log/nginx/error.log+' /etc/fail2ban/jail.local
    sleep 1    
    echo "* conf files have been created *"
    
    reloading

# nginx inactive
else

    read -p "Nginx is not cofigured or is not working properly. Do you want to continue? (y/n) " NGINX_CONTINUE

    # continue
    if [ $NGINX_CONTINUE == "y" || $NGINX_CONTINUE == "Y" ]; then
       
        installation
        
        sleep 1
        echo "\n* conf files have been created *"

        reloading
    
    # leave the game
    else
        echo -e "\n**************************************************************************"
        echo -e ">                               END OF SCRPIT       "
        echo -e "**************************************************************************\n"

        sleep 1
        echo "Installation script ended unsuccessfuly $(date +"%Y.%m.%d %H:%M:%S")" 
    fi

fi






