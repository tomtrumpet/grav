#!/bin/bash

set -e

function configure_admin() {
    export GRAV_HOME=/var/www/grav-admin

    # Setup admin user (if supplied)
    if [ -z $ADMIN_USER ]; then
        echo "[ INFO ] No Grav admin user details supplied"
    else
        if [ -e $GRAV_HOME/user/accounts/$ADMIN_USER.yaml ]; then
            echo "[ INFO ] Grav admin user already exists"
        else
            echo "[ INFO ] Setting up Grav admin user"
            cd $GRAV_HOME

            sudo -u www-data bin/plugin login newuser \
                 --user=${ADMIN_USER} \
                 --password=${ADMIN_PASSWORD-"Pa55word"} \
                 --permissions=${ADMIN_PERMISSIONS-"b"} \
                 --email=${ADMIN_EMAIL-"admin@domain.com"} \
                 --fullname=${ADMIN_FULLNAME-"Administrator"} \
                 --title=${ADMIN_TITLE-"SiteAdministrator"}
        fi
    fi
}

function configure_nginx() {
    echo "[ INFO ] Configuring Nginx"

    echo "[ INFO ]  > Updating to listen on port 80"
    sed -i 's/#listen 80;/listen 80;/g' /etc/nginx/conf.d/default.conf

    # # Setup SSL in the Nginx config
    # echo "[ INFO ]  > Adding SSL settings to Nginx config"
    # sed -i 's/server_name localhost;/\
    # server_name localhost;\
    # listen 443 ssl;\
    # ssl_certificate \/var\/lib\/acme\/live\/'${DOMAIN}'\/fullchain;\
    # ssl_certificate_key \/var\/lib\/acme\/live\/'${DOMAIN}'\/privkey;/g' /etc/nginx/conf.d/default.conf
    # echo "[ INFO ]  > Updating Nginx to listen on port 443"
    #
    # echo "[ INFO ]  > Setting server_name to" ${DOMAIN} www.${DOMAIN}
    # sed -i 's/server_name localhost/server_name '${DOMAIN}' 'www.${DOMAIN}'/g' /etc/nginx/conf.d/default.conf
}

function start_services() {
    echo "[ INFO ] Starting nginx"
    bash -c 'service php7.2-fpm start; nginx -g "daemon off;"'
}


function main() {
    configure_admin
    configure_nginx
    start_services
}


main "$@"
