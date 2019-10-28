<#
    .DESCRIPTION
        install the build agent prequisites
#>
Configuration BuildAgentTools
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    Node $AllNodes.NodeName
    {
        CircleChoco choco {} # choco needs to be configured for this resource to work
        CircleBuildAgentPreReq BuildAgentTools { }
    }
}
