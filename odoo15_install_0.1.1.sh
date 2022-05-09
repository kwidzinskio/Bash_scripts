#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                         Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of installing two separatelly Odoo's instances
# There are create two python virtual environment.
# Packages required by Odoo (python modules) are installing using pip based on file requirements.txt becomes from git sources.

#-----------------------------------------------------------------------------------------------------------
#                                             Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to server:
# scp odoo15_install_0.1.1.sh user@192.168.0.12:~/
# Make the file executable:
# sudo chmod +x odoo15_install_0.1.1.sh
# Execute the script to install Odoo:
# sudo ./odoo15_install_0.1.1.sh

#-----------------------------------------------------------------------------------------------------------
#                                             Script version
#-----------------------------------------------------------------------------------------------------------

# version  0.1.0 [2022-01-14]
# version 0.1.1 [2022-02-08]
# during installing missing python packages 
# were added: paramiko
# were deleted: passlib, PyPDF2, lxml, polib, pillow, werkzeug, python-dateutil, psutil==5.6.6, Jinja2, reportlab, psycopg2, greenlet==0.4.15, gevent==1.5.0, libsass, python-ldap, python-stdnum

#-----------------------------------------------------------------------------------------------------------
#                                      Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_NAME="odoo15_install_0.1.1.sh"
SCRIPT_VERSION="0.1.1"
SCRIPT_AUTHOR="Oskar Kwidziński"

# odooprod - production environment
# odootest - test environment
OE_P_USER="odooprod"
OE_T_USER="odootest"
OE_P_HOME="/$OE_P_USER"
OE_T_HOME="/$OE_T_USER"
OE_P_HOME="/$OE_P_USER"
OE_T_HOME="/$OE_T_USER"
OE_P_HOME_EXT="/$OE_P_USER/${OE_P_USER}-server"
OE_T_HOME_EXT="/$OE_T_USER/${OE_T_USER}-server"

# The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
# Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"

# Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)
OE_P_PORT="8069"
OE_T_PORT="8569"

# Set the superadmin password
OE_SUPERADMIN="admin"
OE_P_CONFIG="${OE_P_USER}-server"
OE_T_CONFIG="${OE_T_USER}-server"

# Set Odoo version
ENTERPRISE="N"
OE_VERSION="15.0"

###  WKHTMLTOPDF download links
## === Ubuntu Bionic x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltox installed, for a danger note refer to 
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb
WKHTMLTOX_X32=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_i386.deb

UPDATE="y"

#-----------------------------------------------------------------------------------------------------------
#                                              Script launch
#-----------------------------------------------------------------------------------------------------------

echo -e "\n=============================================================================="
echo "                             Launch: ${SCRIPT_NAME}                "
echo "                              version ${SCRIPT_VERSION}            "
echo "                            $(date +"%Y.%m.%d %H:%M:%S")             "
echo "                          Created by: ${SCRIPT_AUTHOR}            "
echo -e "==============================================================================\n"

echo -e "\n**************************************************************************"
echo -e ">                              SERVER UPDATE                    "
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

sudo apt-get -y install mc 

echo -e "\n**************************************************************************"
echo -e ">	                           UPDATE LOCALE "
echo -e "**************************************************************************\n"

sudo apt-get install locales
sudo locale-gen "en_US.UTF-8"
sudo locale-gen "pl_PL.UTF-8"
sudo dpkg-reconfigure --frontend=noninteractive locales
sudo apt-get install language-pack-pl -y
sudo update-locale LANG="pl_PL.UTF-8"
locale
sleep 1

#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------

echo -e "\n**************************************************************************"
echo -e ">	                      INSTALL POSTRESQL SERVER "
echo -e "**************************************************************************\n"

sudo apt-get install postgresql -y
sleep 1

echo -e "\n**************************************************************************"
echo -e ">                    CREATING THE ODOO POSTGRESQL USERS  "
echo -e "**************************************************************************\n"

sudo su - postgres -c "createuser -s $OE_P_USER" 2> /dev/null || true
sudo su - postgres -c "createuser -s $OE_T_USER" 2> /dev/null || true
sleep 1

echo -e "\n**************************************************************************"
echo -e ">	                INSTALLING PYTHON 3 + pip3 + virtualenv"
echo -e "**************************************************************************\n"

sudo apt-get install -y python3 python3-pip python3-dev python3-venv python3-wheel python3-setuptools virtualenv libpq-dev zlib1g-dev libxslt-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev libjpeg-dev 
sleep 1

echo -e "\n**************************************************************************"
echo -e ">	                        INSTALL TOOL PACKAGES "
echo -e "**************************************************************************\n"

sudo apt-get install -y wget git bzr gdebi-core xz-utils fontconfig libfreetype6 libx11-6 libxext6 libxrender1 xfonts-75dpi
sleep 1

echo -e "\n**************************************************************************"
echo -e ">	                    INSTALL OTHER REQUIRED PACKAGES"
echo -e "**************************************************************************\n"

sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install -y gcc libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libssl1.0-dev libldap2-dev libpq-dev libpng-dev libjpeg-dev build-essential libxslt-dev libzip-dev libffi-dev
sleep 1

# Install Wkhtmltopdf if needed
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then

  echo -e "\n**************************************************************************"
  echo -e ">	INSTALL WKHTML AND PLACE SHORTCUTS ON CORRECT PLACE FOR ODOO 15 "
  echo -e "**************************************************************************\n"

  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then

      _url=$WKHTMLTOX_X64

  else

      _url=$WKHTMLTOX_X32

  fi

  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/binpython

else

  echo "Wkhtmltopdf isn't installed due to the choice of the user!"

fi

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	                    CREATE ODOO SYSTEM USERS"
echo -e "**************************************************************************\n"

if grep "odoo:" /etc/passwd >/dev/null 2>&1; then

	echo -e "User odoo exists ."

else

	echo -e "Create missing user odoo ."
	sudo adduser --system --quiet --shell=/bin/bash --home=/odoo --gecos 'ODOO' --group odoo
	sudo adduser odoo sudo

fi

sleep 1

sudo adduser --system --quiet --shell=/bin/bash --home=$OE_P_HOME --gecos 'ODOO' --group $OE_P_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_P_USER sudo

sudo adduser --system --quiet --shell=/bin/bash --home=$OE_T_HOME --gecos 'ODOO' --group $OE_T_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_T_USER sudo

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	                       CREATE LOG DIRECTORY "
echo -e "**************************************************************************\n"

sudo mkdir /var/log/$OE_P_USER
sudo chown $OE_P_USER:$OE_P_USER /var/log/$OE_P_USER

sudo mkdir /var/log/$OE_T_USER
sudo chown $OE_T_USER:$OE_T_USER /var/log/$OE_T_USER

if [ ! -d "$OE_P_HOME" ]; then

	echo -e ">	Create missing directory : $OE_P_HOME "
	sudo mkdir $OE_P_HOME

fi

if [ ! -d "$OE_T_HOME" ]; then

	echo -e ">	Create missing directory : $OE_T_HOME "
	sudo mkdir $OE_T_HOME

fi

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	                       INSTALL ODOO "
echo -e "**************************************************************************\n"

echo -e "**************************************************************************"
echo -e ">	       CREATE ENVIRONMENT FOF $OE_P_USER  :: Git clonning ..."
echo -e "**************************************************************************\n"

sleep 1

sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/odoo $OE_P_HOME_EXT/

if [ $ENTERPRISE = "T" ]; then
    # Odoo Enterprise install!
    echo -e "\n--- Create symlink for node"
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo mkdir $OE_P_HOME/enterprise
    sudo mkdir $OE_P_HOME/enterprise/addons
	
	sudo mkdir $OE_T_HOME/enterprise
    sudo mkdir $OE_T_HOME/enterprise/addons

   GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/enterprise "$OE_P_HOME/enterprise/addons" 2>&1)

    while [[ $GITHUB_RESPONSE == *"Authentication"* ]]; do

        echo "------------------------WARNING------------------------------"
        echo "Your authentication with Github has failed! Please try again."
        printf "In order to clone and install the Odoo enterprise version you \nneed to be an offical Odoo partner and you need access to\nhttp://github.com/odoo/enterprise.\n"
        echo "TIP: Press ctrl+c to stop this script."
        echo "-------------------------------------------------------------"
        echo " "
        GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/enterprise "$OE_P_HOME/enterprise/addons" 2>&1)

    done

    echo -e "\n---- Added Enterprise code under $OE_HOME/enterprise/addons ----"
    echo -e "\n---- Installing Enterprise specific libraries ----"
   
    sudo apt-get install nodejs npm
    sudo npm install -g less
    sudo npm install -g less-plugin-clean-css

fi

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	        DUPLICATE ENVIRONMENT $OE_P_USER  ===> $OE_T_USER "
echo -e "**************************************************************************\n"

sudo cp -a $OE_P_HOME_EXT/. $OE_T_HOME_EXT/
if [ $ENTERPRISE = "T" ]; then
	sudo cp -a $OE_P_HOME/enterprise/addons/. $OE_T_HOME/enterprise/addons
fi

sleep 1

echo -e "**************************************************************************"
echo -e ">	                CREATE CUSTOM MODULE DIRECTORY "
echo -e "**************************************************************************\n"

sudo mkdir $OE_P_HOME/custom
sudo mkdir $OE_P_HOME/custom/addons

sudo mkdir $OE_T_HOME/custom
sudo mkdir $OE_T_HOME/custom/addons

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	  SETTING PERMISSIONS ON HOME FOLDERS :$OE_P_HOME and $OE_T_HOME "
echo -e "**************************************************************************\n"

sudo chown -R $OE_P_USER:$OE_P_USER $OE_P_HOME
sudo chown -R $OE_T_USER:$OE_T_USER $OE_T_HOME

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	     CREATE SERVER CONFIG FILE FOR $OE_P_USER user/service "
echo -e "**************************************************************************\n"

sudo rm /etc/${OE_P_CONFIG}.conf
sudo touch /etc/${OE_P_CONFIG}.conf

sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${OE_P_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = ${OE_SUPERADMIN}\n' >> /etc/${OE_P_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_port = ${OE_P_PORT}\n' >> /etc/${OE_P_CONFIG}.conf"
sudo su root -c "printf 'logfile = /var/log/${OE_P_USER}/${OE_P_CONFIG}.log\n' >> /etc/${OE_P_CONFIG}.conf"

sleep 1

if [ $ENTERPRISE = "T" ]; then

	sudo su root -c "printf 'addons_path=${OE_P_HOME_EXT}/addons,${OE_P_HOME}/enterprise/addons,${OE_P_HOME}/custom/addons\n' >> /etc/${OE_P_CONFIG}.conf"

else

	sudo su root -c "printf 'addons_path=${OE_P_HOME_EXT}/addons,${OE_P_HOME}/custom/addons\n' >> /etc/${OE_P_CONFIG}.conf"

fi

sudo chown $OE_P_USER:$OE_P_USER /etc/${OE_P_CONFIG}.conf
sudo chmod 640 /etc/${OE_P_CONFIG}.conf

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	     CREATE SERVER CONFIG FILE FOR $OE_T_USER user/service"
echo -e "**************************************************************************\n"

sudo rm /etc/${OE_T_CONFIG}.conf
sudo touch /etc/${OE_T_CONFIG}.conf

sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${OE_T_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = ${OE_SUPERADMIN}\n' >> /etc/${OE_T_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_port = ${OE_T_PORT}\n' >> /etc/${OE_T_CONFIG}.conf"
sudo su root -c "printf 'logfile = /var/log/${OE_T_USER}/${OE_T_CONFIG}.log\n' >> /etc/${OE_T_CONFIG}.conf"

if [ $ENTERPRISE = "T" ]; then

	sudo su root -c "printf 'addons_path=${OE_T_HOME_EXT}/addons,${OE_T_HOME}/enterprise/addons,${OE_T_HOME}/custom/addons\n' >> /etc/${OE_T_CONFIG}.conf"

else

	sudo su root -c "printf 'addons_path=${OE_T_HOME_EXT}/addons,${OE_T_HOME}/custom/addons\n' >> /etc/${OE_T_CONFIG}.conf"

fi

sudo chown $OE_T_USER:$OE_T_USER /etc/${OE_T_CONFIG}.conf
sudo chmod 640 /etc/${OE_T_CONFIG}.conf

sleep 1

echo -e "\n**************************************************************************"
#echo -e ">	Create python virtual environment ===> $OE_P_HOME_EXT/env_$OE_P_USER  "
echo -e ">	CREATE PYTHON VIRTUAL ENVIRONMENT ===> $OE_P_HOME/env_$OE_P_USER  "
echo -e "**************************************************************************\n"

#sudo su $OE_P_USER -c "virtualenv -p python3 $OE_P_HOME_EXT/env_$OE_P_USER "
sudo su $OE_P_USER -c "virtualenv -p python3 $OE_P_HOME/env_$OE_P_USER "

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	INSTALLING PYTHON PACKAGES USING PIP FROM : $OE_P_HOME_EXT/requirements.txt \n"
echo -e ">	cd $OE_P_HOME/env_$OE_P_USER/bin && $OE_P_HOME/env_$OE_P_USER/bin/python pip3 install -r $OE_P_HOME_EXT/requirements.txt"
echo -e "**************************************************************************\n"

sudo su $OE_P_USER -c "cd $OE_P_HOME/env_$OE_P_USER/bin && $OE_P_HOME/env_$OE_P_USER/bin/python pip3 install -r $OE_P_HOME_EXT/requirements.txt"

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	        INSTALLING MISSING PYTHON PACKAGES USING PIP "
echo -e "**************************************************************************\n"

sudo su $OE_P_USER -c "cd $OE_P_HOME/env_$OE_P_USER/bin && $OE_P_HOME/env_$OE_P_USER/bin/python pip3 install phonenumbers html2text paramiko "

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	CREATE PYTHON VIRTUAL ENVIRONMENT ===> $OE_T_HOME/env_$OE_T_USER \n"
echo -e "**************************************************************************\n"

sudo su $OE_T_USER -c "virtualenv -p python3 $OE_T_HOME/env_$OE_T_USER "

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	INSTALLING PYTHON PACKAGES USING PIP FROM : $OE_T_HOME_EXT/requirements.txt \n"
echo -e ">	cd $OE_T_HOME/env_$OE_T_USER/bin && $OE_T_HOME/env_$OE_T_USER/bin/python pip3 install -r $OE_T_HOME_EXT/requirements.txt"
echo -e "**************************************************************************\n"

sudo su $OE_T_USER -c "cd $OE_T_HOME/env_$OE_T_USER/bin && $OE_T_HOME/env_$OE_T_USER/bin/python pip3 install -r $OE_T_HOME_EXT/requirements.txt"

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	        INSTALLING MISSING PYTHON PACKAGES USING PIP "
echo -e "**************************************************************************\n"

sudo su $OE_T_USER -c "cd $OE_T_HOME/env_$OE_T_USER/bin && $OE_T_HOME/env_$OE_T_USER/bin/python pip3 install phonenumbers html2text paramiko"

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	CREATING SERVICE CONFIG FILE FOR SERVICE: ${OE_P_CONFIG}.service"
echo -e "**************************************************************************\n"

sudo rm /lib/systemd/system/${OE_P_CONFIG}.service
sudo touch /lib/systemd/system/${OE_P_CONFIG}.service
sudo su root -c "printf '[Unit] \nDescription = Odoo${OE_VERSION}-${OE_P_USER}  \n' >> /lib/systemd/system/${OE_P_CONFIG}.service"
sudo su root -c "printf 'Requires=postgresql.service\nAfter=postgresql.service\n' >>  /lib/systemd/system/${OE_P_CONFIG}.service"
sudo su root -c "printf '[Service] \nType=simple\nPermissionsStartOnly=true\nUser=${OE_P_USER}\nGroup=odoo\nSyslogIdentifier=Odoo${OE_VERSION}-${OE_P_USER}\n' >> /lib/systemd/system/${OE_P_CONFIG}.service"
sudo su root -c "printf 'ExecStart=$OE_P_HOME/env_$OE_P_USER/bin/python3 $OE_P_HOME_EXT/odoo-bin -c /etc/${OE_P_CONFIG}.conf \n' >> /lib/systemd/system/${OE_P_CONFIG}.service"
sudo su root -c "printf '[Install]\nWantedBy=multi-user.target\n' >> /lib/systemd/system/${OE_P_CONFIG}.service"
sudo chmod 640 /lib/systemd/system/${OE_P_CONFIG}.service

sleep 1

echo -e "\n**************************************************************************"
echo -e "> REGISTRATION SERVICE ===> ${OE_P_CONFIG}.service [file location : /lib/systemd/system/${OE_P_CONFIG}.service] "
echo -e "**************************************************************************\n"

sudo systemctl enable ${OE_P_CONFIG}.service
sudo systemctl start ${OE_P_CONFIG}.service

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	CREATING SERVICE CONFIG FILE FOR SERVICE: ${OE_T_CONFIG}.service"
echo -e "**************************************************************************\n"

sudo rm /lib/systemd/system/${OE_T_CONFIG}.service
sudo touch /lib/systemd/system/${OE_T_CONFIG}.service
sudo su root -c "printf '[Unit] \nDescription = Odoo${OE_VERSION}-${OE_T_USER}  \n' >> /lib/systemd/system/${OE_T_CONFIG}.service"
sudo su root -c "printf 'Requires=postgresql.service\nAfter=postgresql.service\n' >> /lib/systemd/system/${OE_T_CONFIG}.service"
sudo su root -c "printf '[Service] \nType=simple\nPermissionsStartOnly=true\nUser=${OE_T_USER}\nGroup=odoo\nSyslogIdentifier=Odoo${OE_VERSION}-${OE_T_USER}\n' >> /lib/systemd/system/${OE_T_CONFIG}.service"
sudo su root -c "printf 'ExecStart=$OE_T_HOME/env_$OE_T_USER/bin/python3 $OE_T_HOME_EXT/odoo-bin -c /etc/${OE_T_CONFIG}.conf \n' >> /lib/systemd/system/${OE_T_CONFIG}.service"
sudo su root -c "printf '[Install]\nWantedBy=multi-user.target\n' >> /lib/systemd/system/${OE_T_CONFIG}.service"
sudo chmod 640 /lib/systemd/system/${OE_T_CONFIG}.service

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	REGISTRATION SERVICE ===> ${OE_T_CONFIG}.service [file location : /lib/systemd/system/${OE_T_CONFIG}.service] "
echo -e "**************************************************************************\n"

sudo systemctl enable ${OE_T_CONFIG}.service
sudo systemctl start ${OE_T_CONFIG}.service

#-----------------------------------------------------------------------------------------------------------
#                                           End of script
#-----------------------------------------------------------------------------------------------------------

sleep 1

echo -e "\n**************************************************************************"
echo -e ">                               END OF SCRPIT       "
echo -e "**************************************************************************\n"

echo -e "Instalation was finished on $(date +"%Y.%m.%d %H:%M:%S")" 

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	Service ${OE_P_CONFIG}.service status "
echo -e "**************************************************************************\n"

sudo systemctl status ${OE_P_CONFIG}.service

echo -e "\n**************************************************************************"
echo "Done! The Odoo production server is up and running. Specifications:"
echo "Port: $OE_P_PORT"
echo "User service: $OE_P_USER"
echo "User PostgreSQL: $OE_P_USER"
echo "Code location: $OE_P_USER"
echo "Addons folder: $OE_P_USER/$OE_P_CONFIG/addons/"
echo "Start Odoo service: sudo systemctl start $OE_P_CONFIG.service "
echo "Stop Odoo service: sudo systemctl stop $OE_P_CONFIG.service "
echo -e "Restart Odoo service: sudo systemctl restart $OE_P_CONFIG.service\n"	

sleep 1

echo -e "\n**************************************************************************"
echo -e ">	Service ${OE_T_CONFIG}.service status "
echo -e "**************************************************************************\n"

sudo systemctl status ${OE_T_CONFIG}.service

sleep 1

echo -e "\n**************************************************************************"
echo "Done! The Odoo test server is up and running. Specifications:"
echo "Port: $OE_T_PORT"
echo "User service: $OE_T_USER"
echo "User PostgreSQL: $OE_T_USER"
echo "Code location: $OE_T_USER"
echo "Addons folder: $OE_T_USER/$OE_T_CONFIG/addons/"
echo "Start Odoo service: sudo systemctl start $OE_T_CONFIG.service "
echo "Stop Odoo service: sudo systemctl stop $OE_T_CONFIG.service "
echo -e "Restart Odoo service: sudo systemctl restart $OE_T_CONFIG.service\n "

sleep 1

echo "* To verify odooprod database, run the command: *"
echo -e "sudo systemctl status ${OE_P_CONFIG}.service\n"

echo "* To verify odootest database, run the command: *"
echo -e "sudo systemctl status ${OE_T_CONFIG}.service\n"

echo "* To restart odooprod database, run the command: *"
echo -e "sudo systemctl restart ${OE_P_CONFIG}-server.service\n"

echo "* To restart odooprod database, run the command: *"
echo -e "sudo systemctl restart ${OE_T_CONFIG}-server.service\n"













