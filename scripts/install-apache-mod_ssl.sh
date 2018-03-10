#!/bin/bash -xv

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

function update_document_root() {
    docRoot='/apps/hello-http/html'
    if [[ ! -e $docRoot ]]; then
        mkdir -p $docRoot
    fi
    # inline update DocumentRoot
    perl -i~ -ple 's/(DocumentRoot) ".*"/$1 "\/apps\/hello-http\/html"/g if /\/var\/www\/html/ && /DocumentRoot/' /etc/httpd/conf/httpd.conf
    grep '\/apps\/hello-http\/html' /etc/httpd/conf/httpd.conf > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo DocumentRoot successfully updated
    else
        echo failed to update DocumentRoot
        exit -1
    fi
}

function remove_welcome_conf() {
    if [[ -e /etc/httpd/conf.d/welcome.conf ]]; then
        rm -vf /etc/httpd/conf.d/welcome.conf
    else
        echo /etc/httpd/conf.d/welcome.conf removed already, skip
    fi
}

function deploy_ssl_configs() {
    if [[ $(diff -q /vagrant/files/httpd/httpd.conf /etc/httpd/conf/httpd.conf > /dev/null 2>&1) != 0 ]]; then
        cp /vagrant/files/httpd/httpd.conf /etc/httpd/conf/httpd.conf
    else
        echo httpd.conf copy complete already, skip
    fi

    if [[ $(diff -q /vagrant/files/httpd/ssl.conf /etc/httpd/conf.d/ssl.conf > /dev/null 2>&1) != 0 ]]; then
        cp /vagrant/files/httpd/ssl.conf /etc/httpd/conf.d/ssl.conf
    else
        echo ssl.conf copy complete already, skip
    fi

}

main() {
    install_apache
    install_modssl
    install_perl
    update_document_root
    remove_welcome_conf
    deploy_ssl_configs
}

# --- execution part ----
main
