#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                     Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of creating users with root privileges by enabling connection via ssh keys

# Interface allows root user to:
# [1] - create new user (from scratch - declaring username and ssh key)
# [2]-[5] - create user (that username and ssh key are declared in script)
# [9] - list all users
# [0] - delete chosen user

#-----------------------------------------------------------------------------------------------------------
#                                           Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp script.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x create_user_0.2.0.sh
# Execute the file:
# sudo ./script.sh
# As the script executes, provide responses that match the user being created

#-----------------------------------------------------------------------------------------------------------
#                                                  Script version
#-----------------------------------------------------------------------------------------------------------

# version  0.1.0 [2022-01-11]

# version  0.2.0 [2022-05-23]
# added listing of all users

#-----------------------------------------------------------------------------------------------------------
#                                  Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_AUTHOR="Oskar Kwidziński"
SCRIPT_NAME="create_user_0.2.0.sh"
SCRIPT_VERSION="0.2.0"

# employees
USERNAME_OSKAR="oskarkwidzinski"
PUB_KEY_OSKAR="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCycSz7Ey7qnI1AyoDu+JpAc9Gvb9q/oLexacw0UwDjhlm1Cho5llkFZNenUZrx6e3JqesTa6ZwE95PebBsCPOqTHgvHsk9l2/6fBZZ/F2sx/qn45zOAGASfU/YTbbjyoA1gfT2fmu9hTgOaXSfuStmDyIzcgWtMmbWSN4z8zt0T3mQnZRwz6KzCYe0k8drtS2b3Vn1mHGq69lwcFngWdOjQGwBoRnV1sWG7eL7KA+iwEQGwQSDD9S6bio517sfSFV7cmah0z8uuQdhirp3sarqKfmx/QPyJYwL/82FGhrqfwAeHkC5WJY0W2QH1Zsojl8kOipXlFzXNz9EBiqQcw9sKEtTLspGq/Hx+zQabagSE6HQ/R4gk+Ibz2CELHU0LcqRpyHm9Gf1PEnE0X52VSK4CWk8n55C06ehC4FZaBXIXTp0xQaGf0aMRFeAe6Vty/Gsr0JGWAldmrfDViaKI2HLtnuxIeBpy1fT4AtfmUHkn/oqseyC7V9MMdUHsFMZ1+k= kwidz@DESKTOP-90DFH4J"
USERNAME_USER2=""
PUB_KEY_USER2=""
USERNAME_USER3=""
PUB_KEY_USER3=""
USERNAME_USER4=""
PUB_KEY_USER4=""

UPDATE="y"
USER_OPTION=1

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
        UPDATE=n
    fi

done

sleep 1
echo -e "\n**************************************************************************"
echo -e "                      LIST OF ALREADY CREATED USERS       "
echo -e "**************************************************************************\n"

# list all users
SUBDIRCOUNT=$(find /home/ -maxdepth 1 -type d | wc -l) 
if [ "$SUBDIRCOUNT" -eq 1 ]; then
	echo -e "*** No users created yet ***" 
else
	for i in $(ls -d /home/* ); do
        	sleep 0.5 
		echo "${i:6}";
	done
fi


#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------

# create user function
create_user () {

    sleep 1
    echo -e "\n**************************************************************************"
    echo -e "                             USER CREATION       "
    echo -e "**************************************************************************\n"
    
    if [ -d "/home/$1" ]; then

        echo "*** User '$1' already exists ***"

    else

        # adding user
        adduser $1

        # inputting user pubkey
        cd /home/$1/
        mkdir .ssh
        chmod 700 .ssh
        cd .ssh
        touch authorized_keys
        chmod 600 authorized_keys
        echo $2 >> /home/$1/.ssh/authorized_keys

        # change shared .bash_aliases destination for user
        sed -i 's+~/.bash_aliases+/etc/.shared_aliases+' /home/$1/.bashrc
        if [ -f /etc/.bash_aliases ]; then
        	source /etc/.bash_aliases
        fi

        usermod -aG sudo $1
        chown -R $1:$1 /home/$1/.ssh

        # created user confirmation
        sleep 1
        echo -e "\n**************************************************************************"
        echo -e "                      USER $1 HAS BEEN CREATED       "
        echo -e "**************************************************************************\n"

        sleep 1
        echo -e "*** Verification of user: ***\n"
	sleep 1
        id $1
        echo " "

        sleep 1
        echo -e "*** Verification of user's privileges: ***\n"
        sleep 1
	sudo -l -U $1 
	sleep 1 
    fi

}

# delete user function
delete_user () {
 
    sleep 1
    echo -e "\n**************************************************************************"
    echo -e "                        USER $1 DELETION       "
    echo -e "**************************************************************************\n"
    
    if [ -d "/home/$1" ]; then

        read -p "*** Are you sure you want to delete user '$1' (y/n)? " DEL_USER
        sudo killall -u $1
        echo " "
        sleep 1

        if [ $DEL_USER == y ] || [ $DEL_USER == Y ] ; then

          # user deletion
          sudo deluser --remove-home $1
          sleep 1
          echo -e "\n*** User '$1' has been deleted ***"

        fi

    else
         
        sleep 1
        echo "*** User '$1' does not exist ***"

    fi
    sleep 1

}

# options interface
while [ $USER_OPTION != q ] && [ $USER_OPTION != Q ]; do

    sleep 1
    echo -e "\n**************************************************************************"
    echo -e "                            CHOOSE OPERATION            "
    echo -e "**************************************************************************\n"

    echo "Choose operation:"
    echo "1 - create new user"
    echo "2 - create user '$USERNAME_OSKAR'"
    echo "3 - create user '$USERNAME_USER2'"
    echo "4 - create user '$USERNAME_USER3'"
    echo "5 - create user '$USERNAME_USER4'"
    echo "9 - list all users"
    echo "0 - delete chosen user"
    echo -e "q - cancel\n"

    read -p "*** Input choice: " USER_OPTION

    if [ $USER_OPTION == 0 ] || [ $USER_OPTION == 1 ]; then
       
        if [ $USER == "root" ]; then
        	echo -e "\n**************************************************************************"
        	echo -e "                           RETRIEVE USER DATA            "
        	echo -e "**************************************************************************\n"
        	read -p "*** Input username: " USERNAME

	        if [ $USER_OPTION == 0 ]; then

	            delete_user $USERNAME

	        elif [ $USER_OPTION == 1 ]; then

	            read -p "*** Input $USERNAME public key: " PUB_KEY
        	    create_user $USERNAME "$PUB_KEY"

	        fi
        else
		echo -e "\n*** Operation restricted for root user ***"
        fi

    elif [ $USER_OPTION == 2 ]; then

	if [ $USER == "root" ]; then	
	    create_user $USERNAME_OSKAR "$PUB_KEY_OSKAR"
        else
            echo -e "\n*** Operation restricted for root user ***"
        fi        

    elif [ $USER_OPTION == 3 ]; then

	if [ $USER == "root" ]; then
	    create_user $USERNAME_USER2 "$PUB_KEY_USER2"
        else
	    echo -e "\n*** Operation restricted for root user ***"
        fi

    elif [ $USER_OPTION == 4 ]; then

	if [ $USER == "root" ]; then
	    create_user $USERNAME_USER3 "$PUB_KEY_USER3"
        else
	    echo -e "\n*** Operation restricted for root user ***"
        fi

    elif [ $USER_OPTION == 5 ]; then

	if [ $USER == "root" ]; then
	    create_user $USERNAME_USER4 "$PUB_KEY_USER4"
        else
	    echo -e "\n*** Operation restricted for root user ***"
        fi
        
    elif [ $USER_OPTION == 9 ]; then

	sleep 1
	echo -e "\n**************************************************************************"
	echo -e "                      LIST OF ALREADY CREATED USERS       "
	echo -e "**************************************************************************\n"

	SUBDIRCOUNT=$(find /home/ -maxdepth 1 -type d | wc -l) 
	if [ "$SUBDIRCOUNT" -eq 1 ]; then
		echo -e "*** No users created yet ***" 
	else
		for i in $(ls -d /home/* ); do
        	sleep 0.5 
		echo "${i:6}";
	done
	fi


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
echo -e "*** The commands from the script were executed on $(date +"%Y.%m.%d %H:%M:%S") ***\n" 
echo "*** To verify the created user, run the command: ***"
echo -e "id username\n"

echo "*** To verify a user privileges run the command: ***"
echo -e "sudo -U -l username\n" 

echo "*** To edit user aliases run script: ***"
echo -e "bash_aliases_0.1.0\n"



















