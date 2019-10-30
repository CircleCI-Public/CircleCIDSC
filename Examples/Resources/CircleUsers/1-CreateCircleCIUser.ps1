<#
    .DESCRIPTION
        Add the CircleCI and CircleCIAdmin user to the system
#>
Configuration Example
{

    Import-DscResource -ModuleName CircleCIDSC

    node $AllNodes.NodeName
    {
        CircleUser 'CircleUsers' { }
    }

}
