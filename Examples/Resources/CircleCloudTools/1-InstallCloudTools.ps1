<#
    .DESCRIPTION
        Install cloud tools for aws, gcp, and azure as well as servicefabric
#>
Configuration InstallCloudTools
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    Node $AllNodes.NodeName
    {
        CircleCloudTools circleCloudTools { }
    }
}
