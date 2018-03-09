#!/bin/bash

function install_apache() {
    if [[ $(rpm -qa httpd 2>&1 > /dev/null | grep httpd) == 0 ]]; then
        if [[ $(yum install httpd -y) != 0 ]]; then
            echo error installing apache-httpd package
            exit -1
        fi
    else
        echo apache-httpd already installed
    fi
}

function install_modssl() {
    if [[ $(rpm -qa mod_ssl 2>&1 > /dev/null | grep mod_ssl) == 0 ]]; then
        yum install mod_ssl -y
        if [[ $(yum install mod_ssl -y) != 0 ]]; then
            echo error installing mod_ssl package
            exit -1
        fi
    else
        echo apache-httpd already installed
    fi
}

main() {
    install_apache
    install_modssl
}

# --- execution part ----
main
