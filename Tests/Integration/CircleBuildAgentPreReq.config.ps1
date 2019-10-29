$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath
        }
    )
}
<#
    .SYNOPSIS
    install git, 7zip, gzip and git-lfs. The needed tools for build agetn
#>
Configuration CircleBuildAgentPreReq_Integration_Config
{
    Import-DscResource -ModuleName CircleCIDSC
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'


    node $AllNodes.NodeName
    {
        CircleChoco 'choco' {}
        CircleBuildAgentPreReq 'Integration_Test' { }
    }
}
