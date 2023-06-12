#!/bin/bash

exec > >(tee /var/log/userdata.log|logger -t userdata -s 2>/dev/console) 2>&1

sudo yum update -y
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-17-amazon-corretto-devel.x86_64
sudo yum install -y wget
sudo yum install -y git
sudo yum install -y build-essential
sudo yum install -y gcc
sudo yum install -y tmux

sudo su
sudo adduser minecraft
mkdir /opt/minecraft/
mkdir /opt/minecraft/server/
mkdir /opt/minecraft/tools/
cd /opt/minecraft/server

sudo wget -O /opt/minecraft/server/server.jar https://piston-data.mojang.com/v1/objects/15c777e2cfe0556eef19aab534b186c0c6f277e1/server.jar
echo "eula=true" | sudo tee /opt/minecraft/server/eula.txt

mkdir /opt/minecraft/tools/mcrcon
cd /opt/minecraft/tools/mcrcon
git clone https://github.com/Tiiffi/mcrcon.git
cd mcrcon

make
sudo make install

cd /opt/minecraft/server
touch /opt/minecraft/server/server.properties
cat <<EOT >> /opt/minecraft/server/server.properties
enable-rcon=true
rcon.password=testtest
EOT


sudo chown -R minecraft:minecraft /opt/minecraft/


sudo tee /etc/systemd/system/minecraft.service <<EOT
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
Nice=5
KillMode=none
SuccessExitStatus=0 1
InaccessibleDirectories=/root /sys /srv /media -/lost+found
NoNewPrivileges=true
WorkingDirectory=/opt/minecraft/server
ReadWriteDirectories=/opt/minecraft/server
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
ExecStop=/usr/local/bin/mcrcon -p testtest -w 5 stop

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service





