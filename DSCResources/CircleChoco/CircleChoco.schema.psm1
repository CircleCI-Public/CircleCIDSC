Configuration CircleChoco {
    Import-DscResource -Module cChoco

    LocalConfigurationManager {
        DebugMode = 'ForceModuleImport'
    }

    cChocoInstaller installChoco
    {
        InstallDir = 'C:\ProgramData\Chocolatey'
    }

    cChocoFeature allowGlobalConfirmation {
        FeatureName = 'allowGlobalConfirmation'
        DependsOn   = '[cChocoInstaller]installChoco'
    }

    $CircleCIUser = "circleci"
    $ImportHelpers = @'
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module $ChocolateyProfile
}
refreshenv >$null 2>&1
'@

    $CircleCIProfile = "C:\Users\$CircleCIUser\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    File CircleChocoProfile
    {
        DestinationPath = $CircleCIProfile
        Contents        = $ImportHelpers
    }

    $raw_password = [System.Web.Security.Membership]::GeneratePassword(42, 10)
    $password = ConvertTo-SecureString $raw_password -AsPlainText -Force
    $username = 'circleci'
    $cred = New-Object System.Management.Automation.PSCredential ($username, $password)

    Script SetProfileACL {
        GetScript  = {
            $TargetAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents"
            $PowerShellModuleAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents\WindowsPowerShell"
            $ProfileAcl = Get-Acl $using:CircleCIProfile

            return @{
                Result = @{
                    PsmAcl     = $PowerShellModuleAcl;
                    ProfileAcl = $ProfileAcl
                    TargetAcl  = $TargetAcl
                }
            }
        }
        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke().Result
            If ($state.PsmAcl -eq $state.TargetAcl -and $state.ProfileAcl -eq $state.targetAcl) {
                return $True
            }
            else {
                return $False
            }
        }
        SetScript  = {
             $TargetAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents"
             Set-Acl -Path "C:\Users\$using:CircleCIUser\Documents\WindowsPowerShell" -AclObject $TargetAcl
             Set-Acl -Path $using:CircleCIProfile -AclObject $using:TargetAcl
        }
        DependsOn  = '[File]CircleChocoProfile'
        PsDscRunAsCredential = $cred
    }
}
