<#
    Install Active Directory Domain Services,
    and setup example.org forest.
#>
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$NTDSpath = "C:\Windows\NTDS"
$SYSVolPath = "C:\Windows\SYSVOL"

Install-ADDSForest `
    -DatabasePath $NTDSpath `
    -LogPath $NTDSpath `
    -Sysvolpath $SYSVolPath `
    -DomainName "example.org" `
    -NoRebootOnCompletion:$true `
    -InstallDns `
    -Confirm:$false `
    -SafeModeAdministratorPassword (ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force)   

Restart-Computer -Force