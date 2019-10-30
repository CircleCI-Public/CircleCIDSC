<#
    .DESCRIPTION
        Add C:\Tests to the path
#>
Configuration Example
{
    Import-DscResource -ModuleName CircleCIDSC

    Node $AllNodes.NodeName
    {

        CirclePath 'TestIsOnPath'
        {
            PathItem = 'C:\Tests'
        }
    }
}
