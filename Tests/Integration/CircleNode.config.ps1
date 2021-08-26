$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
        }
    )
}

<#
    .SYNOPSIS
    Installs node 14 as the default version
#>
Configuration CircleNode_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CircleNode 'Integration_Test'
        {
            Version = '14.17.5'
            DefaultVersion = $true
        }
    }
}
