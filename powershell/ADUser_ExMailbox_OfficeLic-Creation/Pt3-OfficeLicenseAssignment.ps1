#This thrid part of the script assigns an Office license if desired

#This variable truncates output if not set to -1
if ($FormatEnumerationLimit -ne -1) {$FormatEnumerationLimit = -1}

#Connects to Azure AD for Office 365 subscription        Step 13
$O365Creds = Get-Credential -Message "Enter Office 365 Credentials"

#If the MSOnline module is not on the machine, then install the module. This is needed to use the AD cmdlets following this command 
if (!(Get-Module -ListAvailable -Name "MSOnline")) {
    Install-Module -Name "MSOnline" -Scope CurrentUser -Confirm:$False
    Write-Host "`nMSOnline module loaded successfully...`n" -ForegroundColor Yellow
}

Connect-MsolService -Credential $O365Creds
    

do {
    #Sets a flag var
    $assignLicenseValid = $false
    
    #Sets var to user input        Step 12
    $Continuing = Read-Host -Prompt "`nAre you continuing license assignment from  Part 2 - Creating Mailbox |y or n|"

    

    #follows this course if user selects yes
    if (($Continuing -eq "y") -or ($Continuing -eq "Y") -or ($Continuing -eq "yes") -or ($Continuing -eq "YES")) {
        
        Write-Host "`nCurrently assigning License for $FullUPN..." -ForegroundColor Green
       

        
        #Lists current # of licences for each type        Step 14
        Write-Host "`nAvailable Office Licenses = ((ActiveUnits + WarningUnits) - ConsumedUnits)" -ForegroundColor Green
        Get-MsolAccountSku | Out-String -Stream


        #Display license selection menu to user        Step 15
        Write-Host "Select type of license you are assigning below`n"
        Write-Host "`t`t    1. E3 License         (ENTERPRISEPACK)
                    2. F1 License         (DESKLESSPACK)
                    3. Power BI Standard  (POWER_BI_STANDARD)
                    4. Visio              (VISIOCLIENT)
                    5. Project Online Pro (PROJECTPROFESSIONAL)"
        
        #Sets licType var to user selection given in menu above
        do {
            #seting vars to types of Office licenses we have
            $E3Lic = ":ENTERPRISEPACK"
            $F1Lic = ":DESKLESSPACK"
            $PowerBILic = ":POWER_BI_STANDARD"
            $VisioLic = ":VISIOCLIENT"
            $ProjectLic = ":PROJECTPROFESSIONAL"
            
            #Asks user to enter selection and setting a flag var for licSelection menu
            $LicType = Read-Host -Prompt "`nPlease make licence selection"
            $validLicSelection = $false

            switch($LicType) {
                1 {$LicType = $E3Lic
                    $validLicSelection = $true
                }

                2 {$LicType = $F1Lic
                    $validLicSelection = $true
                }

                3 {$LicType = $PowerBILic
                    $validLicSelection = $true
                }

                4 {$LicType = $VisioLic
                    $validLicSelection = $true
                }

                5 {$LicType = $VisioLic
                    $validLicSelection = $true
                }

                default {Write-Host "Error: Invalid license selection`n" -ForegroundColor Red}
            }
        } until ($validLicSelection)

        #Sets account's country code in the Office portal (required before assigning a license)
        Set-MsolUser -UserPrincipalName $FullUPN -UsageLocation US

        #Assigns license to user created and setting license to the user selection above        Step 16
        Set-MsolUserLicense -UserPrincipalName $FullUPN -AddLicenses $LicType

        #Changing flag to true to end loop if user gets licensed successfully
        $userLicTest = Get-MsolUser -UserPrincipalName $FullUPN

        if ($userLicTest.IsLicensed) {
            Write-Host "The user $($FullName) has been successfully assigned an $($LicType) licence!!"  -ForegroundColor Green
            $assignLicenseValid = $true
        }
        
        else {
            Write-Host "The user $($FullName) could not be issued a license.`n"
        }
  }      

    #If user does not want to assign license, display that the program is exiting and changing the flag to end the loop
    elseif (($Continuing -eq "n") -or ($Continuing -eq "N") -or ($Continuing -eq "no") -or ($Continuing -eq "NO")) {
        $FirstName = Read-Host -Prompt "`nPlease enter user First Name"
        if ($FirstName.Substring(0,1) -cmatch "[a-z]") {
            $FirstName = $FirstName.Substring(0,1).ToUpper() + $FirstName.Substring(1)}

        $LastName = Read-Host -Prompt "`nPlease enter user Last Name"
        if ($LastName.Substring(0,1) -cmatch "[a-z]") {
            $LastName = $LastName.Substring(0,1).ToUpper() + $LastName.Substring(1)}

        #userprincipalname/ email - sets all chars to lowercase
        $UPN = $FirstName.Substring(0,1).ToLower() + $LastName.ToLower()
        $FullUPN = "$($UPN)@schoolhealth.com"

        #follows this course if user selects no
        Write-Host "`nCurrently assigning License for $FullUPN..." -ForegroundColor Green
        
         #Lists current # of licences for each type        Step 14
        Write-Host "`nAvailable Office Licenses = ((ActiveUnits + WarningUnits) - ConsumedUnits)" -ForegroundColor Green
        Get-MsolAccountSku | Out-String -Stream


        #Display license selection menu to user        Step 15
        Write-Host "Select type of license you are assigning below`n"
        Write-Host "`t`t    1. E3 License         (ENTERPRISEPACK)
                    2. F1 License         (DESKLESSPACK)
                    3. Power BI Standard  (POWER_BI_STANDARD)
                    4. Visio              (VISIOCLIENT)
                    5. Project Online Pro (PROJECTPROFESSIONAL)"
        
        #Sets licType var to user selection given in menu above
        do {
            #seting vars to types of Office licenses we have
            $E3Lic = ":ENTERPRISEPACK"
            $F1Lic = ":DESKLESSPACK"
            $PowerBILic = ":POWER_BI_STANDARD"
            $VisioLic = ":VISIOCLIENT"
            $ProjectLic = ":PROJECTPROFESSIONAL"
            
            #Asks user to enter selection and setting a flag var for licSelection menu
            $LicType = Read-Host -Prompt "`nPlease make licence selection"
            $validLicSelection = $false

            switch($LicType) {
                1 {$LicType = $E3Lic
                    $validLicSelection = $true
                }

                2 {$LicType = $F1Lic
                    $validLicSelection = $true
                }

                3 {$LicType = $PowerBILic
                    $validLicSelection = $true
                }

                4 {$LicType = $VisioLic
                    $validLicSelection = $true
                }

                5 {$LicType = $VisioLic
                    $validLicSelection = $true
                }

                default {Write-Host "Error: Invalid license selection`n" -ForegroundColor Red}
            }
        } until ($validLicSelection)

        #Sets account's country code in the Office portal (required before assigning a license)
        Set-MsolUser -UserPrincipalName $FullUPN -UsageLocation US

        #Assigns license to user created and setting license to the user selection above        Step 16
        Set-MsolUserLicense -UserPrincipalName $FullUPN -AddLicenses $LicType

        #Changing flag to true to end loop if user gets licensed successfully
        $userLicTest = Get-MsolUser -UserPrincipalName $FullUPN

        if ($userLicTest.IsLicensed) {
            Write-Host "`nThe user $($FullName) has been successfully assigned an $($LicType) licence!!`n"  -ForegroundColor Green
            Pause
            Read-host -Prompt "Hit Enter when ready to close."
            $assignLicenseValid = $true
        }
        
        else {
            Write-Host "The user $($FullName) could not be issued a license.`n"
            Read-host -Prompt "Hit enter to continue"
        }
  }     

} until ($assignLicenseValid -eq $true)