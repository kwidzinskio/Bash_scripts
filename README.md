# List of bash scripts:


## bash_aliases_0.2.0.sh

The script performs task of **adding bash aliases for root and other users**
There are bash aliases repo accesible for non-root users: etc/.bash_aliases and root user: root/.bash_aliases
There are private bash aliases for non-root users: home/USERNAME/.bashrc and root user: root/.bashrc

When root user starts the script:
At first, script creates files to store shared aliases for users: etc/.shared_aliases nad for root: /root/.bash_aliases
Then, both files are filled up with rks bash aliases stored in script (only if is not up to date)

**Interface allows root to:**
[1] - add aliases to shared aliases (etc/.shared_aliases accessible for non-root users)
[2] - add aliases to own aliases (private root/.bash_aliases accessible for root user)
[3] - refresh aliases (allow to refresh access to parallelly made changes)
[4] - show all aliases (list all aliases stored in: etc/.bash_aliases, root/.bash_aliases and root/.bashrc)

**Interface allows non-root to:**
[2] - add aliases to own aliases (private home/USERNAME/.bashrc accessible only for this user)
[3] - refresh aliases (allow to refresh access to parallelly made changes)
[4] - show all aliases (list all aliases stored in: etc/.bash_aliases, home/USERNAME/.bashrc)

**Script should be started with 'source ./bash_aliases_0.2.0.sh' !**



## check_logs_0.2.0.sh

The script performs task of **checking server logs from desired logfile**

**Interface allows root to list logs from:**
[1] - odooprod logfile
[2] - odootest logfile
[3] - fail2ban logfile
[4] - postresql logfile
[5] - nginx logfile
[6] - letsencrypt logfile
[8] - all above logfiles
[9] - custom directory logfile

**With desired options:**
[1] - all logs with ERROR 
[2] - logs with ERROR at specified date
[3] - logs with ERROR at specified date and phrase
[4] - logs at specified date
[5] - logs at specified date and specified phrase

Script saves logs to a file called log_errors_DATE.txt



## create_user_0.2.0.sh

The script performs task of **creating users with root privileges by enabling connection via ssh keys**

**Interface allows root user to:**
[1] - create new user (from scratch - declaring username and ssh key)
[2]-[5] - create user (that username and ssh key are declared in script)
[9] - list all users
[0] - delete chosen user



## fail2ban_install_1.2.0.sh

The script performs task of **installing fail2ban service on Odoo servers with nginx service**
All required packages are installed via Advanced Packaging Tool - using apt-get command

**jail.local is created** and configured for fail2ban service working properly

Installation is being made seamlessly if nginx service is installed, if not script assures to continue
After installation is proceeded, maxretry and bantime parameters are overwritten according to script values



## git_clone_0.1.1.sh

The script performs task of **cloning directories/files from Github to server**

Cloning is proceeded via subversion package (installed automatically if not installed yet)

**Interface allow user to either:**
[1] - declare URL of repo
[2] - declare path: username, branch and optional filename or directory name

Repo is cloned to the same direcotry as script



## nginx_4.0.0.sh

The script performs task of **installing NGINX with SSL certificate for two subdomens**      
Script can either use free SSL certificate from Let's Encrypt or Cloudflare
In order to perform Cloudflare certification prepare cert.pem and key.pem in the same directory as script

**Script performs tasks in that order:**
1. Asks user whether SSL certification is to be proceeded with (a) Let's Encrypt or (b) Cloudflare
2a. Checks if domain points to the same IP as server 
2b. Checks if key.pem and cert.pem are prepared in the same directory as script
3. Lists all sites available in nginx
4. Installs nginx
5. Checks IP access blockade (in etc/odootest-server.conf and etc/odooprod-server.conf)
6. Generating SSL keys (if not generated yet)
7. Updates server and restarts nginx
8a. Installs certbot and Let's Encrypt repository, configurates test and prod instances for certification, declares snippets and performs final nginx configuration
8b. Configurates test and prod instances for certification, declares snippets, moves key.pem and cert.pem to desired directory
9. Restarts nignx service
10. Asks if user want to certificate another domain
11. If not, restarts all services and performs nginx test
12. If nginx test is successful, then proxy mode is enabled (in etc/odootest-server.conf and etc/odooprod-server.conf)



## odoo15_install_0.1.1.sh

The script performs task of **installing two separatelly Odoo's instances**

There are created two python virtual environment

Packages required by Odoo (python modules) are installing using pip based on file requirements.txt becomes from git sources

