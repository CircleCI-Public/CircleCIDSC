<#
    .DESCRIPTION
        Install and configure chocolaty so it works with CircleCI
#>
Configuration JustChoco
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    Node $AllNodes.NodeName
    {
        CircleChoco choco { }
    }
}
