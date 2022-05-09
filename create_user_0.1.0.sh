#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                     Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of creating users with root privileges by enabling connection via ssh keys

#-----------------------------------------------------------------------------------------------------------
#                                           Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp script.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x script.sh
# Execute the file:
# sudo ./script.sh
# As the script executes, provide responses that match the user being created

#-----------------------------------------------------------------------------------------------------------
#                                                  Script version
#-----------------------------------------------------------------------------------------------------------

# version  0.1.0 [2022-01-11]

#-----------------------------------------------------------------------------------------------------------
#                                  Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_AUTHOR="Oskar Kwidziński"
SCRIPT_NAME="create_user_0.1.0.sh"
SCRIPT_VERSION="0.1.0"

# employees
USERNAME_OSKAR="oskarkwidzinski"
PUB_KEY_OSKAR="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCycSz7Ey7qnI1AyoDu+JpAc9Gvb9q/oLexacw0UwDjhlm1Cho5llkFZNenUZrx6e3JqesTa6ZwE95PebBsCPOqTHgvHsk9l2/6fBZZ/F2sx/qn45zOAGASfU/YTbbjyoA1gfT2fmu9hTgOaXSfuStmDyIzcgWtMmbWSN4z8zt0T3mQnZRwz6KzCYe0k8drtS2b3Vn1mHGq69lwcFngWdOjQGwBoRnV1sWG7eL7KA+iwEQGwQSDD9S6bio517sfSFV7cmah0z8uuQdhirp3sarqKfmx/QPyJYwL/82FGhrqfwAeHkC5WJY0W2QH1Zsojl8kOipXlFzXNz9EBiqQcw9sKEtTLspGq/Hx+zQabagSE6HQ/R4gk+Ibz2CELHU0LcqRpyHm9Gf1PEnE0X52VSK4CWk8n55C06ehC4FZaBXIXTp0xQaGf0aMRFeAe6Vty/Gsr0JGWAldmrfDViaKI2HLtnuxIeBpy1fT4AtfmUHkn/oqseyC7V9MMdUHsFMZ1+k= kwidz@DESKTOP-90DFH4J"
USERNAME_MICHAL="michalandrzejewski"
PUB_KEY_MICHAL="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTignBLADbdJxX34+l/yy3M5iJLmNV54YSn6mtg4Lc9/2HIavPwO6afZXBYFD5YqVBM+OVvLHGuiRFeIA5mNOSjAhqCxFcikm3aFrE+ceniTp1hfQByJeSA6GvoAXYPIu+977np794CVfkMXNfD5zfsRyPfj8Os3nRyc0a/OBD9kK7s5LXLbcFFftOpkevXwmp5b5jaFOIWqFONz0RUp+tfRsW8CKiF+f+Ixdi7E1xJXaqzBUkjXbrRSqERvlad65muY67hKnTeq2ru3MrmajL5pE0EzrsiBfnkCL5dXsRQiv0cWUfKxnSpKUg7HQpjefyvt1Z0pOZkoAkPQuSEqcsfz38A+hKHLawzfFaPO3n8GOAidr4IbpMlBZw2/aXXYhH+CMW3n3lKRYfq7XQuSu5rMPpYUGXNRq81Os+SS1Xhmgl41HB5+2WSY7OFR/DP9Izxf3ihwgseSpAKmax6KcMYhjZfytOFwh8CVGr9T2nh4fGF7Rcq/6iFxOzRhszZvk= michal@michal-VirtualBox"
USERNAME_DAWID="dawidnowalinski"
PUB_KEY_DAWID="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqrMF8mXda37k2bNB3iLrzjt7c/3Mmq6LFYAwvQbHEVmiIdhksmBAyWGQudnZSOsi/PgS6+iZS/eVnbr+3eBs/H4py6eB5LCME0PkHICHC8kIx8nygiIlfgCshvVCDuuzaFoNk3RG0soORKwZ6o2cMogvhkifk0U4omEbzulFucqeAOFE2yOfSf91UH3uhBKqN6+pdaw18O8r9tD0plEeN7tP9foff8BOAX9PhWedopKxoixTdW4TTcTNlo/CiWrFB8LxHq0Mfb8kJtt5lBiZSl6y/gHsQB38wdyLQaxUJYftD7HGoHUTZ3AyAV40bQfFm3URuh3On4fcdpe/MWfjGFA3auDJwihHorI69OGxsaKlbdDOiE8wTqOJCBDDRn1E3814D4ePE1SzMcV73qQ9HXhVRGJpUpkwZ4UxcN0cWNBdvFzjJPxHP9WoSwHSX9zcub98T+5XTdLa36OEXSyJ1FlXdj8aU7VgjcbK1DaN1g5de5soYgGqextOWUzA+SuAV4ya3eYJLK1cnDsTn3kYKzF40XqMlBNP3Lsznsy0w1L1l41wGLL2WLrPpsN8nJ80tNFb8HWIfYoBqQXMC5iS47+IUkIeymJfsBbukJhh0zldGoeovSjvxz/74G7o097Wk98nuEiwAavtWH4ZqVkHMuBqp927E5GNNCXz8L0X0mw== knifcio@KnifcioXPS"
USERNAME_PATRYCJA="patrycjabolius"
PUB_KEY_PATRYCJA="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNLVbmExtbrbwr3XKNtUiXcqJbzNPcOU/bRgiy8R8Cs0RDFZZqu11ikmSta9ivoEmFHTZ9o+CJsRkzZWe1GlSHd8/uJDT/Mc5hK5yxIrhJ5++N/RLi9roHdnKOs+/wHbvryJROGx29WIVqN+wjM6TajH7kSGfCmYTjpDFmKNNPWP8grautjhAZlUxCRhy8KHzO2DUYDX+I78lWagAaksXnFnK2VGINWpav1FQuyY+L6FiCeQK6+gOWFr/eyFEuSwarZm3BoVmLV5QX7yWuV5mWE9kQ9tPh+/2kOavpWdRLC9CQHglEXRyTrCBa2MxCuHsW5LKnW+UYVtO1f+IOLMPsbwQdr0X1qH1lzWOO064yEkIzw8yMxb/qDepYjZ0KyHljNDlhbuoPxNqlxFPIw17fDWGd1BRjhau+w49Hcgug1W1ArkVKrfdEbllDVnFrQ8j5vfm4cGMcss/64r9v/k4WjnkOcRgaeeamD9U9tYl5EV5ouDkrXud0C5Chm+zVZp8= pati@MacBook-Pro-Patrycja.local"

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
if [ -d /home/*/ ]; then
	for i in $(ls -d /home/* ); do
        	sleep 0.5 
		echo "${i:6}";
	done
else
	echo -e "*** No users created yet ***" 
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
    echo "3 - create user '$USERNAME_DAWID'"
    echo "4 - create user '$USERNAME_PATRYCJA'"
    echo "5 - create user '$USERNAME_MICHAL'"
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
	    create_user $USERNAME_DAWID "$PUB_KEY_DAWID"
        else
	    echo -e "\n*** Operation restricted for root user ***"
        fi

    elif [ $USER_OPTION == 4 ]; then

	if [ $USER == "root" ]; then
	    create_user $USERNAME_PATRYCJA "$PUB_KEY_PATRYCJA"
        else
	    echo -e "\n*** Operation restricted for root user ***"
        fi

    elif [ $USER_OPTION == 5 ]; then

	if [ $USER == "root" ]; then
	    create_user $USERNAME_MICHAL "$PUB_KEY_MICHAL"
        else
	    echo -e "\n*** Operation restricted for root user ***"
        fi
        
    elif [ $USER_OPTION == 9 ]; then

	sleep 1
	echo -e "\n**************************************************************************"
	echo -e "                      LIST OF ALREADY CREATED USERS       "
	echo -e "**************************************************************************\n"

	if [ -d /home/*/ ]; then
             for i in $(ls -d /home/* ); do
        		sleep 0.5 
			echo "${i:6}";
	     done
	else
	     echo -e "*** No users created yet ***" 
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



















