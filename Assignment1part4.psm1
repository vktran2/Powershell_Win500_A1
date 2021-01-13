function Make-Session{
    #Prompt user for name and session name
    $compName = Read-Host "Enter Computer Name: "
    $sessName = Read-Host "Enter Session Name: "
    #var for testing
    $test = Test-Connection -ComputerName $compName -Quiet
    #test if computer is on
    if ($test -eq $true){
        #create PSSession with variables given
        Write-Host "Connection succeeded! Returning to menu."
        New-PSSession -ComputerName $compName -Name $sessName
        Get-PSSession
    }
    #test if computer is off
    elseif ($test -eq $false){
        Write-Host "The computer is unavailable. Returning to menu."
    }
}