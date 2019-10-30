<#
    .SYNOPSIS
    This tests the Circle Dev tools DSC this manages installing python, node, java
    and a few other tools

#>

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
            }
        )
    }
}

<#
    .SYNOPSIS
    Runs the CircleDevTools DSC
#>
Configuration CircleDevTools_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CircleDevTools 'Integration_Test' {
            Esnure = "Present"
         }

    }
}
