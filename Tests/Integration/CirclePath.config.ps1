

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
    Adds C:\Tests to the path
#>
Configuration CirclePath_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CirclePath 'Integration_Test'
        {
            PathItem = 'C:\Tests'
        }
    }
}
