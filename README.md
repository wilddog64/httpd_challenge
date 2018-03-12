# HTTP Challenge Assigment

This assignment try to accomplish following requirments

* Deploy standard Centos 7 base image
* Check Apache and mod_ssl are installed, if not install them
* DocumentRoot for hello.html is /apps/hello-http/html
* Application should server page at 443; use default cert is fine
* Disable TSL 1.0
* Place Apache log in /var/log/weblogs/http
* After script successfully deploys the application, verify apache load the page and http status is 200
* The caller to the script should be able to determine if script execute successfully or fail
* Use regular script languages rather configuration management tools such as Puppet, Chef, or Ansible

## Script Use

Bash shell script language is choosen for the simpilcity

## Provision Tools

This assignment use Vagrant and virtualbox to provision CentOS Operating System, in order for anyone to run it, Vagranthas to be installed. If you are on

* Mac - brew cask install vagrant virtualbox
* Other plaforms - [Vagrant Download](https://www.vagrantup.com/downloads.html), [VirtualBox Download](https://www.virtualbox.org/wiki/Downloads)

### Optional

If you want to save time by running only one command repeatly testing vagrant box provision, you can install a ```vagrant-pristine``` plugin by ```vagrant plugin install vagrant-pristine```

## Execute Provision Script

At the root of the project

* To bring up a CentOS with proper Apache, mod_ssl, and the serve page, run ```vagrant up```
* To rerun provision, run ```vagrant provision```
* To restart vagrant box and provision, run ```vagrant reload --provision```
* To destory vagrant box, run ```vagrant destroy -f```
* To destroy and re-provision vagrant box in one command, run ```vagrant pristine -f``` (assuming you install vagrant-pristine plugin)

## Implementation Detail
This project can be splited into the following sections for how to deploy Apache/SSL to CentOS

### Packages Deployment
The following packages are needed in order to successfully deploy an Apache httpd to successfully serve pages

* httpd 2.4.*
* mod_ssl
* policycoreutils-python (for managing and applying selinux policy)
* nmap-ncat (for testing and checking a given port is listening)

4 functions: 

    install_apache, 
    install_modssl,
    install_policycoreutils_python,
    install_nmap_ncat 

are used to handle packages installation. These functions will check if target packages are installed or not before they install anything. The function will bail out if package cannot be successfully installed

### SSL Configuration Deployment
In order for Apache SSL to work, the following steps has to be taken,

* Generate a self-signed certicate (the default one does not work). Once can following [this article](https://wiki.centos.org/HowTos/Https) to create them. For this project, we generates and store under files/certs directory
* Copy self-signed certs to ```/etc/pki/tls/certs/``` and ```/etc/pki/tls/private/```
* Configure Apache to use self-signed certs

2 functions:

    deploy_ssl_configs, 
    deploy_selfsigned_certs 
    
handles the above requirments

note:
*  httpd.conf that deploy_ssl_configs push to also change the ```DocumentRoot``` and ```DirectoryIndex``` settings to the new values

## Serve Pages Deployment
In order for our custom configuration to work, the default welcome.conf has to be removed, we also need to copy hello.html to DocumentRoot. Also we have to change default logs location bases on what httpd.conf tells apache.

functions:

    remove_welcome_conf
    deploy_indexhtml
    relocate_http_log

are used to handle these requirements

### Apply selinux Policy To A New DocumentRoot
CentOS has selinux in order to secure the operation system. By default Apache configure DocumentRoot to /var/www directory. Any new DocumentRoot outside this context will not work due to selinux policy. We have to apply proper selinux policy to our new root in order for Apache to serve. This function serves the purpose

    apply_selinux_policy

This function first check to see if DocumentRoot has selinux attributes existed, if not, ```semanage``` and ```restorecon``` will be called to apply a proper policy

### Start Httpd service

If everything above works well, then it is the time to start httpd service. Function ```start_httpd_service``` serves the purpose. This function will first check if httpd service running, if not then start it.

If for any reason this function fails to start httpd service, it will executes ```systemctl status httpd.service``` to display more information.

### Check SSL Port Is Listening, Pages Serve, And Good Http Status

Once httpd service start successfully, we have to check the followings to ensure this is a successfully deployment.

* 443 is listening
* Apache loads our page and http status is 200

These are done by the following functions

    check_port443_listening
    check_httpd_return_200
## Project Directory Structure
    .
    ├── README.md
    ├── Vagrantfile
    ├── files
    │   ├── certs
    │   │   ├── server.crt
    │   │   └── server.key
    │   ├── hello.html
    │   └── httpd
    │       ├── httpd.conf
    │       └── ssl.conf
    └── scripts
        └── install-apache-mod_ssl.sh
