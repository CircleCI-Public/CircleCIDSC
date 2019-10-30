<#
    .DESCRIPTION
    Install Node 12 as the default version
#>
Configuration Example
{
    Import-DscResource -ModuleName CircleCIDSC

    Node $AllNodes.NodeName
    {
        CircleNode 'Node 12'
        {
            Version = '12.11.1'
            DefaultVersion = $true
        }
    }
}
