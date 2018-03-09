#!/bin/bash

function install_apache() {
    rpm -qa httpd | grep httpd
    if [[ $? == 1 ]]; then
        yum install httpd -y
        if [[ $? != 0 ]]; then
            echo error installing apache-httpd package
            exit -1
        fi
    else
        echo apache-httpd already installed
    fi
}

function install_modssl() {
    rpm -qa mod_ssl 2>&1 > /dev/null | grep mod_ssl
    if [[ $? == 1 ]]; then
        yum install mod_ssl -y
        if [[ $? != 0 ]]; then
            echo error installing mod_ssl package
            exit -1
        fi
    else
        echo apache-httpd already installed
    fi
}


function install_perl() {
    rpm -qa perl 2>&1 > /dev/null | grep perl
    if [[ $? == 1 ]]; then
        yum install perl -y
        if [[ $? != 0 ]]; then
            echo error installing perl package
            exit -1
        fi
    else
        echo apache-httpd already installed
    fi
}

main() {
    install_apache
    install_modssl
    install_perl
}

# --- execution part ----
main
