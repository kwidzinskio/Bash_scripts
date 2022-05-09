 #!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                     Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of cloning directories/files from Github to server

#-----------------------------------------------------------------------------------------------------------
#                                                Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp git_clone_0.1.0.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x git_clone_0.1.0.sh
# Execute the file:
# sudo ./git_clone_0.1.0.sh

#-----------------------------------------------------------------------------------------------------------
#                                               Script version
#-----------------------------------------------------------------------------------------------------------

# version 0.1.0 [2022-01-17]

#-----------------------------------------------------------------------------------------------------------
#                                       Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_NAME="git_clone_0.1.0.sh"
SCRIPT_VERSION="0.1.0"
SCRIPT_AUTHOR="Oskar Kwidziński"

USER_CHOICE=1
UPDATE=y

#-----------------------------------------------------------------------------------------------------------
#                                              Script launch
#-----------------------------------------------------------------------------------------------------------

echo " "
echo "=============================================================================="
echo "                          Launch: ${SCRIPT_NAME}                "
echo "                              version ${SCRIPT_VERSION}            "
echo "                            $(date +"%Y.%m.%d %H:%M:%S")             "
echo "                          Created by: ${SCRIPT_AUTHOR}            "
echo "=============================================================================="
echo " "

echo  "**************************************************************************"
echo  ">                             SERVER UPDATE                    "
echo  "**************************************************************************"
echo " "

# server update
while [ $UPDATE != n ] && [ $UPDATE != N ]; do

    read -p "Do you want to update UNIX packages? (y/n) " UPDATE

    if [ "$UPDATE" == "y" ] || [ $UPDATE == Y ]  ; then
	    sudo apt update -y && sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get upgrade -y && sudo apt dist-upgrade -y && sudo apt-get dist-upgrade -y
            sudo apt-get autoremove -y
            UPDATE=n
    fi

done

# install subversion if does not exist
if [ ! -f /etc/subversion/config ]; then
	sudo apt-get install subversion -y
fi

sleep 1

#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------

# export git subversion
git_subversion () {

echo -e "\n**************************************************************************"
echo -e "			             CLONING		    	"
echo -e "**************************************************************************\n"

BRANCH_NAME=$(echo "$GIT_LOGPATH" | awk -F[/,/] '{print $7}')

if [ -z "$BRANCH_NAME" ]; then
	BRANCH_NAME="empty"	
fi

# preparing url
if [ $BRANCH_NAME == 'main' ]; then

    GIT_LOGPATH=$(echo "$GIT_LOGPATH" | sed 's+blob/main+trunk+g')
    GIT_LOGPATH=$(echo "$GIT_LOGPATH" | sed 's+tree/main+trunk+g')

elif [ $BRANCH_NAME != 'main' ]; then

    GIT_LOGPATH=$(echo "$GIT_LOGPATH" | sed "s+blob/$BRANCH_NAME+branches/$BRANCH_NAME+g")
    GIT_LOGPATH=$(echo "$GIT_LOGPATH" | sed "s+tree/$BRANCH_NAME+branches/$BRANCH_NAME+g")

fi

# exporting
svn export $GIT_LOGPATH

}


# main
# choose option interface
while [ $USER_CHOICE != 0 ]; do
	
		echo -e "\n* Choose option: "
		echo "1 - clone by inputing url"
		echo "2 - clone by inputing branch name"
		echo -e "0 - exit script\n"
		read -p 'Option: ' USER_CHOICE

if [ $USER_CHOICE != 0 ]; then 

    # git clone
    if [ $USER_CHOICE == 1 ]; then 
        echo -e "\n**************************************************************************"
        echo -e "			             INPUTING		    	"
        echo -e "**************************************************************************\n"

        # input repository url
        read -p "Input repository ex. https://github.com/kwidzinskio/dir/.../fielname.py ): " GIT_LOGPATH

    	# git subversion export
        git_subversion 

    elif [ $USER_CHOICE == 2 ]; then
	

	read -p "Input username (ex. kwidzinskio): " USERNAME
	read -p "Input repo name (ex. Scrpits): " REPO_NAME
	read -p "Input branch name: " BRANCH_NAME

	BRANCH_NAME_MOD="tree/${BRANCH_NAME}"

	read -p "Do you want to specify file or directory (y/n): " SPECIFY

	if [ $SPECIFY == "y" ] || [ $SPECIFY == "Y" ]; then
    		read -p "Input file or directory name: " DIR_NAME
    		GIT_LOGPATH="https://github.com/${USERNAME}/${REPO_NAME}/${BRANCH_NAME_MOD}/${DIR_NAME}"

	else
    		GIT_LOGPATH="https://github.com/${USERNAME}/${REPO_NAME}/${BRANCH_NAME_MOD}"
	fi

	# git subversion export
	git_subversion

    # leave the game
    elif [ $USER_CHOICE == 0 ]; then
        exit

    else
        true
    fi

fi

done

#-----------------------------------------------------------------------------------------------------------
#                                           End of script
#-----------------------------------------------------------------------------------------------------------

sleep 1

echo -e "\n**************************************************************************"
echo -e ">                               END OF SCRPIT       "
echo -e "**************************************************************************\n"

echo -e "The commands from the script were executed $(date +"%Y.%m.%d %H:%M:%S")\n" 

echo "* To grant permissions to cloned script, run the command: *"
echo -e "sudo chmod +x script_name.sh\n"

echo "* To run script, run the command: *"
echo -e "sudo ./script_name.sh or another command given in Script manual\n"

echo "* To move external module to odooprod addons, run the command: *"
echo -e "cp module_dir /odooprod/custom/addons/module_dir\n"

echo "* To move external module to odootest addons, run the command: *"
echo -e "cp module_dir /odootest/custom/addons/module_dir\n"

echo "* Remember to restart odoo env after moving module, using commands: *"
echo "for odootest: sudo systemctl restart odootest-server.service "
echo -e "for odooprod: sudo systemctl restart odooprod-server.service\n"









