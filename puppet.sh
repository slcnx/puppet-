#!/bin/bash
#
trap 'exit' INT
rpm -q facter &> /dev/null || yum -y -d 0 -e 0 install facter &> /dev/null
[ "$?" -ne "0" ] && echo "please install facter" && exit 1
master_ip=$(facter -p | grep 'ipaddress\>' | awk '{print $3}')
master_fqdn='master.magedu.com'
\cp files/hosts /etc/hosts
\cp -f files/puppet.conf /etc/puppet/puppet.conf
\cp -f files/auth.conf /etc/puppet/auth.conf

[ ! -s puppet_member ] && echo -e "Input all puppet cluster members to \033[32m`pwd`/puppet_member\033[0m file" && exit 0
while read line; do
   [ "$line" == "$master_ip" ]  && sed -i "/$line/d" puppet_member && continue
    if ping -c 1 -W 2 -w 1 $line &> /dev/null; then
       IP[${#IP[@]}]=$line
    else
	sed -i "/$line/d" puppet_member
    fi
done < puppet_member
[ -s puppet_member ] || exit 0

echo -n "Init master: "
echo "$master_ip ${master_fqdn} m" >> /etc/hosts
echo "      server = ${master_fqdn}" >> /etc/puppet/puppet.conf
sed -i '/\[main\]/a listen = true' /etc/puppet/puppet.conf
sed -i "116a path /run \nmethod save\nauth any\nallow ${master_fqdn}" /etc/puppet/auth.conf

rpm -q epel-release &> /dev/null || yum -y -d 0 -e 0 install epel-release &> /dev/null
rpm -q facter puppet-server &> /dev/null || yum -y -d 0 -e 0 install facter puppet puppet-server &> /dev/null
[ -f ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -P '' &> /dev/null
if [ -f ~/.ssh/authorized_keys ]; then
  grep "$(head -c 17  ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys &> /dev/null || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod o=--- ~/.ssh/id_rsa.pub
else
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod o=--- ~/.ssh/id_rsa.pub
fi
hostnamectl set-hostname ${master_fqdn}
systemctl restart puppetmaster.service
systemctl enable puppetmaster.service
echo OK

echo -e " master is \033[1;31m$master_ip\033[0m"

echo "Init puppet agent"
for i in $(seq 0 $[${#IP[@]}-1]); do
	ssh-copy-id -i ~/.ssh/id_rsa.pub ${IP[$i]} &> /dev/null
	ssh ${IP[$i]} 'rpm -q epel-release || yum -y install -d 0 -e 0 epel-release' &> /dev/null
	ssh ${IP[$i]} 'rpm -q facter puppet || yum -y install -d 0 -e 0 facter puppet' &> /dev/null
	ssh ${IP[$i]} "hostnamectl set-hostname agent$[$i+1].magedu.com" &> /dev/null

	grep "agent$[$i+1].magedu.com" /etc/hosts || echo "${IP[$i]} agent$[$i+1].magedu.com a$[$i+1]" >> /etc/hosts
	echo -e " agent$[$i+1] is \033[1;31m${IP[$i]}\033[0m"
done

for i in $(seq 0 $[${#IP[@]}-1]); do
	scp /etc/puppet/puppet.conf ${IP[$i]}:/etc/puppet/puppet.conf
	scp /etc/hosts  ${IP[$i]}:/etc/hosts
	scp /etc/puppet/auth.conf ${IP[$i]}:/etc/puppet/auth.conf
	ssh ${IP[$i]} 'systemctl restart puppetagent.service'
	ssh ${IP[$i]} 'systemctl enable puppetagent.service'
done

