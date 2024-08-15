#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Introduction text
echo -e "${GREEN}This script tests and validates DNS functionality between the local Linux host (Ubuntu 22.04) and the remote Windows Domain on the same network.${NC}"
echo -e "${GREEN}It checks if the DNS server is reachable, if it can resolve the domain, and if the DNS configuration is correct.${NC}"
echo -e "${GREEN}Additionally, it verifies the required DNS records that ADDS registers so clients can discover the domain.${NC}"
echo -e "${GREEN}For more information, visit:${NC}"
echo -e "${YELLOW}https://www.example.com/dns-validation-guide${NC}"
echo ""

# Explanation of major DNS records
echo -e "${GREEN}Active Directory Domain Services (ADDS) publishes several important DNS records that are essential for domain functionality.${NC}"
echo -e "${GREEN}These records include SRV records and A records, which are used by clients to locate domain controllers and other services.${NC}"
echo -e "${GREEN}Here are some of the major DNS records and their purposes:${NC}"
echo -e "${YELLOW}_ldap._tcp.dc._msdcs.<domain>${NC} - ${GREEN}Used by clients to locate domain controllers for LDAP services.${NC}"
echo -e "${YELLOW}_kerberos._tcp.dc._msdcs.<domain>${NC} - ${GREEN}Used by clients to locate domain controllers for Kerberos authentication.${NC}"
echo -e "${YELLOW}_ldap._tcp.gc._msdcs.<domain>${NC} - ${GREEN}Used by clients to locate global catalog servers for LDAP services.${NC}"
echo -e "${YELLOW}_kerberos._tcp.<domain>${NC} - ${GREEN}Used by clients to locate Kerberos servers.${NC}"
echo -e "${YELLOW}_kpasswd._tcp.<domain>${NC} - ${GREEN}Used by clients to locate Kerberos password change servers.${NC}"
echo -e "${YELLOW}_kpasswd._udp.<domain>${NC} - ${GREEN}Used by clients to locate Kerberos password change servers (UDP).${NC}"
echo ""

# Explanation of how Linux tools use these DNS records
echo -e "${GREEN}Linux tools such as adcli, kerberos, krb5-workstation, and ldap use these DNS records to interact with Active Directory.${NC}"
echo -e "${GREEN}Here is how some of these tools use the DNS records:${NC}"
echo -e "${YELLOW}adcli${NC} - ${GREEN}Uses the _ldap._tcp.dc._msdcs.<domain> record to locate domain controllers for joining the domain and managing computer accounts.${NC}"
echo -e "${YELLOW}Kerberos (krb5-workstation)${NC} - ${GREEN}Uses the _kerberos._tcp.dc._msdcs.<domain> and _kerberos._tcp.<domain> records to locate Kerberos servers for authentication.${NC}"
echo -e "${YELLOW}LDAP${NC} - ${GREEN}Uses the _ldap._tcp.dc._msdcs.<domain> and _ldap._tcp.gc._msdcs.<domain> records to locate domain controllers and global catalog servers for directory services.${NC}"
echo -e "${YELLOW}kpasswd${NC} - ${GREEN}Uses the _kpasswd._tcp.<domain> and _kpasswd._udp.<domain> records to locate Kerberos password change servers.${NC}"
echo ""

# Prompt user for detailed trace logs
echo -e "${BLUE}Would you like to see detailed trace logs of DNS packets? (yes/no)${NC}"
read -r show_trace_logs

# Define the domain controller and domain
DNS_DOMAIN="lab.local"
DOMAIN_CONTROLLER="192.168.3.1"

# Verify that DNS is configured correctly
if ! grep -q "nameserver $DOMAIN_CONTROLLER" /etc/resolv.conf; then
    echo -e "${RED}DNS is not configured correctly. Please update /etc/resolv.conf with the domain controller's IP address.${NC}" 
    echo ""
    echo -e "${YELLOW}Example configuration:${NC}"
    echo ""
    echo -e "${YELLOW}    nameserver $DOMAIN_CONTROLLER${NC}"
    echo -e "${YELLOW}    search $DNS_DOMAIN${NC}"
    echo ""
    exit 1
fi

# Check if the DNS server is reachable
if ! ping -c 1 $DOMAIN_CONTROLLER &> /dev/null; then
    echo -e "${RED}The DNS server ($DOMAIN_CONTROLLER) is not reachable. Please check your network connection.${NC}"
    exit 1
else
    echo -e "${GREEN}The DNS server ($DOMAIN_CONTROLLER) is reachable.${NC}"
fi

# Try to resolve the domain
if ! host $DNS_DOMAIN &> /dev/null; then
    echo -e "${RED}Could not resolve the domain ($DNS_DOMAIN). Please check DNS configuration.${NC}"
    exit 1
else
    echo -e "${GREEN}The domain ($DNS_DOMAIN) was successfully resolved.${NC}"
fi

# Validate DNS functionality
echo -e "${GREEN}Validating DNS functionality...${NC}"
if ! nslookup $DNS_DOMAIN $DOMAIN_CONTROLLER &> /dev/null; then
    echo -e "${RED}DNS functionality validation failed. The domain ($DNS_DOMAIN) could not be resolved using the DNS server ($DOMAIN_CONTROLLER).${NC}"
    exit 1
else
    echo -e "${GREEN}DNS functionality validation succeeded. The domain ($DNS_DOMAIN) was successfully resolved using the DNS server ($DOMAIN_CONTROLLER).${NC}"
fi

# Verify required DNS records for ADDS
echo -e "${GREEN}Verifying required DNS records for ADDS...${NC}"

REQUIRED_RECORDS=(
    "_ldap._tcp.dc._msdcs.$DNS_DOMAIN"
    "_kerberos._tcp.dc._msdcs.$DNS_DOMAIN"
    "_ldap._tcp.gc._msdcs.$DNS_DOMAIN"
    "_kerberos._tcp.$DNS_DOMAIN"
    "_kpasswd._tcp.$DNS_DOMAIN"
    "_kpasswd._udp.$DNS_DOMAIN"
)

for record in "${REQUIRED_RECORDS[@]}"; do
    echo -e "${YELLOW}Querying DNS record: $record${NC}"
    if [ "$show_trace_logs" == "yes" ]; then
        dig +trace +short $record @$DOMAIN_CONTROLLER | xxd
    else
        dig +short $record @$DOMAIN_CONTROLLER
    fi
    if ! host -t SRV $record $DOMAIN_CONTROLLER &> /dev/null; then
        echo -e "${RED}Required DNS record $record is missing.${NC}"
        exit 1
    else
        echo -e "${GREEN}Required DNS record $record is present.${NC}"
    fi
done

echo -e "${GREEN}All required DNS records for ADDS are present.${NC}"
echo -e "${GREEN}DNS functionality test and validation completed successfully.${NC}"