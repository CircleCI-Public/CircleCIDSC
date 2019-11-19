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
        Installs the pile of MSFT tools our customers want
#>
Configuration CircleMicrosoftTools_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CircleMicrosoftTools 'Integration_Test' {
            InstallVS=$False
            InstallDotNet=$False
            InstallWinAppDriver=$False
         }
    }
}

