[Microsoft.DscResourceKit.IntegrationTest(ContainerName = 'test', ContainerImage = 'mcr.microsoft.com/windows/servercore:ltsc2019')]
param()

<#
    .SYNOPSIS
       Template for creating DSC Resource Integration Tests

    .DESCRIPTION
        To Use:
            1. Copy to \Tests\Integration\ folder and rename <ResourceName>.Integration.tests.ps1
               (e.g. MSFT_Firewall.Integration.tests.ps1).
            2. Customize TODO sections.
            3. Remove TODO comments.
            4. Create test DSC Configuration file <ResourceName>.config.ps1
               (e.g. MSFT_Firewall.config.ps1) from integration_template.config.ps1 file.
            5. Remove this comment-based help.

    .NOTES
        Code in HEADER and FOOTER regions are standard and should not be altered
        if possible.
#>

$script:dscModuleName = 'CircleCIDSC'
$script:dscResourceFriendlyName = 'CircleBuildAgentPreReq'
$script:dscResourceName = "($script:dscResourceFriendlyName)"

#region HEADER
# Integration Test Template Version: 1.3.3
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -TestType Integration
#endregion


# Using try/finally to always cleanup.
try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        $configurationName = "$($script:dscResourceName)_BuildAgent_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        <#
                            The variable $ConfigurationData was dot-sourced
                            above. (Optional) The configuration data hash table can
                            be moved into this file as appropriate, see the
                            integration_template.config.ps1 for more information.
                        #>
                        ConfigurationData    = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName `
                    -and $_.ResourceId -eq $resourceId
                }

                $resourceCurrentState.Ensure | Should -Be 'Present'
                $resourceCurrentState.Property | Should -Be $ConfigurationData.AllNodes.Property1
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }

            It "Has 7zip on th path" {
                (Get-Command -Name '7z') | Should -HaveCount 1
            }
            It "Has git on the path" {
                (Get-Command -Name 'git') | Should -HaveCount 1
            }
            It "Has unix tools on the path" {
                (Get-Command -Name 'xargs') | Should -HaveCount 1
            }
            It "Has gzip on the path" {
                (Get-Command -Name 'gzip') | Should -HaveCount 1
            }
        }
    }
    #endregion

}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
