#!/bin/bash

#-----------------------------------------------------------------------------------------------------------
#                                     Script functionality
#-----------------------------------------------------------------------------------------------------------

# The script performs task of checking server logs from desired logfile

#-----------------------------------------------------------------------------------------------------------
#                                           Script manual
#-----------------------------------------------------------------------------------------------------------

# Send this file to the server using the command:
# scp check_logs_0.1.0.sh root@server_ip:~/
# Grant permissions to the script:
# sudo chmod +x check_logs_0.1.0.sh
# Execute the file:
# sudo ./check_logs_0.1.0.sh
# As the script executes, provide responses that matches user choice option

#-----------------------------------------------------------------------------------------------------------
#                                                  Script version
#-----------------------------------------------------------------------------------------------------------

# version  0.1.0 [2022-01-13]

#-----------------------------------------------------------------------------------------------------------
#                                  Script parameters and variables
#-----------------------------------------------------------------------------------------------------------

SCRIPT_AUTHOR="Oskar Kwidziński"
SCRIPT_NAME="check_logs_0.1.0.sh"
SCRIPT_VERSION="0.1.0"
DATE=$(date +%d_%m_%y)

# logs directories
ODOOPROD_DIR=/var/log/odooprod/odooprod-server.log  
ODOOTEST_DIR=/var/log/odootest/odootest-server.log  
FAIL2BAN_DIR=/var/log/fail2ban.log
POSTGRES_DIR=/var/log/postgresql/postgresql-12-main.log
NGINX_DIR=/var/log/nginx/error.log
LETSENCRYPT_DIR=/var/log/letsencrypt/letsencrypt.log

LOGS_FILENAME='log_errors'"$DATE"'.txt'
USER_CHOICE=1
LOGS_CHOICE=1
UPDATE=y

#-----------------------------------------------------------------------------------------------------------
#                                              Script launch
#-----------------------------------------------------------------------------------------------------------

echo -e "\n=============================================================================="
echo "                         Launch: ${SCRIPT_NAME}                "
echo "                              version ${SCRIPT_VERSION}            "
echo "                            $(date +"%Y.%m.%d %H:%M:%S")             "
echo "                          Created by: ${SCRIPT_AUTHOR}            "
echo -e "==============================================================================\n"

echo -e "**************************************************************************"
echo -e ">                                SERVER UPDATE                    "
echo -e "**************************************************************************\n"

# server update
while [ $UPDATE != n ] && [ $UPDATE != N ]; do

    read -p "Do you want to update UNIX packages? (y/n) " UPDATE

    if [ "$UPDATE" == "y" ] || [ $UPDATE == Y ]  ; then
	    sudo apt update -y && sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get upgrade -y && sudo apt dist-upgrade -y && sudo apt-get dist-upgrade -y
        UPDATE=n
    fi

done

#-----------------------------------------------------------------------------------------------------------
#                                        Performed actions
#-----------------------------------------------------------------------------------------------------------

echo -e "\n**************************************************************************"
echo -e ">                   CREATING FILE TO INPUT LOGS TO                    "
echo -e "**************************************************************************"
echo " "

# create if does not exist
if [ -f $LOGS_FILENAME ]; then
	rm *log_errors*
fi
touch $LOGS_FILENAME

# print errors log
print_errors () {

        echo -e "\n**************************************************************************"
        echo -e ">                        WRITING $1 LOGS TO FILE            "
        echo -e "**************************************************************************\n"

		echo " " >> $LOGS_FILENAME
		echo "================================================================" >> $LOGS_FILENAME
		echo "		         " $1 "logs" >> $LOGS_FILENAME
		echo "================================================================" >> $LOGS_FILENAME
		echo " " >> $LOGS_FILENAME
		
	if [ $1 == "odooprod" ] || [ $1 == "odootest" ] ; then

            if [ $3 == 1 ]; then
                awk '$4=="ERROR" {f=1} $4=="INFO" {f=0} f' $2 >> $LOGS_FILENAME
            elif [ $3 == 2 ]; then
		while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
			echo "Generating logs from:" $START_DATE
			awk -v date="${START_DATE}" '$1==date && $4=="ERROR" {f=1} $4=="INFO" {f=0} f' $2 >> $LOGS_FILENAME
           	        START_DATE=$(date -I -d "$START_DATE + 1 day")
		done
	    elif [ $3 == 3 ]; then
                awk ' /'"$5"'/ && $4=="ERROR" {f=1} $4=="INFO" {f=0} f' $2 >> $LOGS_FILENAME
            elif [ $3 == 4 ]; then
		while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
	                awk -v date="${START_DATE}" ' /'"$5"'/ && $1==date && $4=="ERROR" {f=1} $4=="INFO" {f=0} f ' $2 >> $LOGS_FILENAME
              		START_DATE=$(date -I -d "$START_DATE + 1 day")
                done
	    fi

        elif [ $1 == "fail2ban" ]; then

            if [ $3 == 1 ]; then
                awk '/fail2ban/' $2 >> $LOGS_FILENAME
            elif [ $3 == 2 ]; then
		while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
                	awk -v date="${START_DATE}" ' /fail2ban/ && $1==date {f=1} f ' $2 >> $LOGS_FILENAME
            		START_DATE=$(date -I -d "$START_DATE + 1 day")
		done
	    elif [ $3 == 3 ]; then
                awk ' /'"$5"'/ ' $2 >> $LOGS_FILENAME
            elif [ $3 == 4 ]; then
                 while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
			awk -v date="${START_DATE}" ' /'"$5"'/ && $1==date ' $2 >> $LOGS_FILENAME
           		START_DATE=$(date -I -d "$START_DATE + 1 day")
		 done
	    fi

        elif [ $1 == "postgres" ]; then

            if [ $3 == 1 ]; then
                awk '/ERROR/' $2 >> $LOGS_FILENAME
            elif [ $3 == 2 ]; then
		 while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
          	         echo "Generating logs from:" $START_DATE
                	 awk -v date="${START_DATE}" ' /ERROR/ && $1==date ' $2 >> $LOGS_FILENAME
			 START_DATE=$(date -I -d "$START_DATE + 1 day")
		 done
            elif [ $3 == 3 ]; then
                awk ' /'"$5"'/ && /ERROR/ ' $2 >> $LOGS_FILENAME
            elif [ $3 == 4 ]; then
                 while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                         echo "Generating logs from:" $START_DATE                
			 awk -v date="${START_DATE}" ' /'"$5"'/ && /ERROR/ && $1==date ' $2 >> $LOGS_FILENAME
               		 START_DATE=$(date -I -d "$START_DATE + 1 day")
                 done
	     fi

        elif [ $1 == "nginx" ]; then

            if [ $3 == 1 ]; then
                awk '/error/' $2 >> $LOGS_FILENAME
            elif [ $3 == 2 ]; then
                while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do
			echo "Generating logs from:" $START_DATE
	       	        date_start_modified=$(echo "$START_DATE" | sed 's+-+/+g')
			awk -v date="${date_start_modified}" ' /error/ && $1==date ' $2 >> $LOGS_FILENAME
            		START_DATE=$(date -I -d "$START_DATE + 1 day")
		done
	    elif [ $3 == 3 ]; then
                awk ' /'"$5"'/ && /error/ ' $2 >> $LOGS_FILENAME
            elif [ $3 == 4 ]; then
		while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do
			echo "Generating logs from:" $START_DATE
                        date_start_modified=$(echo "$START_DATE" | sed 's+-+/+g')
                	awk -v date="${date_start_modified}" ' /'"$5"'/ && /error/ && $1==date ' $2 >> $LOGS_FILENAME
			START_DATE=$(date -I -d "$START_DATE + 1 day")
                done
            fi

        elif [ $1 == "letsencrypt" ]; then

            if [ $3 == 1 ]; then
                awk '/error/' $2 >> $LOGS_FILENAME
            elif [ $3 == 2 ]; then
		while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
	                awk -v date="${START_DATE}" ' /error/ && $1==date ' $2 >> $LOGS_FILENAME
			START_DATE=$(date -I -d "$START_DATE + 1 day")
                done
            elif [ $3 == 3 ]; then
                awk ' /'"$5"'/ && /error/ ' $2 >> $LOGS_FILENAME
            elif [ $3 == 4 ]; then
                while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
			awk -v date="${START_DATE}" ' /'"$5"'/ && /error/ && $1==date ' $2 >> $LOGS_FILENAME
            		START_DATE=$(date -I -d "$START_DATE + 1 day")
		done
	    fi
                
        elif [ $1 == "custom_directory" ]; then
            if [ $3 == 1 ]; then
                while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
			awk ' /'"$START_DATE"'/ ' $2 >> $LOGS_FILENAME
			START_DATE=$(date -I -d "$START_DATE + 1 day")
                done
            elif [ $3 == 2 ]; then
                awk ' /'"$5"'/  ' $2 >> $LOGS_FILENAME
            elif [ $3 == 3 ]; then
	        while [ $START_DATE != $(date -I -d "$END_DATE + 1 day") ]; do 
                        echo "Generating logs from:" $START_DATE
		        awk ' /'"$5"'/ && /'"$START_DATE"'/ ' $2 >> $LOGS_FILENAME
			START_DATE=$(date -I -d "$START_DATE + 1 day")
                done
            fi

        fi

        echo "*** DONE ***"
}



# choose log options interface
choose_log_options () {

echo " "
echo -e "**************************************************************************"
echo -e ">                          CHOOSE LOGS OPTIONS            "
echo -e "**************************************************************************"
echo " "

echo -e "\n* Choose logs option: "

# known directories
if [ "$USER_CHOICE" -ge 1 ] && [ "$USER_CHOICE" -le 8 ]; then
    
    echo "1 - all logs with '$1' "
    echo "2 - logs with '$1' at specified date"
    echo "3 - logs with '$1' and specified phrase"
    echo "4 - logs with '$1' at specified date and phrase"
    echo -e "0 - back\n"
	read -p 'Option: ' LOGS_CHOICE
    echo " "

    if [ "$LOGS_CHOICE" == 2 ] ; then
	read -p "Input start date in YYYY-MM-DD format: " START_DATE
	read -p "Input end date in YYYY-MM-DD format: " END_DATE
    elif [ "$LOGS_CHOICE" == 3 ] ; then
        read -p "Input phrase: " PHRASE
    elif [ "$LOGS_CHOICE" == 4 ] ; then
        read -p "Input start date in YYYY-MM-DD format: " START_DATE
        read -p "Input end date in YYYY-MM-DD format: " END_DATE
        read -p "Input phrase: " PHRASE
    fi

# custom directory
else    
        		                
    echo "1 - logs at specified date"
    echo "2 - logs with specified phrase"
    echo "3 - logs at specified date and with phrase"
    echo -e "0 - back\n"
	read -p 'Option: ' LOGS_CHOICE   
    echo " "

    if [ "$LOGS_CHOICE" == 1 ] ; then
        read -p "Input start date in YYYY-MM-DD format: " START_DATE
        read -p "Input end date in YYYY-MM-DD format: " END_DATE
    elif [ "$LOGS_CHOICE" == 2 ] ; then                    
        read -p "Input phrase: " PHRASE
    elif [ "$LOGS_CHOICE" == 3 ] ; then
        read -p "Input start date in YYYY-MM-DD format: " START_DATE
        read -p "Input end date in YYYY-MM-DD format: " END_DATE
        read -p "Input phrase: " PHRASE
    fi
    
fi

}



# main
while [ $USER_CHOICE != 0 ]; do

    echo " "
    echo -e "**************************************************************************"
    echo -e ">                            CHOOSE OPERATION            "
    echo -e "**************************************************************************"
    echo " "
	
        # choose log directory interface
		echo -e "\n* Choose logfile directory: "
		echo "1 - odooprod"
		echo "2 - odootest"
        echo "3 - fail2ban"
        echo "4 - postresql"
        echo "5 - nginx"
        echo "6 - letsencrypt"
        echo "8 - all above"
        echo "9 - custom directory"
		echo -e "0 - exit script\n"
		read -p 'Option: ' USER_CHOICE

        # execute script
        if [ $USER_CHOICE != 0 ]; then

                    # odooprod and odootest
                    if [ "$USER_CHOICE" -ge 1 ] && [ "$USER_CHOICE" -le 2 ]; then

                        choose_log_options ERROR

                            if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 4 ]; then
                                
                                # odooprod logs
		                        if [ $USER_CHOICE == 1 ]; then
			                        print_errors "odooprod" $ODOOPROD_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE

                                # odootest logs    
		                        elif [ $USER_CHOICE == 2 ]; then
			                        
					        print_errors "odootest" $ODOOTEST_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE
                                
		                        fi
                            fi

                    # fail2ban 
                    elif [ "$USER_CHOICE" == 3 ] ; then           
                
                        choose_log_options FAIL2BAN
                        
                        if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 4 ]; then
	                    
                                   print_errors "fail2ban" $FAIL2BAN_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE    
                               
                        fi

                    # postgres 
                    elif [ "$USER_CHOICE" == 4 ] ; then           
            
                        choose_log_options ERROR
                   
                        if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 4 ]; then
	                               
                                   print_errors "postgres" $POSTGRES_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE   
                               
                        fi
                
                     # nginx   
                     elif [ "$USER_CHOICE" == 5 ] ; then            
            
                        choose_log_options error
                   
                        if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 4 ]; then
	                               
                                   print_errors "nginx" $NGINX_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE   
                               
                        fi
 
                     # letsencrypt
                     elif [ "$USER_CHOICE" == 6 ] ; then          
            
                        choose_log_options error
                   
                        if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 4 ]; then
	                               
                                   print_errors "letsencrypt" $LETSENCRYPT_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE   
                               
                        fi

                      # all above
                      elif [ "$USER_CHOICE" == 8 ] ; then           
                
                        choose_log_options error
                       
                        if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 4 ]; then
	
                                   print_errors "odooprod" $ODOOPROD_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE
                                   print_errors "odootest" $ODOOTEST_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE
                                   print_errors "fail2ban" $FAIL2BAN_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE     
                                   print_errors "postgres" $POSTGRES_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE
                                   print_errors "nginx" $NGINX_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE
                                   print_errors "letsencrypt" $LETSENCRYPT_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE 
                               
                        fi

                    # custom directory
                    elif [ "$USER_CHOICE" == 9 ] ; then          
                
		                choose_log_options                
                        
                        if [ "$LOGS_CHOICE" -ge 1 ] && [ "$LOGS_CHOICE" -le 3 ]; then
                                   echo " "
	                               read -p "Input custom directory: " CUSTOM_DIR
                                   print_errors "custom_directory" $CUSTOM_DIR $LOGS_CHOICE $START_DATE $PHRASE $END_DATE       
                        fi

                    fi

        # leave the game
        else    

            exit
        fi

       
done