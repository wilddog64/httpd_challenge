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

function remove_welcome_conf() {
    if [[ -e /etc/httpd/conf.d/welcome.conf ]]; then
        rm -vf /etc/httpd/conf.d/welcome.conf
    else
        echo /etc/httpd/conf.d/welcome.conf removed already, skip
    fi
}

function deploy_ssl_configs() {
    diff -q /vagrant/files/httpd/httpd.conf /etc/httpd/conf/httpd.conf > /dev/null 2>&1
    if [[ $? != 0 ]]; then
        cp /vagrant/files/httpd/httpd.conf /etc/httpd/conf/httpd.conf
    else
        echo httpd.conf copy complete already, skip
    fi

    diff -q /vagrant/files/httpd/ssl.conf /etc/httpd/conf.d/ssl.conf > /dev/null 2>&1
    if [[ $? != 0 ]]; then
        cp /vagrant/files/httpd/ssl.conf /etc/httpd/conf.d/ssl.conf
    else
        echo ssl.conf copy complete already, skip
    fi
}

function deploy_selfsigned_certs() {
    if [[ ! -e /etc/pki/tls/certs/server.crt ]]; then
        cp /vagrant/files/certs/server.crt /etc/pki/tls/certs/server.crt
    else
        echo server.crt deployed already, skip
    fi

    if [[ ! -e /etc/pki/tls/private/server.key ]]; then
        cp /vagrant/files/certs/server.key /etc/pki/tls/private/server.key
    else
        echo server.key deployed already, skip
    fi
}

function deploy_indexhtml() {
    docRoot='/apps/hello-http/html'
    if [[ ! -e $docRoot ]]; then
        mkdir -p $docRoot
    fi
    if [[ ! -e $docRoot/index.html ]]; then
        cp /vagrant/files/index.html $docRoot/index.html
        chown -R apache.apache $docRoot
    else
        echo $docRoot/index.html deployed already, skip
    fi
}

function install_policycoreutils_python() {
    rpm -qa policycoreutils-python | grep install_policycoreutils_python
    if [[ $? == 1 ]]; then
        yum install -y policycoreutils-python
        if [[ $? != 0 ]]; then
            echo error installing policycoreutils-python package
            exit -1
        fi
    else
        echo policycoreutils-python already installed
    fi
}

function apply_selinux_policy() {
    ls -lZ /apps | grep 'unconfined_u:object_r:httpd_sys_content_t:s0'
    if [[ $? != 0 ]]; then
        semanage fcontext -a -t httpd_sys_content_t '/apps(/.*)'
        restorecon -Rv /apps
    else
        echo httpd_sys_content_d already applied, skip
    fi
}

function start_httpd_service() {
    ps aux | grep '[h]ttpd'
    if [[ $? != 0 ]]; then
        service httpd start
        if [[ $? != 0 ]]; then
            echo fail to start httpd service
            systemctl status httpd.service
            exit -1
        fi
    else
        echo httpd already started, skip
    fi
}
main() {
    install_apache
    install_modssl
    install_policycoreutils_python
    remove_welcome_conf
    deploy_ssl_configs
    deploy_selfsigned_certs
    deploy_indexhtml
    apply_selinux_policy
    start_httpd_service
}

# --- execution part ----
main
