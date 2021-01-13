Function Get-Uptime{
    <#

    .Synopsis
    Gets computer name, OS, and uptime using CIM

    .Description
    Gets computer name, OS, and uptime using CIM

    .Example
    PS>get-Uptime


    .Notes
    Name: Get-Uptime
    Author: Victor Tran
    Date last modified: 11/23/2020
    #>

    #get all ad computer names
    $adComputerName = Get-ADComputer -Filter * | Select -ExpandProperty Name
    #iterate through each computer found in the variable $adComputerName
    Foreach($adComputer in $adComputerName){
        #test connection and if successful complete the following commands
        if(Test-Connection -ComputerName $adComputer -Quiet){
            #output computername
            Write-Host 'Computername: ' $adComputer
            #run command on remote computer
            Invoke-Command -ComputerName $adComputer -ScriptBlock{
                #subtract the current date from last boot up time to get up time
                $dateTime = (Get-Date)-(Get-CimInstance Win32_OperatingSystem).LastBootUpTime | Select Days, Hours, Minutes, Seconds 
                #put the values from hashtable into individual variables for easy formatting
                $days = $dateTime.Days
                $hours = $dateTime.Hours
                $mins = $dateTime.Minutes
                $secs = $dateTime.Seconds
                #get the operating system of the computer
                $OS = (Get-CimInstance Win32_OperatingSystem).Caption
                #output OS and uptime
                Write-Host 'Computer Operating System: ' $OS
                Write-Host "Computer Uptime:  $days : $hours : $mins : $secs"
                Write-Host ''
                }
        }
        #if the connection fails complete following commands
        else{
            #write computer is offline
            Write-Host 'Computer is offline: ' $adComputer
            Write-Host ''
        }
    }
}

Function New-User{
    <#

    .Synopsis
    Creates a new ad-user reading input from the user

    .Description
    Creates a new ad-user using  firstname, surname, and department parameters specified by the user

    .Example
    PS> New-User

    .Notes
    Name: New-User
    Author: Victor Tran
    Date last modified: 11/23/2020
    #>

    #warn the user that spaces and numbers will be removed from the input name text
    Write-Host "Numbers and Spaces WILL be removed from your name"
    #prompt for first and last name, and department
    $fName = Read-Host "Enter your first name: "
    $lName = Read-Host "Enter your last name: "
    $aDepartment = Read-Host "Enter your assigned department: "

    #replace spaces and numbers from name inputs
    $fName = $fName -replace '[1234567890 ]'
    $lName = $lName -replace '[1234567890 ]'
    #replace numbers from department input
    $aDepartment = $aDepartment -replace '[1234567890]'
    #add first and last name together for full name
    $fullName = $fName + ' ' + $lName

    #create user based on given information
    New-ADUser -Name $fullName -GivenName $fName -Surname $lName -Department $aDepartment
    #confirm creation
    write-host "The user has been created with the following information: $fullName , $aDepartment"
}

Function Get-Logon{
    <#

    .Synopsis
    Displays all adusers and their last logon dates

    .Description
    Displays all adusers and their last logon dates

    .Example
    PS>Get-Logon


    .Notes
    Name: Get-Logon
    Author: Victor Tran
    Date last modified: 11/23/2020
    #>
    #save all users in variable
    $allUsers = Get-ADUser -Filter * | Select -ExpandProperty name
    #iterate over each user in variable
    $a = foreach($user in $allUsers){
        #select the name and logondate from each user
        Get-ADUser -Identity $user -Properties LastLogonDate | Select -Property Name, LastLogonDate
    } 
    #convert to HTML and open webpage
    $a | ConvertTo-Html | Out-File logon.html
    Invoke-Item logon.html
}

Function Set-Logon{
    <#

    .Synopsis
    Set the specified logon date and time for the specified user

    .Description
    Set the specified logon date and time for the specified user

    .Example
    PS>Set-Logon


    .Notes
    Name: Set-Logon
    Author: Victor Tran
    Date last modified: 11/23/2020
    #>
    #Set the bytes used to change log on hours
    [Byte[]]$hours = @(0,0,0,0,0,254,3,0,254,3,0,254,3,0,254,3,0,254,3,0,0)
    #prompt for username
    $user = read-host "Enter Username: "
    #get all aduser names
    $allUsers = Get-ADUser -Filter * | Select -ExpandProperty Name
    #check if the given username is in the list of adusers
    if($user -in $allUsers){
        #set the logon times to weekdays only 9am to 6pm
        Set-ADUser -Identity $user -Replace @{Logonhours = $hours}
        Write-Host "$user has logon hours changed to weekdays only, 9am to 6pm"
    }
    #if the username is not found user will be notified
    else{
        write-host "That user does not exist"
    }
}

#create aliases and export
New-Alias -Name gup -Value Get-Uptime
New-Alias -Name nusr -Value New-User
New-Alias -Name glog -Value Get-Logon
New-Alias -Name slog -Value Set-Logon

Export-ModuleMember -Alias * -Function *