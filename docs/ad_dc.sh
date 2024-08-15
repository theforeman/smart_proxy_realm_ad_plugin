# 1. Configure NTP on Windows DC:
# Set the DC to use its own clock as the time source:

w32tm /config /manualpeerlist:"0.pool.ntp.org,0x1" /syncfromflags:manual /reliable:YES /update
Restart-Service w32time

# 2. Configure Ubuntu 22.04:
# Install the NTP client package on your Ubuntu server:

make shell

apt-get update 
apt-get install ntp

# Edit the NTP configuration file:
DC_IP_ADDRESS=192.168.3.1

# 
sed -i "s/server ntp.ubuntu.com/server $DC_IP_ADDRESS/g" /etc/ntp.conf
