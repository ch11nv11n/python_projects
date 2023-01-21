#This variable truncates output if not set to -1
if ($FormatEnumerationLimit -ne -1) {$FormatEnumerationLimit = -1}

#if module is not loaded
if (! (Import-Module "ActiveDirectory")) {
        Write-Host "`nActive Directory module loaded successfully...`n" -ForegroundColor Yellow
}

Write-Host "`nThis script will ask for user input to create an AD user. Then automatically creates their Exchange mailbox. Then you can choose to assign an Office 365 if necessary`n

  Part 1 - Creating AD user              Part 2 - Creating Mailbox               Part 3 - O365 License Assignment
-----------------------------         -------------------------------         --------------------------------------         
   Step 1: First name                   Step 8: Asks for admin creds           Step 12: Asks if you want to assign license`n
   Step 2: Last name                    Step 9: Runs an AD sync                Step 13: Get Office credentials`n
   Step 3: Company selection           Step 10: Creates mailbox                Step 14: List avialable license types`n
   Step 4: Department selection        Step 11: Runs second sync               Step 15: Display license selection menu`n
   Step 5: Title                                                               Step 16: Sets user's license`n
   Step 6: Password`n
   Step 7: Ou selection`n" -ForegroundColor Magenta | Format-Table -AutoSize

Read-host -Prompt "Begin Part 1 - Creating AD User: Press the ENTER key to start script"


#firstname - if first letter not capitalized, capitalize it
$FirstName = Read-Host -Prompt "Step 1: Please enter user First Name"
if ($FirstName.Substring(0,1) -cmatch "[a-z]") {
    $FirstName = $FirstName.Substring(0,1).ToUpper() + $FirstName.Substring(1)
}

#lastname - if first letter not capitalized, capitalize it
$LastName = Read-Host -Prompt "`nStep 2: Please enter user Last Name"
if ($LastName.Substring(0,1) -cmatch "[a-z]") {
    $LastName = $LastName.Substring(0,1).ToUpper() + $LastName.Substring(1)
}

#fullname = CN - sets Display Name to firstname and lastname vars with space in between
$FullName = "$($FirstName) $($LastName)"

#sAMAccountName = Win(pre-Windows 2000) - CANNOT BE SAME FIRST INITIAL LAST LAME AS ANY OTHER USER
#Sets to first name var and first character of last name  var - sets all chars to lowercase
$FNameLInitial = $FirstName.ToLower() + $LastName.Substring(0,1).ToLower()

#userprincipalname/ email - sets all chars to lowercase
$UPN = $FirstName.Substring(0,1).ToLower() + $LastName.ToLower()
$FullUPN = "$($UPN)@domain.com"

#Company Name - asks for company name selection and if not school health, asks for string input - uses loop to validate selection
Write-Host "`nSteps 3-5 are for setting attributes on the Organization tab on the user object" -ForegroundColor Yellow
Write-Host "Step 3: Select user company selection below"
Write-Host "`n`t    1. Company
            2. Other/Consultant"
do {
    $Company = Read-Host -Prompt "`nPlease make company selection"
    $validCompany = $false

    switch($Company) {
    1 {$Company = "Company"
       $validCompany = $true
    }
    2 { $Company = Read-Host -Prompt "Enter company name"
        $validCompany = $true
    }
    default { Write-Host "Error: Invalid company name selection" -ForegroundColor Red }
    }
} Until ($validCompany)

#Department menu - uses loop to validate selection
Write-Host "`nStep 4: Select user department below`n"
Write-Host "`t    1. Accounting
            2. Business Analytics
            3. Contract Sales
            4. Customer Care
            5. Distribution Center
            6. ECommerce
            7. Executive
            8. Graphic Design
            9. Human Resources
           10. Inside Sales
           11. Inventory Control
           12. Marketing
           13. National Accounts
           14. Order Processing
           15. Outside Sales
           16. Product Management
           17. Project Management
           18. Service Center/CPR
           19. Technology"

do {
    $Dept = Read-Host -Prompt "`nPlease make department selection"
    $validDept = $false

    switch ($Dept) {
    1. {$Dept = "Accounting"
        $validDept = $true
    }
    2. {$Dept = "Business Analytics" 
        $validDept = $true
    }
    3. {$Dept = "Contract Sales" 
        $validDept = $true
    }
    4. {$Dept = "Customer Care" 
        $validDept = $true
    }
    5. {$Dept = "Distribution Center"
        $validDept = $true
    }
    6. {$Dept = "ECommerce"
        $validDept = $true
    }
    7. {$Dept = "Executive"
        $validDept = $true
    }
    8. {$Dept = "Graphic Design"
        $validDept = $true
    }
    9. {$Dept = "Human Resources"
        $validDept = $true
    }
    10. {$Dept = "Inside Sales"
        $validDept = $true
    }
    11. {$Dept = "Inventory Control"
        $validDept = $true
    }
    12. {$Dept = "Marketing"
        $validDept = $true
    }
    13. {$Dept = "National Accounts"
        $validDept = $true
    }
    14. {$Dept = "Order Processing"
        $validDept = $true
    }
    15. {$Dept = "Outside Sales"
        $validDept = $true
    }
    16. {$Dept = "Product Management"
        $validDept = $true
    }
    17. {$Dept = "Project Management"
        $validDept = $true
    }
    18. {$Dept = "Service Center/CPR"
        $validDept = $true
    }
    19. {$Dept = "Technology"
        $validDept = $true
    }
    default { Write-Host "Error: Invalid department selection" -ForegroundColor Red}
    }
} Until ($validDept)

#Title
$Title = Read-Host -Prompt "`nStep 5: Please enter user title"

#password
Write-Host "`n**Remember to follow complexity requirements**" -ForegroundColor Yellow
$Password = Read-Host -Prompt "Step 6: Please enter user's Password"
$Password = $Password | ConvertTo-SecureString -AsPlainText -Force

#ou selection menu - uses loop to validate user input
Write-Host "`nStep 7: Select from following OU's to put object in:`n"
Write-Host "`t    1. Users
            2. Users - Consultants
            3. Users - Enablemart
            4. Users - Internal
            5. Users - Notebooks
            6. Users - Remote
            7. Users - TechExec
            8. Users - TermSrv
            9. Users - Test"
do {
    $OUInput = Read-Host -Prompt "`nPlease make an OU selection"
    $validOU = $false 
    
    switch ($OUInput) {
        1 {$OUInput = "Users"
           $validOU = $true
        }
        2 {$OUInput = "Users - Consultants"
           $validOU = $true
        }
        3 {$OUInput = "Users - Enablemart"
           $validOU = $true
        }
        4 {$OUInput = "Users - Internal"
           $validOU = $true
        }
        5 {$OUInput = "Users - Notebooks"
           $validOU = $true
        }
        6 {$OUInput = "Users - Remote"
           $validOU = $true
        }
        7 {$OUInput = "Users - TechExec"
           $validOU = $true
        }
        8 {$OUInput = "Users - TermSrv"
           $validOU = $true
        }
        9 {$OUInput = "Users - Test"
           $validOU = $true
        }
        default {Write-Host "Error: Invalid Selection" -Foregroundcolor Red }
        }
    } until ($validOU)

#appends ou selection to OU format
$FullOU = "OU= $($OUInput),DC=domain,DC=com"

#Creating user
$NewUser = New-ADUser -GivenName $FirstName -Surname $LastName -Name $FullName -DisplayName $FullName -Company $Company -Country US -EmailAddress $FullUPN -Title $Title `
           -Department $Dept -SamAccountName $FNameLInitial -UserPrincipalName $FullUPN -Path $FullOU -AccountPassword $Password -Enabled $true


$UserUPNTest = Get-ADUser -Filter {EmailAddress -eq $FullUPN}
$UserSAMTest = Get-ADUser -Filter {sAMAccountName -eq $FNameLInitial} 

if (($UserSAMTest -eq $null) -or ($UserUPNTest -eq $null)) {
    Write-Host "`nThe User $($FullName) was not successfully created. Exiting...`n" -ForegroundColor Red
    exit
}

Else {
    Write-Host "`nThe User $($FullName) has been created.`n"
    #This script adds user to specific groups based on department and OU selection
    & .\UserGroupAdding.ps1
   
    $ContinueOnYorN = Read-host -Prompt "Would you like to proceed to Part 2 - Creating Mailbox |y or n|"

    #Create loop for incorrect selection
    if (($ContinueOnYorN -eq "y") -or ($ContinueOnYorN -eq "Y") -or ($ContinueOnYorN -eq "yes") -or ($ContinueOnYorN -eq "YES")) {
        & .\Pt2-OfficeMailboxCreation.ps1
    }

    elseif (($ContinueOnYorN -eq "n") -or ($ContinueOnYorN -eq "N") -or ($ContinueOnYorN -eq "no") -or ($ContinueOnYorN -eq "NO")) {
        Write-Host "`nExiting..." -ForegroundColor Yellow
        exit
    }

    else {
        Write-Host "`nYou did not enter a valid selection. Exiting..." -ForegroundColor Yellow
        exit
    }
}