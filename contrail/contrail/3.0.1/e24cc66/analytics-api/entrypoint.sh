#!/bin/bash
touch /etc/contrail/contrail-keystone-auth.conf
if [ -n "$KEYSTONE_SERVER" ]; then
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE auth_host $KEYSTONE_SERVER
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE auth_protocol http
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE auth_port 35357
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_user $ADMIN_USER
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_password $ADMIN_PASSWORD
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_token $ADMIN_TOKEN
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE admin_tenant_name $ADMIN_TENANT
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE insecure false
  ./openstack-config --set /etc/contrail/contrail-keystone-auth.conf KEYSTONE memcache_servers $MEMCACHED_SERVER:11211
fi
./openstack-config --set /etc/contrail/vnc_api_lib.ini auth AUTHN_SERVER $KEYSTONE_SERVER


myip=`ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
myip_int=`ifconfig $INTERFACE_INT | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
./openstack-config --set /etc/contrail/contrail-analytics-api.conf DEFAULTS host_ip $myip

if [ -n "$DISCOVERY_SERVER" ]; then
    ./openstack-config --set /etc/contrail/contrail-analytics-api.conf DISCOVERY disc_server_ip $DISCOVERY_SERVER
fi

if [ -n "$ANALYTICS_REDIS_SERVER" ]; then
    sed -i "/\[REDIS\]/a server = $ANALYTICS_REDIS_SERVER" /etc/contrail/contrail-analytics-api.conf
    ./openstack-config --set /etc/contrail/contrail-analytics-api.conf REDIS server $ANALYTICS_REDIS_SERVER
fi

if [ -n "$CASSANDRA_SERVER" ]; then
    IFS=',' read -ra NODE <<< "$CASSANDRA_SERVER"
    CASSANDRA_SERVER_LIST=""
    for i in "${NODE[@]}";do
        if [ -z $CASSANDRA_SERVER_LIST ]; then
            CASSANDRA_SERVER_LIST=`echo $i:9042`
        else
            CASSANDRA_SERVER_LIST=`echo $CASSANDRA_SERVER_LIST,$i:9042`
        fi
    done
    ./openstack-config --set /etc/contrail/contrail-analytics-api.conf DEFAULTS cassandra_server_list $CASSANDRA_SERVER_LIST

fi
hname=`hostname`
/usr/sbin/contrail-provision-analytics --host_name $hname --host_ip $myip --api_server_ip $CONFIG_API_SERVER --api_server_port 8082 --oper add --admin_user $ADMIN_USER --admin_password $ADMIN_PASSWORD --admin_tenant_name $ADMIN_TENANT

exec "$@"
