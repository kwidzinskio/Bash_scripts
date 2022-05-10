#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                        Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of installing NGINX with SSL certificate for two subdomens       
# Script can either use free SSL certificate from Let's Encrypt or Cloudflare
# In order to perform Cloudflare certification prepare cert.pem and key.pem




#-----------------------------------------------------------------------------------------------------------
#                                           Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp nginx_4.0.1.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x nginx_4.0.1.sh
# Execute the file:
# sudo ./nginx_4.0.1.sh




#-----------------------------------------------------------------------------------------------------------
#                                          Script version
#-----------------------------------------------------------------------------------------------------------

SCRIPT_NAME="nginx_4.0.1.sh"
SCRIPT_VERSION="4.0.1"
SCRIPT_AUTHOR="Oskar Kwidziński"




#-----------------------------------------------------------------------------------------------------------
#                                              Script launch
#-----------------------------------------------------------------------------------------------------------

echo -e "\n=============================================================================="
echo "                           Launch: ${SCRIPT_NAME}                "
echo "                              version ${SCRIPT_VERSION}            "
echo "                            $(date +"%Y.%m.%d %H:%M:%S")             "
echo "                       Created by: ${SCRIPT_AUTHOR}            "
echo -e "=============================================================================="




#-----------------------------------------------------------------------------------------------------------
#                                       Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

UPSTREAM_NAME=""

CONTINUE="y"
while [ $CONTINUE == "y" ] || [ $CONTINUE == "Y" ] ; do

echo -e "\n**************************************************************************"
echo -e "                 INPUTING INTIAL CERTIFICATION SETTINGS               "
echo -e "**************************************************************************"

sleep 1

USER_OPTION="continue"
while [ $USER_OPTION != 1 ] && [ $USER_OPTION != 2 ] && [ $USER_OPTION != q ]; do
	echo -e "\n*** CHOOSE OPERATION ***"
	echo "1 - SSL certificate from Letsencrypt"
	echo "2 - SSL certificate from Cloudflare"
	echo -e "q - cancel\n"
	read -p "Input choice: " USER_OPTION
done

sleep 1
if [ $USER_OPTION == '1' ] || [ $USER_OPTION == '2' ]; then
        echo -e "\n*** Enter your domain: (without www. eg. odoo.com): ***"
        read DOMAIN_NAME
        echo -e "\n*** Enter your production environment subdomain: (eg. odoo. or blank): ***"
        read ENV_P
        echo -e "\n*** Enter your test environment subdomain: (eg. test.): ***"
        read ENV_T
        WWW="Y"

	WWW="continue"
	while [ $WWW != "n" ] && [ $WWW != "y" ] && [ $WWW != "N" ] && [ $WWW != "Y" ]; do
            echo -e "\n*** Are you going to additionally certify the domain with the prefix www? (y/n): "
            read WWW
        done
	
	SERVER_IP_UNFORMATED="$(hostname -I)"
	SERVER_IP=${SERVER_IP_UNFORMATED%% *}
	DOMAIN_T=$(dig +short $ENV_T$DOMAIN_NAME)
	DOMAIN_P=$(dig +short $ENV_P$DOMAIN_NAME)

	IS_DNS_OK="true"

	echo -e "\n**************************************************************************"
	echo "	                     CHECKING DNS IP      "
	echo -e "**************************************************************************"
		
	if [ $USER_OPTION == '1' ]; then
	
		if [ "$DOMAIN_T" == "$SERVER_IP" ]; then
			true
		else
			sleep 1
			echo -e "\n*** $ENV_T$DOMAIN_NAME does not indicate proper ip adress ***\n*** Check your DNS ***\n "
			IS_DNS_OK="n"
		fi		

		if [ "$DOMAIN_P" == "$SERVER_IP" ]; then
			true
		else
			sleep 1
			echo -e "\n*** $ENV_P$DOMAIN_NAME does not indicate proper ip adress ***\n*** Check your DNS ***\n "
			IS_DNS_OK="n"		
		fi
			
		if [ "$WWW" == "y" ] || [ $WWW == Y ]; then
			DOMAIN_T=$(dig +short www.$ENV_T$DOMAIN_NAME)
			DOMAIN_P=$(dig +short www.$ENV_P$DOMAIN_NAME)

			if [ "$DOMAIN_T" == "$SERVER_IP" ]; then
				true
	
			else
				sleep 1
				echo -e "\n*** www.$ENV_T$DOMAIN_NAME does not indicate proper ip adress ***\n*** Check your DNS ***\n "
				IS_DNS_OK="n"			

			fi 
	
			if [ "$DOMAIN_P" == "$SERVER_IP" ]; then
				true
		
			else
				sleep 1
				echo -e "\n*** www.$ENV_P$DOMAIN_NAME does not indicate proper ip adress ***\n*** Check your DNS ***\n "
				IS_DNS_OK="n"
	
			fi

		fi

	elif [ $USER_OPTION == '2' ]; then

			while [ $IS_DNS_OK != 'y' ] && [ $IS_DNS_OK != 'Y' ] && [ $IS_DNS_OK != 'n' ] && [ $IS_DNS_OK != 'N' ]; do
				echo -e "\n*** Are you sure you have provided DNS management in Cloudflare for $DOMAIN_NAME? (y/n) ***"
				read IS_DNS_OK
			done
	fi

else
	echo ""
	exit				

fi

if [ $IS_DNS_OK == "n" ] || [ $IS_DNS_OK == "N" ]; then
	sleep 1
        echo -e "--------------------------------------------------------------------------------------------"
        echo -e "				*** EXITING SCRIPT ***"
        echo -e "--------------------------------------------------------------------------------------------\n"
	sleep 1
	exit
else	
	sleep 1
	echo -e "\n*** ALL ADDRESSES MATCH SERVER IP ***"
	sleep 1
fi
		

if [ $USER_OPTION == '1' ]; then

	echo -e "\n**************************************************************************"
	echo "	                INPUTING EMAIL FOR CERTBOT      "
	echo -e "**************************************************************************"

	sleep 1
	echo -e "\n*** Enter your contact email for the installation of the certbot: "
        read EMAIL_ADDRESS
	echo ""

elif [ $USER_OPTION == '2' ]; then

	echo -e "\n**************************************************************************"
	echo "	                CHECKING KEY.PEM AND CERT.PEM      "
	echo -e "**************************************************************************"
	
	PEM_VALIDATION="true"
    
	sleep 1

	while [ $PEM_VALIDATION != 'y' ] && [ $PEM_VALIDATION != 'Y' ] && [ $PEM_VALIDATION != 'n' ] && [ $PEM_VALIDATION != 'N' ]; do
		echo -e "\n*** Are you sure adequate cloudflare cert.pem and key.pem are located in the same directory as script? (y/n): "
		read PEM_VALIDATION
		sleep 1
	done

	if [ $PEM_VALIDATION == "n" ] || [ $PEM_VALIDATION == "N" ]; then
		sleep 1
        	echo -e "--------------------------------------------------------------------------------------------"
        	echo -e "				*** EXITING SCRIPT ***"
        	echo -e "--------------------------------------------------------------------------------------------\n"
		sleep 1
		exit

	elif [ $PEM_VALIDATION == "y" ] || [ $PEM_VALIDATION == "Y" ]; then

		if [ -f ./cert.pem ] && [ -f ./key.pem ]; then
    			echo -e "\n*** CERT.PEM AND KEY.PEM HAVE BEEN FOUND ***\n"
		
			# cloudflare key.pem and cert.pem validation
			grep -q "KEY" ./key.pem && CDN_KEY_VALID="y" || CDN_KEY_VALID="n" 
			grep -q "CERTIFICATE" ./cert.pem && CDN_CERT_VALID="y" || CDN_CERT_VALID="n" 		
    			sleep 1

	    		if [ $CDN_KEY_VALID == "y" ] && [ $CDN_CERT_VALID == "y" ]; then
        			echo -e "*** BOTH PEM FILES ARE VAILD ***\n"

	    		else
        			echo -e "\n-------------------------------------------------------------------------------------------------"
        			echo -e "				*** ERROR!!! ***"
				echo -e "			*** PEM FILES ARE INVAILD ***"  
        			echo -e "	*** CHECK KEY.PEM AND CERT.PEM DECLARATION FOR CLOUDFLARE CERTIFICATION FIRST ***" 
        			echo -e "			     *** EXITING SCRIPT ***"
        			echo -e "-------------------------------------------------------------------------------------------------\n"
        			sleep 1
        			exit
    			fi

		else
        		echo -e "\n-------------------------------------------------------------------------------------------------"
        		echo -e "					*** ERROR!!! ***"
			echo -e "	*** CLOUDFLARE KEY.PEM AND CERT.PEM MUST BE UPLOADED IN THE SAME DIRECTORY AS SCRIPT ***"   
        		echo -e "		*** UPLOAD KEY.PEM AND CERT.PEM FOR CLOUDFLARE CERTIFICATION FIRST ***" 
        		echo -e "				     *** EXITING SCRIPT ***"
        		echo -e "-------------------------------------------------------------------------------------------------\n"
        		sleep 1
        		exit
    		fi
	fi

else
	exit

fi


sleep 1
echo -e "**************************************************************************"
echo "	    CHECKING ALL .CONF FILES IN NGINX SITES AVAILABLE      "
echo -e "**************************************************************************"

# list all certified domains
if [ -d /etc/nginx/sites-available/ ]; then
	
	sleep 1
	echo -e "\n*** LIST OF ALREADY EXISTING SITES AVAILABLE ***\n"

	for i in $(ls -f /etc/nginx/sites-available/* ); do
        	sleep 0.5 
		echo "$i";
	done

	sleep 1
	echo -e "\n*** Input upstream name for domain that will follow upstream name in nginx website.conf ***\n*** Should be declared in format: _upstreamname: \n*** REMAIN BLANK FOR FIRST DOMAIN! ***\n " 
	read UPSTREAM_NAME
else
	echo -e "\n*** No domains added yet ***" 
fi


sleep 1

if [ $USER_OPTION == '1' ]; then
	SSL_TYPE="_lets"

elif [ $USER_OPTION == '2' ]; then
	SSL_TYPE="_cdn"	
fi


# nginx test statement
NGINX_STATEMENT="active"


# snippets location
LOCATION_SSL_CDN="/etc/nginx/snippets/ssl_cdn.conf"
LOCATION_SSL_LETS="/etc/nginx/snippets/ssl_lets.conf"
LOCATION_LE="/etc/nginx/snippets/letsencrypt.conf"


# ssl snippets
SNIPPETS_SSL='
ssl_dhparam /etc/ssl/certs/dhparam.pem;\r
\r
ssl_session_timeout 1d;\r
ssl_session_cache shared:SSL:10m;\r
ssl_session_tickets off;\r
\r
ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;\r
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;\r
ssl_prefer_server_ciphers on;\r
\r
ssl_stapling on;\r
ssl_stapling_verify on;\r
resolver 8.8.8.8 8.8.4.4 valid=300s;\r
resolver_timeout 30s;\r
\r
add_header Strict-Transport-Security "max-age=15768000; includeSubdomains" always;\r
add_header X-Frame-Options SAMEORIGIN;\r
add_header X-Content-Type-Options nosniff;\r
add_header X-XSS-Protection "1; mode=block";\r
add_header Content-Security-Policy "upgrade-insecure-requests" always;\r
'


# Let's encrypt snippets
SNIPPETS_LE='
location ^~ /.well-known/acme-challenge/ {\r
\t  allow all;\r
\t  root /var/lib/letsencrypt/;\r
\t  default_type "text/plain";\r
\t  try_files $uri =404;\r
}
'


# certbot conf file
CERTBOT_FILE="# /etc/cron.d/certbot: crontab entries for the certbot package\r
# \r
# Upstream recommends attempting renewal twice a day\r
# \r
# Eventually, this will be an opportunity to validate certificates\r
# haven't been revoked, etc.  Renewal will only occur if expiration\r
# is within 30 days.\r
# \r
# Important Note!  This cronjob will NOT be executed if you are\r
# running systemd as your init system.  If you are running systemd,\r
# the cronjob.timer function takes precedence over this cronjob.  For\r
# more details, see the systemd.timer manpage, or use systemctl show\r
# certbot.timer.\r
SHELL=/bin/sh\r
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\r
\r
0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(3600))' && certbot -q renew --renew-hook 'systemctl reload nginx' && sudo certbot renew --force-renewal && sudo systemctl restart nginx\r 
"


# test conf file
TEST_FILE='# Odoo test server\n
upstream odootest'"$UPSTREAM_NAME"' {\n
   \tserver 127.0.0.1:8569;\n
}\n
\n
# Chat Odoo\n
upstream odoo-chat-test'"$UPSTREAM_NAME"' {\n
   \tserver 127.0.0.1:8172;\n
}\n
\n
# HTTP -> HTTPS\n
server {\n
   \tlisten 80;\n
   \tserver_name '"$ENV_T"''"$DOMAIN_NAME"';\n
\n
   \tinclude snippets/letsencrypt.conf;\n
   \treturn 301 https://'"$ENV_T"''"$DOMAIN_NAME"'$request_uri;\n
}\n
\n
# WWW -> NON WWW\n
server {\n
    \tlisten 443 ssl http2;\n
    \tserver_name www.'"$ENV_T"''"$DOMAIN_NAME"';\n
\n
    \tssl_certificate /etc/letsencrypt/live/'"$ENV_T"''"$DOMAIN_NAME"'/fullchain.pem;\n
    \tssl_certificate_key /etc/letsencrypt/live/'"$ENV_T"''"$DOMAIN_NAME"'/privkey.pem;\n
    \tssl_trusted_certificate /etc/letsencrypt/live/'"$ENV_T"''"$DOMAIN_NAME"'/chain.pem;\n
\n
    \tinclude snippets/ssl'"$SSL_TYPE"'.conf;\n
    \tinclude snippets/letsencrypt.conf;\n
\n
    \treturn 301 https://'"$ENV_T"''"$DOMAIN_NAME"'$request_uri;\n
}\n
\n
# IP ADRESS RESTRICTION\n    
#server {\n
#   \tlisten 80;\n
#   \tlisten [::]:80;\n
#   \tserver_name http://'"$ENV_T"''"$DOMAIN_NAME"'$request_uri;\n
#}\n
\n
server {\n
   \tlisten 443 ssl http2;\n
   \tserver_name '"$ENV_T"''"$DOMAIN_NAME"';\n
\n
   \t# Logs\n
   \taccess_log /var/log/nginx/odootest.access.log;\n
   \terror_log /var/log/nginx/odootest.error.log;\n
\n
   \t# Maksymalny plik jaki można przesłać\n
   \tclient_max_body_size 64M;\n
\n
   \t# Parametry szyfrowania SSL i certyfikatów\n
   \tssl_certificate /etc/letsencrypt/live/'"$ENV_T"''"$DOMAIN_NAME"'/fullchain.pem;\n
   \tssl_certificate_key /etc/letsencrypt/live/'"$ENV_T"''"$DOMAIN_NAME"'/privkey.pem;\n
   \tssl_trusted_certificate /etc/letsencrypt/live/'"$ENV_T"''"$DOMAIN_NAME"'/chain.pem;\n
\n
   \tinclude snippets/ssl'"$SSL_TYPE"'.conf;\n
   \tinclude snippets/letsencrypt.conf; \n
\n
   \t# Nagłówki i parametry proxy\n
   \tproxy_read_timeout 720s;\n
   \tproxy_connect_timeout 720s;\n
   \tproxy_send_timeout 720s;\n
   \tproxy_set_header X-Forwarded-Host $host;\n
   \tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n
   \tproxy_set_header X-Forwarded-Proto $scheme;\n
   \tproxy_set_header X-Real-IP $remote_addr;\n
\n
   \tlocation / {\n
        \t\tproxy_redirect off;\n
        \t\tproxy_pass http://odootest'"$UPSTREAM_NAME"';\n
   \t}\n
\n
   \t# Zarządzanie zapytaniami longpoll chatu Odoo\n
   \tlocation /longpolling {\n
       \t\tproxy_pass http://odoo-chat-test'"$UPSTREAM_NAME"';\n
   \t}\n
\n
   \t# Pliki pamięci cache\n
   \tlocation ~* /web/static/ {\n
        \t\tproxy_cache_valid 200 90m;\n
        \t\tproxy_buffering on;\n
        \t\texpires 864000;\n
        \t\tproxy_pass http://odootest'"$UPSTREAM_NAME"';\n
   \t}\n
\n
   \t# Gzip \n
   \tgzip on;\n
   \tgzip_min_length 1100;\n
   \tgzip_buffers 4 32k;\n
   \tgzip_types text/plain text/xml text/css text/less application/x-javascript\n
   \tapplication/xml application/json application/javascript;\n
   \tgzip_vary on;\n
}\n
'


# prod conf file
PROD_FILE='# Odoo production server\n
upstream odooprod'"$UPSTREAM_NAME"' {\n
   \tserver 127.0.0.1:8069;\n
}\n
\n
# Chat Odoo\n
upstream odoo-chat'"$UPSTREAM_NAME"' {\n
   \tserver 127.0.0.1:8072;\n
}\n
\n
# HTTP -> HTTPS\n
server {\n
   \tlisten 80;\n
   \tserver_name '"$ENV_P"''"$DOMAIN_NAME"';\n
\n
   \tinclude snippets/letsencrypt.conf;\n
   \treturn 301 https://'"$ENV_P"''"$DOMAIN_NAME"'$request_uri;\n
}\n
\n
# WWW -> NON WWW\n
server {\n
    \tlisten 443 ssl http2;\n
    \tserver_name www.'"$ENV_P"''"$DOMAIN_NAME"'.pl;\n
\n
    \tssl_certificate /etc/letsencrypt/live/'"$ENV_P"''"$DOMAIN_NAME"'/fullchain.pem;\n
    \tssl_certificate_key /etc/letsencrypt/live/'"$ENV_P"''"$DOMAIN_NAME"'/privkey.pem;\n
    \tssl_trusted_certificate /etc/letsencrypt/live/'"$ENV_P"''"$DOMAIN_NAME"'/chain.pem;\n
\n
    \tinclude snippets/ssl'"$SSL_TYPE"'.conf;\n
    \tinclude snippets/letsencrypt.conf;\n
\n
    \treturn 301 https://'"$ENV_P"''"$DOMAIN_NAME"'$request_uri;\n
}\n
\n
# IP ADRESS RESTRICTION\n    
#server {\n
#        \tlisten 80;\n
#        \tlisten [::]:80;\n
#        \tserver_name http://'"$ENV_P"''"$DOMAIN_NAME"'$request_uri;\n
#}\n
\n
server {\n
   \tlisten 443 ssl http2;\n
   \tserver_name '"$ENV_P"''"$DOMAIN_NAME"';\n
\n
   \t# Logs\n
   \taccess_log /var/log/nginx/odooprod.access.log;\n
   \terror_log /var/log/nginx/odooprod.error.log;\n
\n
   \t# Maksymalny plik jaki można przesłać\n
   \tclient_max_body_size 64M;\n
\n
   \t# Parametry szyfrowania SSL i certyfikatów\n
   \tssl_certificate /etc/letsencrypt/live/'"$ENV_P"''"$DOMAIN_NAME"'/fullchain.pem;\n
   \tssl_certificate_key /etc/letsencrypt/live/'"$ENV_P"''"$DOMAIN_NAME"'/privkey.pem;\n
   \tssl_trusted_certificate /etc/letsencrypt/live/'"$ENV_P"''"$DOMAIN_NAME"'/chain.pem;\n
\n
   \tinclude snippets/ssl'"$SSL_TYPE"'.conf;\n
   \tinclude snippets/letsencrypt.conf; \n
\n
   \t# Nagłówki i parametry proxy\n
   \tproxy_read_timeout 720s;\n
   \tproxy_connect_timeout 720s;\n
   \tproxy_send_timeout 720s;\n
   \tproxy_set_header X-Forwarded-Host $host;\n
   \tproxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n
   \tproxy_set_header X-Forwarded-Proto $scheme;\n
   \tproxy_set_header X-Real-IP $remote_addr;\n
\n
   \tlocation / {\n
        \t\tproxy_redirect off;\n
        \t\tproxy_pass http://odooprod'"$UPSTREAM_NAME"';\n
   \t}\n
\n
   \t# Zarządzanie zapytaniami longpoll chatu Odoo\n
   \tlocation /longpolling {\n
       \t\tproxy_pass http://odoo-chat'"$UPSTREAM_NAME"';\n
   \t}\n
\n
   \t# Pliki pamięci cache\n
   \tlocation ~* /web/static/ {\n
        \t\tproxy_cache_valid 200 90m;\n
        \t\tproxy_buffering on;\n
        \t\texpires 864000;\n
        \t\tproxy_pass http://odooprod'"$UPSTREAM_NAME"';\n
   \t}\n
\n
   \t# Gzip \n
   \tgzip on;\n
   \tgzip_min_length 1100;\n
   \tgzip_buffers 4 32k;\n
   \tgzip_types text/plain text/xml text/css text/less application/x-javascript\n
   \tapplication/xml application/json application/javascript;\n
   \tgzip_vary on;\n
}\n
'




echo -e "\n**************************************************************************"
echo -e "                             SERVER UPDATE                    "
echo -e "**************************************************************************\n"

# server update
sleep 1
sudo apt update -y && sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get upgrade -y && sudo apt dist-upgrade -y && sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y
sleep 1
echo -e "\n*** SERVER UPDATED ***"
sleep 1




#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------

echo -e "\n**************************************************************************"
echo "	                    NGINX INSTALLATION      "
echo -e "**************************************************************************\n"

# test if nginx is installed
echo -e "*** PERFORMING NGINX TEST: \n"
sleep 1
NGINX_RESPONSE=$(systemctl is-active nginx)
echo -e "$NGINX_RESPONSE"

# nginx is not installed
if [[ ${NGINX_RESPONSE} == ${NGINX_STATEMENT} ]];then
        echo -e "\n*** NGINX IS ALREADY INSTALLED ***"
	sleep 1

# nginx is not installed
else
	sleep 1
	echo -e "\n*** INSTALLING NGINX ***\n"
	sleep 1
	sudo apt install nginx -y
	sleep 1
	echo -e "\n*** NGINX INSTALLED ***"

fi


# deleting default nginx settings        
if [ -f /etc/nginx/sites-available/default ]; then
	echo -e "\n**************************************************************************"
	echo "	              DELETING DEFAULT NGINX SETTINGS  "
	echo -e "**************************************************************************"

    	sleep 1
    	sudo rm /etc/nginx/sites-available/default
    	sudo rm /etc/nginx/sites-enabled/default
	echo -e "\n*** DEFAULT NGINX SETTING DELETED ***"
        sleep 1
fi
	

echo -e "\n**************************************************************************"
echo "	               CONFIGURING FIREWALL SETTINGS  "
echo -e "**************************************************************************\n"
sleep 1
sudo ufw allow 'Nginx Full'
sleep 1
echo -e "\n*** FIREWALL CONFIGURED ***"
sleep 1


# block ip database access
echo -e "\n**************************************************************************"
echo "	                CHECKING IP ACCESS BLOCKADE      "
echo -e "**************************************************************************" 
grep -q "#xmlrpc_interface = 127.0.0.1\|xmlrpc_interface = 127.0.0.1" /etc/odootest-server.conf || echo -e "#xmlrpc_interface = 127.0.0.1" >> /etc/odootest-server.conf 
grep -q "#xmlrpc_interface = 127.0.0.1\|xmlrpc_interface = 127.0.0.1" /etc/odooprod-server.conf || echo -e "#xmlrpc_interface = 127.0.0.1" >> /etc/odooprod-server.conf 
sleep 1
grep -Fqx "#xmlrpc_interface = 127.0.0.1" /etc/odootest-server.conf && echo -e "\n*** IP DATABASE ACCESS BLOCKED FOR ODOOTEST (BUT HASHED) ***"
grep -Fqx "xmlrpc_interface = 127.0.0.1" /etc/odootest-server.conf && echo -e "\n*** IP DATABASE ACCESS BLOCKED FOR ODOOTEST ***"
grep -Fqx "#xmlrpc_interface = 127.0.0.1" /etc/odooprod-server.conf && echo -e "\n*** IP DATABASE ACCESS BLOCKED FOR ODOOPROD (BUT HASHED) ***"
grep -Fqx "xmlrpc_interface = 127.0.0.1" /etc/odooprod-server.conf && echo -e "\n*** IP DATABASE ACCESS BLOCKED FOR ODOOPROD ***"
sleep 1


if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
	echo -e "\n**************************************************************************"
	echo "	                  GENERATING SSL KEYS "
	echo -e "**************************************************************************"
	echo -e "\n*** GENERATING A 2048-BIT SSL KEY ***\n"
	sleep 1
	sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
	sleep 1
	echo -e "\n*** KEY GENERATED ***"
	sleep 1
fi


echo -e "\n**************************************************************************"
echo "	                 RESTARTING NGINX SERVICE "
echo -e "**************************************************************************"
sleep 1
sudo systemctl restart nginx
echo -e "\n*** NGINX RESTARTED ***\n"
sleep 1




#-----------------------------------------------------------------------------------------------------------
#                                        Let's Encrypt certification
#-----------------------------------------------------------------------------------------------------------

if [ $USER_OPTION == '1' ]; then

    #---------------------------------------------------------------------------------------
    #                                     Install Let's Encrypt
    #---------------------------------------------------------------------------------------

    echo  "**************************************************************************"
    echo "	                      UPDATE SERVER "
    echo -e "**************************************************************************\n"

    sleep 1
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt-get autoremove -y
    sleep 1
    echo -e "\n*** SERVER UPDATED ***\n"
    sleep 1

    echo "**************************************************************************"
    echo "	             DOWNLOADING LETSENCRYPT REPOSITORY"
    echo -e "**************************************************************************\n"

    sleep 1
    sudo apt install software-properties-common -y
    sudo apt-add-repository -r ppa:certbot/certbot -y
    sudo apt update -y
    sudo apt-get autoremove -y
    sleep 1
    echo -e "\n*** LETSENCRYPT DOWNLOADED ***\n"
    sleep 1

    echo "**************************************************************************"
    echo "	                  INSTALLING CERTBOT "
    echo -e "**************************************************************************\n"

    sleep 1
    sudo apt install certbot -y
    sleep 1
    echo -e "\n*** CERTBOT INSTALLED ***\n"
    sleep 1

    echo -e "*** GENERATING CONFIG DIRECTORIES AND PERMISSIONS ***"
    sudo mkdir -p /var/lib/letsencrypt/.well-known
    sudo chgrp www-data /var/lib/letsencrypt
    sudo chmod g+s /var/lib/letsencrypt
    sleep 1
    echo -e "\n*** DIRECTORIES CREATED ***\n"
    sleep 1

    #---------------------------------------------------------------------------------------
    #                         Installation and configuration of certificates
    #---------------------------------------------------------------------------------------

    if [ ! -f ${LOCATION_SSL_LETS} ]; then

	echo -e "**************************************************************************"
	echo "	                CONFIGURING SSL SNIPPETS  "
	echo -e "**************************************************************************"

	sleep 1
	echo -e "\n*** CREATING SSL CONFIGURATION ***"
	echo -e $SNIPPETS_SSL > ${LOCATION_SSL_LETS}
	sudo chmod 666 ${LOCATION_SSL_LETS}
	sleep 1
	echo -e "\n*** SSL CONFIGURATION CREATED ***"

    fi

    echo -e "\n**************************************************************************"
    echo "	             CONFIGURING LETSENCRYPT SNIPPETS  "
    echo -e "**************************************************************************\n"

    echo -e "*** CREATING LETSENCRYPT CONFIGURATION ***\n"
    sleep 1
    echo -e $SNIPPETS_LE > ${LOCATION_LE}
    sudo chmod 666 ${LOCATION_LE}
    sleep 1
    echo -e "*** LETSENCRYPT CONFIGURATION CREATED ***\n"
    sleep 1

    echo "**************************************************************************"
    echo "	    CONFIGURATION OF PRODUCTION INSTANCE FOR CERTIFICATION "
    echo -e "**************************************************************************\n"

    LOCATION_NGINX="/etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf"
    NGINX_CERT_CONF="server {\r
    \t  listen 80;\r
    \t  server_name $ENV_P$DOMAIN_NAME www.$ENV_P$DOMAIN_NAME;\r
    \r
    \t  include snippets/letsencrypt.conf;\r
    }"

    echo -e "*** BASIC NGINX CONFIGURATION FOR SSL CERTIFICATION OF PRODUCTION SUBDOMAIN ***"
    sleep 1
    echo -e $NGINX_CERT_CONF > ${LOCATION_NGINX}
    sudo chmod 666 ${LOCATION_NGINX}
    sleep 1
    echo -e "\n*** PRODUCTION SUBDOMAIN CONFIGURED ***\n"
    sleep 1

    echo -e "*** CREATING SYMBOLIC LINK ***"
    sudo ln -s /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$ENV_P$DOMAIN_NAME.conf
    sleep 1
    echo -e "\n*** SYMBOLIC LINK CREATED ***\n"
    sleep 1

    echo -e "*** RESTARTING NGINX ***"
    sleep 1
    sudo systemctl restart nginx
    sleep 1
    echo -e "\n*** NGINX RESTARTED ***\n"
    sleep 1

    echo "**************************************************************************"
    echo "             SSL CERTIFICATION OF PRODUCTION ENVIRONMENT "
    echo -e "**************************************************************************\n"

    if [ $WWW == "y" ];then
        sudo certbot certonly --agree-tos --email $EMAIL_ADDRESS --webroot -w /var/lib/letsencrypt/ -d $ENV_P$DOMAIN_NAME -d www.$ENV_P$DOMAIN_NAME -n
     else
        sudo certbot certonly --agree-tos --email $EMAIL_ADDRESS --webroot -w /var/lib/letsencrypt/ -d $ENV_P$DOMAIN_NAME -n
    fi
    sleep 1
    echo -e "\n*** PRODUCTION ENVIRONMENT CERTIFIED ***\n"
    sleep 1

    echo "**************************************************************************"
    echo "	       CONFIGURATION OF TEST INSTANCE FOR CERTIFICATION "
    echo -e "**************************************************************************\n"

    sleep 1
    echo -e "*** REMOVING THE BASIC NGINX CONFIGURATION OF PRODUCTION ENVIRONMENT ***\n"
    sudo rm /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    sudo rm /etc/nginx/sites-enabled/$ENV_P$DOMAIN_NAME.conf
    sleep 1
    echo -e "*** NGINX SETTINGS DELETED ***\n"
    sleep 1 

    LOCATION_NGINX="/etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf"
    NGINX_CERT_CONF="server {\r
    \t  listen 80;\r
    \t  server_name $ENV_T$DOMAIN_NAME www.$ENV_T$DOMAIN_NAME;\r
    \r
    \t  include snippets/letsencrypt.conf;\r
    }"

    sleep 1
    echo -e "*** BASIC NGINX CONFIGURATION FOR SSL CERTIFICATION OF PRODUCTION SUBDOMAIN ***\n"
    echo -e $NGINX_CERT_CONF > ${LOCATION_NGINX}
    sudo chmod 666 ${LOCATION_NGINX}
    sleep 1
    echo -e "*** TEST SUBDOMAIN CONFIGURED ***\n"
    sleep 1

    echo -e "*** CREATING SYMBOLIC LINK ***"
    sudo ln -s /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$ENV_T$DOMAIN_NAME.conf
    sleep 1
    echo -e "\n*** SYMBOLIC LINK CREATED ***\n"
    sleep 1

    echo -e "*** RESTARTING NGINX ***\n"
    sleep 1
    sudo systemctl restart nginx
    sleep 1
    echo -e "*** NGINX RESTARTED ***\n"
    sleep 1

    echo "**************************************************************************"
    echo "	          SSL CERTIFICATION OF TEST ENVIRONMENT "
    echo -e "**************************************************************************\n"

    if [ $WWW == "Y" ];then
        sudo certbot certonly --agree-tos --email $EMAIL_ADDRESS --webroot -w /var/lib/letsencrypt/ -d $ENV_T$DOMAIN_NAME -d www.$ENV_T$DOMAIN_NAME -n
     else
        sudo certbot certonly --agree-tos --email $EMAIL_ADDRESS --webroot -w /var/lib/letsencrypt/ -d $ENV_T$DOMAIN_NAME -n
    fi

    sleep 1
    echo -e "\n*** TEST ENVIRONMENT CERTIFIED ***\n"
    sleep 1

    #---------------------------------------------------------------------------------------
    #                                     The final NGINX configuration
    #---------------------------------------------------------------------------------------
    echo "**************************************************************************"
    echo "	  FINAL NGINX CONFIGURATION FOR PRODUCTION AND TEST INSTANCE "
    echo -e "**************************************************************************\n"

    sleep 1
    echo -e "*** REMOVING BASIC NGINX CONFIGURATION OF BOTH SUBDOMAINS ***\n"
    sudo rm /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    sudo rm /etc/nginx/sites-enabled/$ENV_T$DOMAIN_NAME.conf
    sleep 1
    echo -e "*** NGINX SETTINGS DELETED ***\n"
    sleep 1

    echo -e "*** MOVING TEST AND PROD CONFIGURATION FILES AND CREATING SYMBOLIC LINK ***\n"
    sleep 1
    # test
    touch /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    echo -e $TEST_FILE > /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    sudo ln -s /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$ENV_T$DOMAIN_NAME.conf
    # prod
    touch /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    echo -e $PROD_FILE > /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    sudo ln -s /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$ENV_P$DOMAIN_NAME.conf
    sleep 1
    echo -e "*** CONFIG FILES MOVED ***\n"
    sleep 1

    echo -e "*** RESTARTING NGINX ***"
    sudo systemctl restart nginx
    sleep 1
    echo -e "\n*** NGINX RESTARTED ***\n"
    sleep 1

    echo -e "*** STARTING AUTOMATIC NGINX CERTIFICATE UPDATE ***\n"
    sudo rm /etc/cron.d/certbot
    cd /etc/cron.d
    touch certbot
    echo -e $CERTBOT_FILE > /etc/cron.d/certbot
    sudo certbot renew --dry-run
    sleep 1
    echo -e "\n*** NGINX CERTIFICATE UPDATED ***\n"
    sleep 1




#-----------------------------------------------------------------------------------------------------------
#                                        Cloudflare certification
#-----------------------------------------------------------------------------------------------------------

elif [ $USER_OPTION == '2' ]; then

	sleep 1

	if [ ! -f ${LOCATION_SSL_CDN} ]; then

		echo -e "\n**************************************************************************"
		echo "	                   CONFIGURING SNIPPETS  "
		echo -e "**************************************************************************"

		sleep 1
		echo -e "\n*** CREATING SSL CONFIGURATION ***"
		echo -e $SNIPPETS_SSL > ${LOCATION_SSL_CDN}
		sudo chmod 666 ${LOCATION_SSL_CDN}
		sed -i 's/ssl_stapling on;/ssl_stapling off;/' ${LOCATION_SSL_CDN}
		sleep 1
		echo -e "\n*** SSL CONFIGURATION CREATED ***"

	fi

    	echo -e "**************************************************************************"
    	echo -e "                        SAVING CLOUDFLARE KEY AND CERT                    "
    	echo -e "**************************************************************************\n"

	if [ ! -f /etc/ssl/private/${DOMAIN_NAME} ]; then
    		mkdir /etc/ssl/private/${DOMAIN_NAME}
	fi
    	mv ./cert.pem /etc/ssl/private/${DOMAIN_NAME}/cert.pem
    	mv ./key.pem /etc/ssl/private/${DOMAIN_NAME}/key.pem

    	sleep 1
    	echo -e "*** CLOUDFLARE KEY AND CERT SAVED ***\n"
    	sleep 1

    	#---------------------------------------------------------------------------------------
    	#                         Installation and configuration of certificates
    	#---------------------------------------------------------------------------------------

    	echo -e "**************************************************************************"
    	echo "	     CONFIGURATION OF PRODUCTION INSTANCE FOR CERTIFICATION "
    	echo -e "**************************************************************************\n"

    	echo -e "*** NGINX CONFIGURATION FOR SSL CERTIFICATION OF PRODUCTION SUBDOMAIN ***"
    	sleep 1
    	echo -e $PROD_FILE > /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    	sed -i 's+include snippets/letsencrypt.conf;+#include snippets/letsencrypt.conf;+' /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    	sed -i "s+/etc/letsencrypt/live/$ENV_P$DOMAIN_NAME/fullchain.pem;+/etc/ssl/private/$DOMAIN_NAME/cert.pem;+" /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    	sed -i "s+/etc/letsencrypt/live/$ENV_P$DOMAIN_NAME/privkey.pem;+/etc/ssl/private/$DOMAIN_NAME/key.pem;+" /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    	sed -i "s+ssl_trusted_certificate /etc/letsencrypt/live/$ENV_P$DOMAIN_NAME/chain.pem;+#ssl_trusted_certificate /etc/letsencrypt/live/$ENV_P$DOMAIN_NAME/chain.pem;+" /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    	sudo chmod 666 /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf
    	sleep 1

    	echo -e "\n*** NGINX PRODUCTION SUBDOMAIN CONFIGURED ***\n"
    	sleep 1

    	echo -e "*** CREATING SYMBOLIC LINK ***"
    	sudo ln -s /etc/nginx/sites-available/$ENV_P$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$ENV_P$DOMAIN_NAME.conf
    	sleep 1
    	echo -e "\n*** SYMBOLIC LINK CREATED ***\n"
    	sleep 1

    	echo "**************************************************************************"
    	echo "	         CONFIGURATION OF TEST INSTANCE FOR CERTIFICATION "
    	echo -e "**************************************************************************\n"

    	sleep 1
    	echo -e "*** NGINX CONFIGURATION FOR SSL CERTIFICATION OF TEST SUBDOMAIN ***\n"
    	echo -e $TEST_FILE > /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    	sed -i 's+include snippets/letsencrypt.conf;+#include snippets/letsencrypt.conf;+' /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    	sed -i "s+/etc/letsencrypt/live/$ENV_T$DOMAIN_NAME/fullchain.pem;+/etc/ssl/private/$DOMAIN_NAME/cert.pem;+" /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    	sed -i "s+/etc/letsencrypt/live/$ENV_T$DOMAIN_NAME/privkey.pem;+/etc/ssl/private/$DOMAIN_NAME/key.pem;+" /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    	sed -i "s+ssl_trusted_certificate /etc/letsencrypt/live/$ENV_T$DOMAIN_NAME/chain.pem;+#ssl_trusted_certificate /etc/letsencrypt/live/$ENV_T$DOMAIN_NAME/chain.pem;+" /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    	sudo chmod 666 /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf
    	sleep 1
    	echo -e "*** TEST SUBDOMAIN CONFIGURED ***\n"
    	sleep 1

    	echo -e "*** CREATING SYMBOLIC LINK ***"
    	sudo ln -s /etc/nginx/sites-available/$ENV_T$DOMAIN_NAME.conf /etc/nginx/sites-enabled/$ENV_T$DOMAIN_NAME.conf
    	sleep 1
    	echo -e "\n*** SYMBOLIC LINK CREATED ***\n"
    	sleep 1
	
fi

echo -e "*** RESTARTING NGINX ODOOPROD AND ODOOTEST ***"
sudo systemctl restart nginx
sudo systemctl restart odooprod-server.service
sudo systemctl restart odootest-server.service
sleep 1
echo -e "\n*** SERVICES RESTARTED ***\n"
sleep 1

read -p "*** Do you want to certificate another domain? (y/n) " CONTINUE

done




#-----------------------------------------------------------------------------------------------------------
#                                           End of script
#-----------------------------------------------------------------------------------------------------------

sleep 1
echo -e "\n**************************************************************************"
echo -e "                               END OF SCRPIT       "
echo -e "**************************************************************************\n"

echo -e "*** PERFORMING NGINX TEST ***\n"
sleep 1
NGINX_OUTPUT=$(nginx -t 2>&1)
echo $NGINX_OUTPUT

if [[ "$NGINX_OUTPUT" == *"syntax is ok"*"successful" ]]; then
	sleep 1
        echo -e "\n*** SWITCHING PROXY MODE TO TRUE FOR PROD AND TEST ***"
	grep -q "proxy_mode = False" /etc/odootest-server.conf || sed -i 's+proxy_mode = False+proxy_mode = True+' /etc/odootest-server.conf
	grep -q "proxy_mode = False" /etc/odooprod-server.conf || sed -i 's+proxy_mode = False+proxy_mode = True+' /etc/odooprod-server.conf
	sleep 1
	echo -e "\n*** PROXY MODE SWITCHED ON ***"
fi

echo -e "\n**************************************************************************"

sleep 1
echo -e "\n*** Script execution was finished on $(date +"%Y.%m.%d %H:%M:%S") ***" 
sleep 1

echo -e "\n*** To perform nginx test type: ***"
echo -e "nginx -t"

echo -e "\n*** To restart nginx type: ***"
echo -e "sudo systemctl restart nginx\n"










