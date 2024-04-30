grep 'horel-k0s-1' /etc/hosts || echo '192.168.0.204 horel-k0s-1' >> /etc/hosts
grep 'horel-k0s-2' /etc/hosts || echo '192.168.0.168 horel-k0s-2' >> /etc/hosts
grep 'horel-k0s-3' /etc/hosts || echo '192.168.0.4 horel-k0s-3' >> /etc/hosts
grep 'K3S_TOKEN' /etc/environment || echo "K3S_TOKEN=$K3S_TOKEN" >> /etc/environment
echo "K3S_TOKEN"
echo $K3S_TOKEN
grep 'K3S_URL' /etc/environment || echo "K3S_URL=$K3S_URL" >> /etc/environment
echo "K3S_URL"
echo $K3S_URL
echo "INSTALL_K3S_EXEC"
echo $INSTALL_K3S_EXEC
curl -sfL https://get.k3s.io | sh -s - --node-ip 192.168.0.177 --flannel-iface eth1