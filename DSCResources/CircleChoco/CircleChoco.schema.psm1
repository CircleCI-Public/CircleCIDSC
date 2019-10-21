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

    Script SetProfileACL {
        GetScript  = {
            $TargetAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents"
            $PowerShellModuleAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents\WindowsPowerShell"
            $ProfileAcl = Get-Acl $using:CircleCIProfile

            return New-Object -TypeName PSCustomObject -Property @{
                'psmAcl'     = $PowerShellModuleAcl;
                'profileAcl' = $ProfileAcl
                'targetAcl'  = $TargetAcl
            }
        }
        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke()
            If ($state.psmAcl -eq $state.targetAcl -and $state.profileAcl -eq $state.targetAcl) {
                return $true
            }
            else {
                return $false
            }
        }
        SetScript  = {
 #           $TargetAcl = Get-Acl "C:\Users\$using:CircleCIUser\Documents"
 #           Set-Acl -Path "C:\Users\$using:CircleCIUser\Documents\WindowsPowerShell" -AclObject $TargetAcl
 #           Set-Acl -Path $using:CircleCIProfile -AclObject $using:TargetAcl
        }
        DependsOn  = '[File]CircleChocoProfile'
    }
}
