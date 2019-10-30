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
    Import-DscResource -ModuleName 'cChoco'



    node $AllNodes.NodeName
    {
        CircleChoco 'choco' {}
        CircleBuildAgentPreReq 'Integration_Test' {
            Ensure = "Present"
         }
    }
}
