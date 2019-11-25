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
        Disables TDR
#>
Configuration CircleTDR_Integration_Config
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    node $AllNodes.NodeName
    {
        CircleTDR 'Integration_Test'
        {
        }
    }
}
