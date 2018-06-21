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

Stack.sh 명령 수행을 통해 OpenStack을 설치한다.
```
$ cd ~/devstack
$ ./stack.sh
```

설치 완료 후 동작 확인을 위해 Dashboard에 접속해본다. (ID/Password: admin/nova)

ONOS 연동 확인을 위해 Network/Subnet을 생성해본다.
 ㅇ Network Name: net1, net2
 ㅇ Subnet Name: snet1, snet2
 ㅇ CIDR: 20.1.1.0/24, 20.2.2.0/24
 ㅇ Gateway: 20.1.1.1, 20.2.2.1
 
 
 
ONOS에 접속하여 정상 동작을 확인한다.
```
$ ssh -p 8101 karaf@10.1.1.5
Password authentication
Password: karaf
Welcome to Open Network Operating System (ONOS)!
     ____  _  ______  ____     
    / __ \/ |/ / __ \/ __/   
   / /_/ /    / /_/ /\ \     
   \____/_/|_/\____/___/     
                               
Documentation: wiki.onosproject.org      
Tutorials:     tutorials.onosproject.org 
Mailing lists: lists.onosproject.org     

Come help out! Find out how at: contribute.onosproject.org 

Hit '<tab>' for a list of available commands
and '[cmd] --help' for help on a specific command.
Hit '<ctrl-d>' or type 'system:shutdown' or 'logout' to shutdown ONOS.
onos> openstack-networks 
ID                                      Name                Network Mode        VNI                 Subnets 
90b74fc7-c6e7-4254-830c-ab46ece25f83    net1                VXLAN               96                  [20.1.1.0/24]
84001230-81d4-48dd-9fbd-c7c48ab47814    net2                VXLAN               91                  [20.2.2.0/24]
onos> 
```
 
# Exercise 1: East-west routing
Openstack에서 서로 다른 Network에 속한 VM간 통신이 필요한 경우(=east-west routing), 가상의 router를 생성하여 Network를 연동해야 한다.

Horizon을 통해 Router를 생성한다.
```
onos> openstack-routers 
ID                                      Name                External            Internal
7bfb0e90-faa1-4fbc-8d9a-4167abd66a5d    router              []                  []  
```

Horizon을 통해 생성한 router에 net1, net2를 연결한다. (인터페이스 추가 메뉴를 이용)
```
onos> openstack-routers 
ID                                      Name                External            Internal
7bfb0e90-faa1-4fbc-8d9a-4167abd66a5d    router              []                  [20.1.1.1, 20.2.2.1]

onos> openstack-ports 
ID                                      Network             MAC                 Fixed IPs
d064ef9c-1a29-4b1d-91e9-e5f506f4a212    net2                fa:16:3e:70:46:cc   [20.2.2.1]
1981f54f-86f3-4b56-88e4-6ea0621792a2    net1                fa:16:3e:55:0a:43   [20.1.1.1]
```

net1, net2에 각각 vm을 생성한다.
```
onos> openstack-ports 
ID                                      Network             MAC                 Fixed IPs
be4e9afe-96e4-4c2e-a99d-be055ff1bfa8    net2                fa:16:3e:8c:77:f4   [20.2.2.5]
d064ef9c-1a29-4b1d-91e9-e5f506f4a212    net2                fa:16:3e:70:46:cc   [20.2.2.1]
6134aed6-2a4c-47e1-b00d-6dc5f0dccbe1    net1                fa:16:3e:ba:5e:c3   [20.1.1.5]
1981f54f-86f3-4b56-88e4-6ea0621792a2    net1                fa:16:3e:55:0a:43   [20.1.1.1]
```
 
vm간 ping이 되는 것을 확인한다.
```
Mincheolui-MacBook-Pro:~ mincheolpark$ ssh sdn@172.27.0.3
Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-101-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

99 packages can be updated.
0 updates are security updates.


*** System restart required ***
Last login: Thu Jun 21 07:42:24 2018 from 172.16.101.11
sdn@mcpark-all-in-one:~$ virsh list
 Id    Name                           State
----------------------------------------------------
 3     instance-00000003              running
 4     instance-00000004              running

sdn@mcpark-all-in-one:~$ virsh console 4
Connected to domain instance-00000004
Escape character is ^]

$ ifconfig
eth0      Link encap:Ethernet  HWaddr FA:16:3E:8C:77:F4  
          inet addr:20.2.2.5  Bcast:20.2.2.0  Mask:255.255.255.0
          inet6 addr: fe80::f816:3eff:fe8c:77f4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:96 errors:0 dropped:0 overruns:0 frame:0
          TX packets:516 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:7296 (7.1 KiB)  TX bytes:40846 (39.8 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         20.2.2.1        0.0.0.0         UG    0      0        0 eth0
20.2.2.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
$ ping 20.1.1.5
PING 20.1.1.5 (20.1.1.5): 56 data bytes
64 bytes from 20.1.1.5: seq=0 ttl=64 time=6.455 ms
64 bytes from 20.1.1.5: seq=1 ttl=64 time=1.475 ms
64 bytes from 20.1.1.5: seq=2 ttl=64 time=1.387 ms

--- 20.1.1.5 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 1.387/3.105/6.455 ms
$ 
```

router에서 interface 하나를 삭제하고 ping이 안되는 것을 확인한다.
 
# SONA CLI
 
 
 



