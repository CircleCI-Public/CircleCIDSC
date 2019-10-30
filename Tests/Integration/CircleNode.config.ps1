$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
        }
    )
}

<#
    .SYNOPSIS
    Installs node 12 as the default version
#>
Configuration CircleNode_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CircleNode 'Integration_Test'
        {
            Version = '12.11.1'
            DefaultVersion = $true
        }
    }
}
