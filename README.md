# Pre-requisite
Ubuntu 16.04가 설치된 VM

SONA를 설치할 User에 대한 sudo 권한 부여 (하기 Example의 경우 sdn User에 대한 sudo 권한을 부여한다.
```
root@mcpark-all-in-one:~# visudo
...
# User privilege specification
root    ALL=(ALL:ALL) ALL
sdn     ALL=(ALL) NOPASSWD:ALL
...
```

Nameserver 설정
```
$ cat /etc/resolv.conf
# Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
nameserver 8.8.8.8
```
apt repo update 및 git 설치
```
$ sudo apt-get update
$ sudo apt-get install -y git
```

#All-in-One SONA 설치
Devstack Queens를 Clone 한다.
```
$ git clone -b stable/queens https://git.openstack.org/openstack-dev/devstack
```

Devstack 설정을 위한 local.conf를 생성한다. 하기 Sample에서 IP 정보만 변경한다.
```
[[local|localrc]]
HOST_IP=10.1.1.26
SERVICE_HOST=10.1.1.26
RABBIT_HOST=10.1.1.26
DATABASE_HOST=10.1.1.26
Q_HOST=10.1.1.26
 
ADMIN_PASSWORD=nova
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
SERVICE_TOKEN=$ADMIN_PASSWORD
 
DATABASE_TYPE=mysql
 
# Log
USE_SCREEN=True
SCREEN_LOGDIR=/opt/stack/logs/screen
LOGFILE=/opt/stack/logs/xstack.sh.log
LOGDAYS=1
# Images
FORCE_CONFIG_DRIVE=True
 
# Networks
Q_ML2_TENANT_NETWORK_TYPE=vxlan
Q_ML2_PLUGIN_MECHANISM_DRIVERS=onos_ml2
Q_ML2_PLUGIN_TYPE_DRIVERS=flat,vlan,vxlan
ML2_L3_PLUGIN=onos_router
NEUTRON_CREATE_INITIAL_NETWORKS=False
enable_plugin networking-onos https://github.com/sonaproject/networking-onos.git
ONOS_MODE=allinone
 
# Services
ENABLED_SERVICES=n-cpu,placement-client,neutron,key,nova,n-api,n-cond,n-sch,n-novnc,n-cauth,placement-api,g-api,g-reg,q-svc,horizon,rabbit,mysql
 
 
NOVA_VNC_ENABLED=True
VNCSERVER_PROXYCLIENT_ADDRESS=$HOST_IP
VNCSERVER_LISTEN=$HOST_IP
 
LIBVIRT_TYPE=qemu
 
# Branches
GLANCE_BRANCH=stable/queens
HORIZON_BRANCH=stable/queens
KEYSTONE_BRANCH=stable/queens
NEUTRON_BRANCH=stable/queens
NOVA_BRANCH=stable/queens
```
