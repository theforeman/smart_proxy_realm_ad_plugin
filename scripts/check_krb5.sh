#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Introduction text
echo -e "${GREEN}This script verifies connectivity and functionality between krb5-workstation tools and the Active Directory (AD) domain.${NC}"
echo -e "${GREEN}It includes steps to check Kerberos configuration, obtain a Kerberos ticket, and verify the ticket.${NC}"
echo -e "${GREEN}For more information, visit:${NC}"
echo -e "${YELLOW}https://www.example.com/kerberos-setup-guide${NC}"
echo ""

# Ask user for REALM NAME and DC server IP address
read -p "Enter your Kerberos REALM NAME (e.g., EXAMPLE.COM): " REALM

while true; do
    read -p "Enter your Domain Controller (DC) server IP address (e.g., 192.168.1.1): " KDC
    if [[ $KDC =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        break
    else
        echo -e "${RED}Please enter a valid IP address.${NC}"
    fi
done

# Define the domain and realm
DNS_DOMAIN=$(echo $REALM | tr '[:upper:]' '[:lower:]')
ADMIN_SERVER=$KDC

# If kerberos is not installed, install it on ubuntu 22.04
if ! command -v kinit &> /dev/null; then
    echo -e "${YELLOW}Installing krb5-user package...${NC}"
    sudo apt-get update
    sudo apt-get install -y krb5-user
fi

# Step 1: Configure Kerberos
echo -e "${GREEN}Step 1: Configure Kerberos${NC}"
echo -e "${YELLOW}Creating and editing /etc/krb5.conf...${NC}"

# Create /etc/krb5.conf
sudo bash -c "cat > /etc/krb5.conf <<EOF
[libdefaults]
    default_realm = $REALM
    dns_lookup_realm = false
    dns_lookup_kdc = true

[realms]
    $REALM = {
        kdc = $KDC
        admin_server = $ADMIN_SERVER
    }

[domain_realm]
    .$DNS_DOMAIN = $REALM
    $DNS_DOMAIN = $REALM
EOF"

# Display the contents of /etc/krb5.conf
echo -e "${YELLOW}Contents of /etc/krb5.conf:${NC}"
cat /etc/krb5.conf

# Ask if the configuration is correct
read -p "Is the Kerberos configuration correct? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Please edit /etc/krb5.conf manually and rerun the script.${NC}"
    exit 1
fi

# Step 2: Check DNS Resolution for KDC and Admin Server
echo -e "${GREEN}Step 2: Check DNS Resolution for KDC and Admin Server${NC}"
echo -e "${YELLOW}Checking DNS resolution for $KDC...${NC}"
if host $KDC &> /dev/null; then
    echo -e "${GREEN}DNS resolution for $KDC succeeded.${NC}"
else
    echo -e "${RED}DNS resolution for $KDC failed. Please check your DNS configuration.${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking DNS resolution for $ADMIN_SERVER...${NC}"
if host $ADMIN_SERVER &> /dev/null; then
    echo -e "${GREEN}DNS resolution for $ADMIN_SERVER succeeded.${NC}"
else
    echo -e "${RED}DNS resolution for $ADMIN_SERVER failed. Please check your DNS configuration.${NC}"
    exit 1
fi

# Check NTP synchronization, using ./check_ntp_sync.sh
./check_ntp_sync.sh $ADMIN_SERVER $DNS_DOMAIN

# Write status to /tmp/ntp_sync_status.txt
NTP_SYNC_STATUS=$(cat /tmp/ntp_sync_status.txt)
# Check if not defined
if [ -z "$NTP_SYNC_STATUS" ]; then
    echo -e "${RED}Error: NTP synchronization status could not be determined.${NC}"
fi
echo -e "${YELLOW}NTP synchronization status: $NTP_SYNC_STATUS${NC}"

if [ "$NTP_SYNC_STATUS" != "synchronized" ]; then
    echo -e "${RED}Continuing with NTP unsynchronized can give unpredictable results.${NC}"
    read -p "Do you want to continue? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        echo -e "${RED}Please synchronize your system time and rerun the script.${NC}"
        exit 1
    fi
fi

# Step 3: Obtain a Kerberos Ticket
echo -e "${GREEN}Step 3: Obtain a Kerberos Ticket${NC}"
echo -e "${YELLOW}Running kinit to obtain a Kerberos ticket...${NC}"

while true; do
    read -p "Enter your Kerberos username: " USERNAME
    if [[ "$USERNAME" == *"@"* ]]; then
        echo -e "${RED}Please enter only the username without the domain (e.g., 'username' instead of 'username@domain').${NC}"
    else
        break
    fi
done

read -s -p "Enter your Kerberos password: " PASSWORD
echo ""
echo $PASSWORD | kinit $USERNAME@$REALM


# Verify Kerberos Ticket
echo -e "${YELLOW}Verifying Kerberos ticket...${NC}"
if ! klist &> /dev/null; then
    echo -e "${RED}No valid Kerberos ticket found. Please obtain a ticket using kinit.${NC}"
    exit 1
fi

# Test Kerberos Authentication
echo -e "${YELLOW}Testing Kerberos authentication...${NC}"
if ! kvno host/$ADMIN_SERVER@$DNS_DOMAIN &> /dev/null; then
    echo -e "${RED}Kerberos authentication failed. Server not found in Kerberos database.${NC}"
    echo -e "${RED}Please check your Kerberos configuration and ensure the server is registered in the Kerberos database.${NC}"
    exit 1
else
    echo -e "${GREEN}Kerberos authentication succeeded.${NC}"
fi


# Conclusion
echo -e "${GREEN}Kerberos connectivity and functionality with the AD domain have been verified successfully.${NC}"
echo -e "${GREEN}You can now authenticate using Kerberos.${NC}"
echo -e "${GREEN}For more information, visit:${NC}"
echo -e "${YELLOW}https://www.example.com/kerberos-setup-guide${NC}"

# Explain What can happen if NTP sync is not done
# Give some examples of what can go wrong, 

# NTP_SYNC_STATUS check then display text

if [ "$NTP_SYNC_STATUS" != "synchronized" ]; then
    echo -e "${RED}Warning: NTP synchronization issues can severely impact Kerberos functionality.${NC}"
    echo -e "${YELLOW}Here are some examples of what can go wrong if NTP sync is not properly configured:${NC}"
    
    # Example 1: Authentication Failures
    echo -e "${YELLOW}1. Authentication Failures:${NC}"
    echo -e "${YELLOW}   Kerberos relies on time-sensitive tickets for authentication. If the time difference between the client and the KDC exceeds the allowed limit, authentication requests will fail.${NC}"
    echo -e "${YELLOW}   This can prevent users from logging in, accessing network resources, or using services that rely on Kerberos authentication.${NC}"
    
    # Example 2: Ticket Expiration Issues
    echo -e "${YELLOW}2. Ticket Expiration Issues:${NC}"
    echo -e "${YELLOW}   Kerberos tickets have specific lifetimes. If the system clocks are not synchronized, tickets may appear expired or not yet valid.${NC}"
    echo -e "${YELLOW}   This can cause issues with renewing tickets or accessing resources that require valid tickets.${NC}"
    
    # Example 3: Service Disruptions
    echo -e "${YELLOW}3. Service Disruptions:${NC}"
    echo -e "${YELLOW}   Many services depend on Kerberos for authentication. If Kerberos fails due to time synchronization issues, these services may become unavailable.${NC}"
    echo -e "${YELLOW}   This can impact critical applications, file shares, email systems, and more.${NC}"
    
    # Example 4: Increased Administrative Overhead
    echo -e "${YELLOW}4. Increased Administrative Overhead:${NC}"
    echo -e "${YELLOW}   Administrators may need to spend significant time troubleshooting and resolving authentication issues caused by NTP problems.${NC}"
    echo -e "${YELLOW}   Ensuring proper NTP configuration can save time and reduce the risk of authentication-related incidents.${NC}"
    
    # Example 5: Security Risks
    echo -e "${YELLOW}5. Security Risks:${NC}"
    echo -e "${YELLOW}   Time synchronization is crucial for security protocols. Unsynchronized clocks can lead to vulnerabilities and potential security breaches.${NC}"
    echo -e "${YELLOW}   Proper NTP configuration helps maintain the integrity and security of the authentication"
    echo -e "${YELLOW}   infrastructure.${NC}"

    echo -e "${RED}It is highly recommended to synchronize your system time with the domain controller.${NC}"
    echo -e "${RED}Please refer to the following resources for guidance:${NC}"
    echo -e "${YELLOW}https://www.example.com/ntp-sync-guide${NC}"
    echo -e "${YELLOW}https://www.example.com/dns-configuration${NC}"
fi
