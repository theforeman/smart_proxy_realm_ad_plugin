# Define network settings and domain information
$interfaceAlias = "Ethernet"
$ipAddress = "192.168.3.60"
$subnetMask = "255.255.255.0"
$gateway = "192.168.3.1"
$dnsServer = "8.8.8.8"
$servers = @("ad01", "ad02", "ad03", "ad04")
$domainName = "LAB.LOCAL"
$adminPassword = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("Administrator", $adminPassword)

# Function to configure network settings
function Configure-Network {
    param (
        [string]$server,
        [string]$ipAddress
    )

    Invoke-Command -ComputerName $server -Credential $using:credential -ScriptBlock {
        $interfaceAlias = $using:interfaceAlias
        $ipAddress = $using:ipAddress
        $subnetMask = $using:subnetMask
        $gateway = $using:gateway
        $dnsServer = $using:dnsServer

        # Set static IP address
        New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress $ipAddress -PrefixLength 24 -DefaultGateway $gateway

        # Set DNS server
        Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses $dnsServer

        # Rename the server
        Rename-Computer -NewName $env:COMPUTERNAME -Restart
    }
}

# Function to install Windows updates
function Install-WindowsUpdates {
    param (
        [string]$server
    )

    Invoke-Command -ComputerName $server -Credential $using:credential -ScriptBlock {
        Install-Module -Name PSWindowsUpdate -Force
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -Install -AcceptAll -AutoReboot
    }
}

# Function to install AD DS role and configure the forest
function Install-ADDSForest {
    param (
        [string]$server
    )

    Invoke-Command -ComputerName $server -Credential $using:credential -ScriptBlock {
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
        Import-Module ADDSDeployment
        Install-ADDSForest -DomainName $using:domainName -SafeModeAdministratorPassword $using:adminPassword -InstallDNS -Force
    }
}

# Function to configure NTP settings
function Configure-NTP {
    param (
        [string]$server
    )

    Invoke-Command -ComputerName $server -Credential $using:credential -ScriptBlock {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "NtpServer" -Value "time.windows.com,0x9"
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name "AnnounceFlags" -Value 5
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" -Name "SpecialPollInterval" -Value 3600
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Value "NTP"
        Restart-Service w32time
    }
}

# Configure network settings and install updates on all servers
$ipAddresses = @("192.168.3.60", "192.168.3.61", "192.168.3.62", "192.168.3.63")
for ($i = 0; $i -lt $servers.Length; $i++) {
    Configure-Network -server $servers[$i] -ipAddress $ipAddresses[$i]
    Install-WindowsUpdates -server $servers[$i]
}

# Install AD DS and configure the forest on the first server
Install-ADDSForest -server $servers[0]

# Wait for the first server to complete the installation and reboot
Start-Sleep -Seconds 300

# Join the remaining servers to the domain and promote them as additional domain controllers
foreach ($server in $servers[1..3]) {
    Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
        Import-Module ADDSDeployment
        Add-Computer -DomainName $using:domainName -Credential $using:credential -Restart
    }

    # Wait for the server to reboot
    Start-Sleep -Seconds 300

    Invoke-Command -ComputerName $server -Credential $credential -ScriptBlock {
        Install-ADDSDomainController -DomainName $using:domainName -SafeModeAdministratorPassword $using:adminPassword -InstallDNS -Force
    }

    # Wait for the server to complete the installation and reboot
    Start-Sleep -Seconds 300
}

# Configure NTP services on all servers
foreach ($server in $servers) {
    Configure-NTP -server $server
}

Write-Host "Active Directory forest and domain controllers have been configured successfully."