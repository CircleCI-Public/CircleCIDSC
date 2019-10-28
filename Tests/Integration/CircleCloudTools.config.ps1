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
Configuration CircleCIDSC_CircleCloudTools_Basic_Config
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    node $AllNodes.NodeName
    {
        CircleChoco 'choco' {}
        CircleCloudTools 'Integration_Test'
        {
#            PsDscRunAsCredential = New-Object `
#                -TypeName System.Management.Automation.PSCredential `
#                -ArgumentList @($Node.Username, (ConvertTo-SecureString -String $Node.Password -AsPlainText -Force))
        }
    }
}
