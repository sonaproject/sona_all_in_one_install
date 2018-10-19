sudo docker rm -f onos
sudo docker run --name onos --network host -itd  opensona/onos-sona-nightly-docker
sleep 20
sudo rm -rf ~/.ssh/known_hosts
sshpass -p karaf ssh -o "StrictHostKeyChecking=no" -p 8101 karaf@192.168.56.103 cfg set org.onosproject.openstacknode.impl.DefaultOpenstackNodeHandler ovsdbPortNum 6650
sleep 2

sudo ovs-vsctl set-manager ptcp:6650

curl --user onos:rocks -X POST -H "Content-Type:application/json" -d "@/opt/stack/devstack/sona_config" http://localhost:8181/onos/openstacknode/configure
sshpass -p karaf ssh -o "StrictHostKeyChecking=no" -p 8101 karaf@localhost openstack-node-init -a
sshpass -p karaf ssh -o "StrictHostKeyChecking=no" -p 8101 karaf@localhost openstack-nodes
