$errorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

Add-Type -AssemblyName System.web

Configuration CircleUsers {

    # Generate a strong random password that we can throw away.
    Import-DscResource -Name User
    Import-DscResource -Name Group

    Add-Type -AssemblyName System.web

    $raw_password = [System.Web.Security.Membership]::GeneratePassword(42, 10)
    $password = ConvertTo-SecureString $raw_password -AsPlainText -Force
    $username = 'circleci'
    $username_admin = 'circleci-admin'

    $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
    $cred_admin = New-Object System.Management.Automation.PSCredential ($username_admin, $password)
    $domain = $env:COMPUTERNAME


    User CircleUser {
        UserName = $username 
        Password = $cred
    }
    User CircleAdminUser {
        UserName = $username_admin
        Password = $cred_admin
    }

    Group AddADUserToLocalAdminGroup {
        GroupName        = 'Administrators'
        MembersToInclude = @("$domain\$username", "$domain\$username_admin")
    }

    Script LoginTheUsers {
        GetScript = { return @{ Result = $(Test-Path C:\Users\circleci-admin) } }
        TestScript = { return $(Test-Path C:\Users\circleci-admin) }
        SetScript = {
            $password = ConvertTo-SecureString $using:raw_password -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential ($using:username, $password)
            $cred_admin = New-Object System.Management.Automation.PSCredential ($using:username_admin, $password)
            # We need to 'Login' as the created user to kick off windows user initialization.
            Start-Process cmd /c -WindowStyle Hidden -Credential $cred_admin -ErrorAction SilentlyContinue -Wait
            Start-Process cmd /c -WindowStyle Hidden -Credential $cred -ErrorAction SilentlyContinue -Wait
        }
    }
}
