<#
    .DESCRIPTION
    Install the set of microsoft tools used at circle ci
#>
Configuration Example
{
    Import-DscResource -ModuleName CircleCIDSC

    Node $AllNodes.NodeName
    {
        CircleMicrosoftTools 'Integration_Test' { }
    }
}
