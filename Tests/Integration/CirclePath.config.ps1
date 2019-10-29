

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
# TODO: Modify ResourceName and ShortDescriptiveName (e.g. MSFT_Firewall_EnableRemoteDesktopConnection_Config).
Configuration CirclePath_Integration_Config
{
    # TODO: Modify ModuleName (e.g. NetworkingDsc)
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        # TODO: Modify ResourceFriendlyName (e.g. Firewall).
        CirclePath 'Integration_Test'
        {
            PathItem = 'C:\Tests'
        }
    }
}

# TODO: (Optional) Add More Configuration Templates as needed.
