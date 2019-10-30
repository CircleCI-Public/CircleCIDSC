#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion


$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath
        }
    )
}

<#
    .SYNOPSIS
        Installs python3 and sets it to the default
#>
Configuration CirclePython_Integration_Config
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    node $AllNodes.NodeName
    {
        CirclePython 'Integration_Test'
        {
            EnvName        = 'python3'
            Version        = '3.7'
            DefaultVersion = $true
        }
    }
}
