<#
    .DESCRIPTION
        Install python 3.7 using conda and set it to default
#>
Configuration Example
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    node $AllNodes.NodeName
    {
        CirclePython 'Python3.7'
        {
            EnvName        = 'python3'
            Version        = '3.7'
            DefaultVersion = $true
        }
    }
}
