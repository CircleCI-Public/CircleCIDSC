<#
    .DESCRIPTION
        Install python 3.9 using conda and set it to default
#>
Configuration Example
{
    Import-DscResource -ModuleName 'CircleCIDSC'

    node $AllNodes.NodeName
    {
        CirclePython 'Python3.9'
        {
            EnvName        = 'python3'
            Version        = '3.9'
            DefaultVersion = $true
        }
    }
}
