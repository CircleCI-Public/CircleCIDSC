#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName        = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath

                # Add configuration properties when they happend.
#                UserName        = 'MyInstallAccount'
#               Password        = 'MyP@ssw0rd!1'
            }
        )
    }
}

<#
    .SYNOPSIS
    installs a collection of tools for interactiong with clouds
#>
Configuration CircleCloudTools_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CircleCloudTools 'Integration_Test' {
            Ensure = "Present"
         }
    }
}
