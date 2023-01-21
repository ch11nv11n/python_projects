#Connect to Exchange Management Shell on the shc-exch-hybrid server and creates mailbox

#This variable truncates output if not set to -1
if ($FormatEnumerationLimit -ne -1) {$FormatEnumerationLimit = -1}

#Silently imports custom module
Import-Module ProgressBarCountDownFunction -Verbose:$false

#Asking for user credentials    #Step 8
$AdminCreds = Get-Credential -Message "Please enter your Windows Credentials`n(NOT O365 CREDENTIALS)"

#Uri for Exchange Management Shell
$EMSServerUri = "http://server.domain.com/Powershell"

#Enters EMS session
$EMSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $EMSServerUri -Credential $AdminCreds
#Enter-PSSession $EMSSession

#AAD uri
$AADUri = "server.domain.com"

#Enters AAD session
$AADSession = New-PSSession -ComputerName $AADUri -Credential $AdminCreds

#First sync        #Step 9
Invoke-Command -Session $AADSession -ScriptBlock { Start-AdSyncSyncCycle -PolicyType Delta }

#Calls progress bar function
Progress-Bar 60

#Imports Exchange Management Shell commands to local powershell - SILENCE
Import-PSSession $EMSSession -AllowClobber -CommandName Enable-RemoteMailbox | Out-Null

#Creates mailbox in cloud-based service for existing user in the on-premise AD and specifies the SMTP address of mailbox 
#in the service that this user is associated with        #Step 10
$Continuing = Read-Host -Prompt "Are you continuing a user setup from Part 1 - Creating AD User |y or n|"
if (($Continuing -eq "y") -or ($Continuing -eq "Y") -or ($Continuing -eq "yes") -or ($Continuing -eq "YES")) {
    Enable-RemoteMailbox -Identity $FullUPN -RemoteRoutingAddress "$($UPN)@domain.com" | Format-List -Property UserPrincipalName,RemoteRoutingAddress,RemoteRecipientType,EmailAddresses
}

elseif (($Continuing -eq "n") -or ($Continuing -eq "N") -or ($Continuing -eq "no") -or ($Continuing -eq "NO")) {
    #firstname - if first letter not capitalized, capitalize it
    $FirstName = Read-Host -Prompt "`nPlease enter user First Name"
    if ($FirstName.Substring(0,1) -cmatch "[a-z]") {
        $FirstName = $FirstName.Substring(0,1).ToUpper() + $FirstName.Substring(1)
    }

    #lastname - if first letter not capitalized, capitalize it
    $LastName = Read-Host -Prompt "`nPlease enter user Last Name"
    if ($LastName.Substring(0,1) -cmatch "[a-z]") {
        $LastName = $LastName.Substring(0,1).ToUpper() + $LastName.Substring(1)
    }
    
    #userprincipalname/ email - sets all chars to lowercase
    $UPN = $FirstName.Substring(0,1).ToLower() + $LastName.ToLower()
    $FullUPN = "$($UPN)@domain.com"

    Enable-RemoteMailbox -Identity "$($UPN)@domain.com" -RemoteRoutingAddress "$($UPN)@domain.com" `
    | Format-List -Property UserPrincipalName,RemoteRoutingAddress,RemoteRecipientType,EmailAddresses
}

#Disconnects from exchange management shell session
Remove-PSSession $EMSSession

Progress-Bar 180

#Re-runs sync after creating mailbox        #Step 11 SILENCE
Invoke-Command -Session $AADSession -ScriptBlock { Start-AdSyncSyncCycle -PolicyType Delta }

#Disconnects from AAD session
Remove-PSSession $AADSession

do {
    $ValidContinueOnYorN = $false
    $ContinueOnYorN = Read-host -Prompt "Would you like to proceed to Part 3 - O365 License Assignment |y or n|"

    if (($ContinueOnYorN -eq "y") -or ($ContinueOnYorN -eq "Y") -or ($ContinueOnYorN -eq "yes") -or ($ContinueOnYorN -eq "YES")) {
        & .\Pt3-OfficeLicenseAssignment.ps1
        $ValidContinueOnYorN = $true
    }

    elseif (($ContinueOnYorN -eq "n") -or ($ContinueOnYorN -eq "N") -or ($ContinueOnYorN -eq "no") -or ($ContinueOnYorN -eq "NO")) {
        Write-Host "`nExiting Script..." -ForegroundColor Yellow
        $ValidContinueOnYorN = $true
    }

    else {Write-Host "You did not enter a valid selection!`n" -ForegroundColor Red}
} Until ($ValidContinueOnYorN)
