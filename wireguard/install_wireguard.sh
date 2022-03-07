MACHINE=$1


# update base system
apt update
apt upgrade -y

# install wireguard
apt install -y wireguard

# create private and public keys
cd /etc/wireguard/ 
umask 077 .
wg genkey | tee servidor_private.key | wg pubkey > servidor_public.key 
chmod 600 -R ../wireguard/ 

# create wireguard configuration file 
touch wg0.conf 
PRIVATE_KEY=$(cat servidor_private.key) #extract private key and save in a rutime variable
echo "[Interface]" >> wg0.conf 
echo "PrivateKey = $PRIVATE_KEY" >> wg0.conf 
echo "Address = 10.1.0.$MACHINE/12 " >> wg0.conf 
echo "ListenPort = 41480 " >> wg0.conf 
echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  " >> wg0.conf 
echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE " >> wg0.conf 

# enabled and start service
systemctl enable wg-quick@wg0 
systemctl start wg-quick@wg0 


# forwarding enable
sysctl -w net.ipv4.ip_forward=1
