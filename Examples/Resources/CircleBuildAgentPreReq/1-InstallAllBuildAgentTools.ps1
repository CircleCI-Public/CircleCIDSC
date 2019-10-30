<#
    .DESCRIPTION
        install the build agent prequisites
#>
Configuration BuildAgentTools
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    Node $AllNodes.NodeName
    {
        CircleBuildAgentPreReq BuildAgentTools { }
    }
}
