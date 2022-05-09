#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                     Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of creating users with root privileges by enabling connection via ssh keys

#-----------------------------------------------------------------------------------------------------------
#                                           Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp bash_aliases_0.1.0.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x bash_aliases_0.1.0.sh
# Execute the file:
# source ./bash_aliases_0.1.0.sh
# As the script executes, provide responses that matches user choice option

#-----------------------------------------------------------------------------------------------------------
#                                                  Script version
#-----------------------------------------------------------------------------------------------------------

# version  0.1.0 [2022-01-13]

#-----------------------------------------------------------------------------------------------------------
#                                  Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_AUTHOR="Oskar Kwidziński"
SCRIPT_NAME="bash_aliases_0.1.0.sh"
SCRIPT_VERSION="0.1.0"

SCRIPT_VERSION_PHRASE="# GENERATED FROM SCRIPT VERSION $SCRIPT_VERSION"
SHARED_ALIASES_VERSION=""
OWN_ALIASES_VERSION=""

UPDATE=y
USER_OPTION=1
SHARED_ALIASES="/etc/.shared_aliases"
OWN_ALIASES="/home/$USER/.bashrc"
if [ $USER == "root" ]; then
   OWN_ALIASES="/root/.bash_aliases"
fi   

RKS_ALIASES=$''"$SCRIPT_VERSION_PHRASE"'
alias server_update="sudo apt update -y && sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get upgrade -y && sudo apt dist-upgrade -y && sudo apt-get dist-upgrade -y"
alias start_prod="sudo systemctl start odooprod-server.service"
alias stop_prod="sudo systemctl stop odooprod-server.service"
alias restart_prod="sudo systemctl restart odooprod-server.service"
alias source_prod="source ../../../odooprod/env_odooprod/bin/activate"
alias start_test="sudo systemctl start odootest-server.service"
alias stop_test="sudo systemctl stop odootest-server.service"
alias restart_test="sudo systemctl restart odootest-server.service"
alias source_test="source ../../../odootest/env_odooprod/bin/activate"
alias start_nginx="sudo systemctl start nginx"
alias stop_nginx="sudo systemctl stop nginx"
alias restart_nginx="sudo systemctl restart nginx"
alias test_nginx="nginx -t"'


#-----------------------------------------------------------------------------------------------------------
#                                              Script launch
#-----------------------------------------------------------------------------------------------------------

sleep 1
echo -e "\n=============================================================================="
echo "                             Launch: ${SCRIPT_NAME}                "
echo "                              version ${SCRIPT_VERSION}            "
echo "                            $(date +"%Y.%m.%d %H:%M:%S")             "
echo "                          Created by: ${SCRIPT_AUTHOR}            "
echo -e "==============================================================================\n"

sleep 1
echo -e "**************************************************************************"
echo -e "                                SERVER UPDATE                    "
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



# obtain recent aliases version
if [ -f $SHARED_ALIASES ]; then
	SHARED_ALIASES_VERSION=$(head -n 1 $SHARED_ALIASES)
fi

if [ $USER == 'root' ]; then

   # create /etc/.shared_aliases if does not exist
   if [ ! -f $SHARED_ALIASES ]; then
        sleep 1
	touch /etc/.shared_aliases
	source $SHARED_ALIASES
        echo -e "\n*** File for shared aliases has been created in $SHARED_ALIASES ***"
   fi

   # add rks aliases to shared aliases if not equal
   if [ "$SHARED_ALIASES_VERSION" != "$SCRIPT_VERSION_PHRASE" ]; then
	sleep 1
	echo -e "\n*** Current script version $SCRIPT_VERSION is not equal to shared_aliases aliases ***"
	echo -e "... UPDATING ..."
	sleep 1
	echo "$RKS_ALIASES" > $SHARED_ALIASES
	source $SHARED_ALIASES
        echo -e "*** RedKnife Studio aliases have been updated from script in $SHARED_ALIASES ***"
   fi

fi


# obtain recent aliases version
if [ -f $OWN_ALIASES ]; then
	 OWN_ALIASES_VERSION=$(head -n 1 $OWN_ALIASES)
fi

# add rks aliases to .bash_aliases destination for root
if [ $USER == 'root' ]; then

   # create /root/.bash_aliases if does not exist
   if [ ! -f $OWN_ALIASES  ]; then
        sleep 1
	touch $OWN_ALIASES
	source $OWN_ALIASES
        echo -e "\n*** File for root aliases has been created in $OWN_ALIASES ***"
   fi

   # add rks aliases to root aliases if not equal
   if [ "$OWN_ALIASES_VERSION" != "$SCRIPT_VERSION_PHRASE" ]; then
	sleep 1
	echo -e "\n*** Current script version $SCRIPT_VERSION is not equal to root aliases ***"
	echo -e "... UPDATING ..."
        sleep 1
   	echo "$RKS_ALIASES" > $OWN_ALIASES
	source $OWN_ALIASES
        echo -e "*** RedKnife Studio aliases have been updated from script in $OWN_ALIASES ***"
   fi
fi



#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------


# options interface
while [ $USER_OPTION != q ] && [ $USER_OPTION != Q ]; do

    sleep 1
    echo -e "\n**************************************************************************"
    echo -e "                            CHOOSE OPERATION            "
    echo -e "**************************************************************************\n"

    echo "*** Choose operation: "
    echo -e "1 - add aliases to shared aliases"
    echo -e "2 - add aliases to own aliases"
    echo -e "3 - refresh aliases"
    echo -e "4 - show all aliases"
    echo -e "q - cancel\n"

    read -p "*** Input choice: " USER_OPTION

    # execute option

    if [ $USER_OPTION == 1 ]; then
	NEW_ALIAS="yes"

	# adding new shared alias
	while [ "$NEW_ALIAS" != "q" ] && [ "$NEW_ALIAS" != "Q" ]; do

                if [ $USER == "root" ]; then
                	echo -e "\n*** Declare new alias in format:\n*** alias name_alias='performed command' ***"
			echo -e "*** q - exit adding aliases ***\n"
	    		read NEW_ALIAS

			if [ "$NEW_ALIAS" != "q" ] && [ "$NEW_ALIAS" != "Q" ]; then 
                		echo $NEW_ALIAS >> $SHARED_ALIASES
				sleep 1
        	        	echo -e "\n*** Alias has been added ***"
				echo -e "--------------------------------------------------"
			fi

                # adding blocked to non root
                else 
                        if [ -f $SHARED_ALIASES  ]; then
                        	source $SHARED_ALIASES
                        fi
                        echo -e "\n*** Only root user can add alias to shared aliases ***"
			NEW_ALIAS="q"
		fi   

                sleep 1

	done
     
     # adding new own alias   
     elif [ $USER_OPTION == 2 ]; then     
	NEW_ALIAS="yes"

	# adding new own alias
     	while [ "$NEW_ALIAS" != "q" ] && [ "$NEW_ALIAS" != "Q" ]; do
                echo -e "\n*** Declare new alias in format:\n*** alias name_alias='performed command' ***"
		echo -e "*** q - exit adding aliases ***\n"
	    	read NEW_ALIAS
		
		if [ "$NEW_ALIAS" != "q" ] && [ "$NEW_ALIAS" != "Q" ]; then
			if [ $USER == "root" ]; then 
                		echo $NEW_ALIAS >> /root/.bashrc       
                		source /root/.bashrc  

			else
				echo $NEW_ALIAS >> $OWN_ALIASES        
                		source $OWN_ALIASES	
			fi

	                sleep 1
        	        echo -e "\n*** Alias has been added ***"
			echo -e "--------------------------------------------------"
		fi
	done
    
    # updating aliases    
    elif [ $USER_OPTION == 3 ]; then

        	# update aliases
        	if [ $USER != "root" ]; then
		      if [ -f $SHARED_ALIASES ]; then
   	              	source $SHARED_ALIASES
          	      	sleep 1
          	      	echo -e "\n*** Shared aliases refreshed ***"
		      fi 
		fi   

        	source $OWN_ALIASES
        	sleep 1
        	echo -e "\n*** Own aliases refreshed ***"

    # showing all aliases
    elif [ $USER_OPTION == 4 ]; then

		sleep 1
		echo -e "\n*** Shared aliases repo *** " 
		awk '$1=="alias" {f=1} $1!="alias" {f=0} f' $SHARED_ALIASES 

		sleep 1
		if [ $USER == "root" ]; then 
			echo -e "\n*** $USER aliases repo *** "
		else
			echo -e "\n*** $USER aliases manually added *** "
		fi
		awk '$1=="alias" {f=1} $1!="alias" {f=0} f' $OWN_ALIASES   

		if [ $USER == "root" ]; then 
			sleep 1
			echo -e "\n*** $USER aliases manually added *** "
			awk '$1=="alias" {f=1} $1!="alias" {f=0} f' /root/.bashrc
		fi	


    # leaving the game  
    elif [ $USER_OPTION == q ]; then
        	true
    fi
  
done


#-----------------------------------------------------------------------------------------------------------
#                                           End of script
#-----------------------------------------------------------------------------------------------------------

sleep 1
echo -e "\n**************************************************************************"
echo -e "                               END OF SCRPIT       "
echo -e "**************************************************************************\n"

sleep 1
echo -e "The commands from the script were executed $(date +"%Y.%m.%d %H:%M:%S")\n" 

echo "*** To check own aliases, go to file: ***"
echo -e "$OWN_ALIASES\n"


echo "*** To check shared aliases, go to file: ***"
echo -e "$SHARED_ALIASES\n"





















