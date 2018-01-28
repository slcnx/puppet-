#!/bin/bash
#
exec_() {
	ssh-copy-id -i ~/.ssh/id_rsa.pub root@${IP}
	ssh root@${IP} 'rm -fr /etc/yum.repos.d/*'
	ssh root@${IP} 'iptables -F'
	ssh root@${IP} 'setenforce 0'
	scp `pwd`/files/CentOS-Base.repo root@${IP}:/etc/yum.repos.d/
}

read -p 'init environment? ' choice
sed -i 's@\r@@g' `pwd`/files/CentOS-Base.repo
if [ "$choice" == "y" ]; then
	rm -fr /etc/yum.repos.d/*
	cp `pwd`/files/CentOS-Base.repo /etc/yum.repos.d/
	[ -f  ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa -b 768 -f ~/.ssh/id_rsa -P ''
	[ -f  ~/.ssh/id_rsa.pub ] || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

	IP=$(ifconfig | head -n 2 | tail -n 1 | awk '{print $2}')
	exec_
else
	read -p 'Ener a IP need to be inited: ' IP
	exec_
fi

