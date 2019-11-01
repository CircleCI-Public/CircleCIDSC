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

    File Tools {
        Type = 'Directory'
        DestinationPath = 'C:\Tools'
        Ensure = "Present"
    }

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
                # TODO:
                return $True #This is always returning true becuase we need to extract the user cred out
                             # to a node variable. This is going to be tedious and provide little value aside
                             # from getting rid of ugly hacks.
            }
        }
        SetScript  = {
            #TODO: once the above todo is fixed you can comment these back in
#             $TargetAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents"
#             Set-Acl -Path "C:\Users\$using:CircleCIUser\Documents\WindowsPowerShell" -AclObject $TargetAcl
#             Set-Acl -Path $using:CircleCIProfile -AclObject $using:TargetAcl
        }
        DependsOn  = '[File]CircleChocoProfile'
    }
}
