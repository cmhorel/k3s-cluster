grep 'horel-k0s-1' /etc/hosts || echo '192.168.0.204 horel-k0s-1' >> /etc/hosts
grep 'horel-k0s-2' /etc/hosts || echo '192.168.0.168 horel-k0s-2' >> /etc/hosts
grep 'horel-k0s-3' /etc/hosts || echo '192.168.0.4 horel-k0s-3' >> /etc/hosts
grep 'horel-k0s-4' /etc/hosts || echo '192.168.0.177 horel-k0s-3' >> /etc/hosts
grep 'horel-k0s-5' /etc/hosts || echo '192.168.0.121 horel-k0s-3' >> /etc/hosts
grep 'K3S_TOKEN' /etc/environment || echo "K3S_TOKEN=$K3S_TOKEN" >> /etc/environment
echo "K3S_TOKEN"
echo $K3S_TOKEN
grep 'K3S_URL' /etc/environment || echo "K3S_URL=$K3S_URL" >> /etc/environment
echo "K3S_URL"
echo $K3S_URL
echo "INSTALL_K3S_EXEC"
echo $INSTALL_K3S_EXEC
swapoff /dev/sda2
#systemctl mask "dev-\*.swap"
mkdir -p  /etc/rancher/k3s/
#Doesn't seem to even try?
# echo 'mirrors:
#   horel-k0s-3:
#     endpoint:
#       - "https://horel-k0s-3:30000"' > /etc/rancher/k3s/registries.yaml
curl -sfL https://get.k3s.io | sh -s - --node-ip 192.168.0.177 --flannel-iface eth1

# unset K3S_URL
# curl -sfL https://get.k3s.io |  sh -s - server \
#  --embedded-registry # --server https://horel-k0s-2:6443