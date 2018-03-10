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
* Other plaforms - [Vagrant Download](https://www.vagrantup.com/downloads.html), [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Optional
If you want to save time by running only one command repeatly testing vagrant box provision, you can install a ```vagrant-pristine``` plugin by ```vagrant plugin install vagrant-pristine```

## Execute Provision Script

At the root of the project

* To bring up a CentOS with proper Apache, mod_ssl, and the serve page, run ```vagrant up```
* To rerun provision, run ```vagrant provision```
* To restart vagrant box and provision, run ```vagrant reload --provision```
* To destory vagrant box, run ```vagrant destroy -f```
* To destroy and re-provision vagrant box in one command, run ```vagrant pristine -f``` (assuming you install vagrant-pristine plugin)

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
