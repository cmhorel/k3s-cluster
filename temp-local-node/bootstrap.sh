grep 'horel-k0s-1' /etc/hosts || echo '192.168.0.204 horel-k0s-1' >> /etc/hosts
grep 'horel-k0s-2' /etc/hosts || echo '192.168.0.168 horel-k0s-2' >> /etc/hosts
grep 'horel-k0s-3' /etc/hosts || echo '192.168.0.4 horel-k0s-3' >> /etc/hosts
echo "K3S_TOKEN"
echo $K3S_TOKEN
echo "K3S_URL"
echo $K3S_URL
curl -sfL https://get.k3s.io | sh -