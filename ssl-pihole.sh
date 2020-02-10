#!/bin/bash
echo"================================================"
echo"============= DNS Over SSL PIHOLE =============="
echo"============== Installer Armbian ==============="
echo"================================================"
echo""
echo "Konfigurasi Arsitektur "
sudo dpkg --add-architecture armhf >/dev/null 2>&1
echo "Konfigurasi Arsitektur Selesai"
echo "Update Repo"
sudo apt-get update >/dev/null 2>&1
echo "Update Repo Selelsai"
echo"Install libc6"
sudo apt-get install libc6:armhf >/dev/null 2>&1
echo "Install libc6 Selesai"
echo"Mengunduh File SSL"
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz >/dev/null 2>&1
tar -xvzf cloudflared-stable-linux-arm.tgz >/dev/null 2>&1
sudo cp ./cloudflared /usr/local/bin >/dev/null 2>&1
sudo chmod +x /usr/local/bin/cloudflared >/dev/null 2>&1
echo"Mengunduh File SSL Selesai"
echo "Cek Versi Cloudflared"
cloudflared -v
echo "Membuat User Cloudflared"
sudo useradd -s /usr/sbin/nologin -r -M cloudflared >/dev/null 2>&1
echo "Menyetel Konfigurasi"
echo "CLOUDFLARED_OPTS=--port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query" > /etc/default/cloudflared
sudo chown cloudflared:cloudflared /etc/default/cloudflared >/dev/null 2>&1
sudo chown cloudflared:cloudflared /usr/local/bin/cloudflared >/dev/null 2>&1
echo "[Unit]
Description=cloudflared DNS over HTTPS proxy
After=syslog.target network-online.target

[Service]
Type=simple
User=cloudflared
EnvironmentFile=/etc/default/cloudflared
ExecStart=/usr/local/bin/cloudflared proxy-dns $CLOUDFLARED_OPTS
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/cloudflared.service 

sudo systemctl enable cloudflared >/dev/null 2>&1
sudo systemctl start cloudflared >/dev/null 2>&1
sudo systemctl status cloudflared >/dev/null 2>&1
echo "Menyetel Konfigurasi Selesai"
echo "Mengetes DNS Over SSL"
dig @127.0.0.1 -p 5053 google.com
echo "Instalasi Selesai"
echo "Port SSL 5053"
