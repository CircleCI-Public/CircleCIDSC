[Microsoft.DscResourceKit.IntegrationTest(ContainerName = 'test', ContainerImage = 'mcr.microsoft.com/windows/servercore:ltsc2019')]
param()
#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        e.g. integration_template.config.json for real testing
        scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    <#
        If appropriate, this configuration hash table
        can be moved from here and into the integration test file.
        For example, if there are several configurations which all
        need different configuration properties, it might be easier
        to have one ConfigurationData-block per configuration test
        than one big ConfigurationData-block here.
        It may also be moved if it is easier to read the tests when
        the ConfigurationData-block is in the integration test file.
        The reason for it being here is that it is easier to read
        the configuration when the ConfigurationData-block is in this
        file.
    #>
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName        = 'localhost'
                CertificateFile = $env:DscPublicCertificatePath
            }
        )
    }
}

<#
    .SYNOPSIS
    install git, 7zip, gzip and git-lfs. The needed tools for build agetn
#>
Configuration CircleCIDSC_CircleBuildAgentPreReq_Basic_Config
{
    Import-DscResource -ModuleName 'CircleCIDSC'
    node $AllNodes.NodeName
    {
        CircleBuildAgentPreReq 'Integration_Test' { }
    }
}
