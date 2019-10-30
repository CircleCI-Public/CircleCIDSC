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
    Adds the circleCI users
#>
Configuration CircleUser_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    Node $AllNodes.NodeName
    {
        CircleUser 'Integration_Test' { }
    }
}
