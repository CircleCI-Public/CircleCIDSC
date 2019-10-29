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
    Import-DscResource -ModuleName 'PackageManagement' -ModuleVersion '1.0.0.1'
    Import-DscResource -ModuleName 'ComputerManagementDsc'



    node $AllNodes.NodeName
    {
        CircleBuildAgentPreReq 'Integration_Test' { }
    }
}
