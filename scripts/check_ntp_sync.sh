#!/usr/bin/env bash

# Check if arguments are empty
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <DOMAIN_CONTROLLER> <DNS_DOMAIN>"
    echo "not synchronized" > /tmp/ntp_sync_status.txt
    return 1
fi

# DOMAIN_CONTROLLER: IP address of the domain controller
DOMAIN_CONTROLLER=$1
# DNS_DOMAIN: DNS domain name
DNS_DOMAIN=$2

if [ -z "$DOMAIN_CONTROLLER" ] || [ -z "$DNS_DOMAIN" ]; then
    echo "Usage: $0 <DOMAIN_CONTROLLER> <DNS_DOMAIN>"
    echo "not synchronized" > /tmp/ntp_sync_status.txt
    return 1
fi

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Introduction text
echo -e "${GREEN}This script checks the synchronization of your system time with the domain controller.${NC}"
echo -e "${GREEN}It verifies DNS configuration and attempts to resolve the domain controller.${NC}"
echo -e "${GREEN}If the time difference exceeds acceptable limits, it provides guidance on how to investigate and resolve the issue.${NC}"
echo -e "${GREEN}For more information, visit:${NC}"
echo -e "${YELLOW}https://www.example.com/ntp-sync-guide${NC}"
echo -e "${YELLOW}https://www.example.com/dns-configuration${NC}"
echo ""
 
# Verify that DNS is configured correctly
if ! grep -q "nameserver $DOMAIN_CONTROLLER" /etc/resolv.conf; then
    echo "DNS is not configured correctly. Please update /etc/resolv.conf with the domain controller's IP address." 
    echo ""
    echo "Example configuration:"
    echo ""
    echo "    nameserver $DOMAIN_CONTROLLER"
    echo "    search $DNS_DOMAIN"
    echo ""
    echo "not synchronized" > /tmp/ntp_sync_status.txt
    return 1
fi

# Try to resolve the domain
if ! host $DOMAIN_CONTROLLER &> /dev/null; then
    echo "Could not resolve the domain controller. Please check DNS configuration."
    echo "not synchronized" > /tmp/ntp_sync_status.txt
    return 1
fi

# Ensure ntpdate is installed
if ! command -v ntpdate &> /dev/null; then
    echo -e "${RED}Error: ntpdate could not be found.${NC}"
    echo -e "${YELLOW}Resolution: Installing ntpdate...${NC}"
    sudo apt-get update && sudo apt-get install -y ntpdate
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}ntpdate has been successfully installed.${NC}"
    else
        echo -e "${RED}Failed to install ntpdate. Please check your network connection and package manager settings.${NC}"
        echo "not synchronized" > /tmp/ntp_sync_status.txt
        return 1
    fi
fi

# Get the time from the domain controller
domain_time=$(ntpdate -q $DOMAIN_CONTROLLER | grep -oP '(?<=offset )[^ ]+')
 
# Ensure domain_time is not empty
if [ -z "$domain_time" ]; then
    echo -e "${RED}Error: Unable to retrieve time offset from the domain controller.${NC}"
    echo "not synchronized" > /tmp/ntp_sync_status.txt
    return 1
fi

# Dump the domain_time variable as hex
echo -e "${YELLOW}Hex dump of domain_time:${NC}"
echo "$domain_time" | xxd

# Convert domain time offset to a floating-point number
domain_time_offset=$(echo "$domain_time" | awk '{print $1}')

# Dump the domain_time_offset variable as hex
echo -e "${YELLOW}Hex dump of domain_time_offset:${NC}"
echo "$domain_time_offset" | xxd

# Ensure domain_time_offset is a valid floating-point number
# It should be a decimal number like: +11.605469 

# Parse the number of float using python.
# Parse the float string into a property float type in python
# If the float is valid, it will return the float value

if python -c "print($domain_time_offset)" &> /dev/null; then
    echo -e "${GREEN}Time offset from the domain controller: $domain_time_offset seconds.${NC}"
else
    echo -e "${RED}Error: Unable to parse the time offset from the domain controller.${NC}"
    echo "not synchronized" > /tmp/ntp_sync_status.txt
    return 1
fi


# Check if the time difference is within acceptable limits (e.g., 5 seconds)
# The time is in decimal form
if (( $(echo "$domain_time_offset <= 5" | bc -l) )); then
    echo -e "${GREEN}Time is synchronized with the domain controller.${NC}"
    echo "synchronized" > /tmp/ntp_sync_status.txt
fi