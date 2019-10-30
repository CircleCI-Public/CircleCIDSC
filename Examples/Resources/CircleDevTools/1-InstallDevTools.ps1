<#
    .DESCRIPTION
    How to Configure your instance with python, ruby, java, and go.
#>
Configuration Example
{
    Import-DscResource -ModuleName CircleCIDSC

    Node $AllNodes.NodeName
    {
        CircleDevTools 'DevTools' { }
    }
}
