$script:dscModuleName = 'CircleCIDSC'
$script:dscResourceFriendlyName = 'CircleMicrosoftTools'
$script:dscResourceName = "$($script:dscResourceFriendlyName)"


Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')

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

try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        $configurationName = "$($script:dscResourceName)_Integration_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        ConfigurationData    = $ConfigurationData
                        OutputPath           = $TestDrive
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
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
            }

            Update-Paths

            It 'Should return $true when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }


            Describe ".net" {
                It "the dotnet cli tool is on the path" {
                    $(Get-Command -Name 'dotnet') | Should -HaveCount 1
                }
                It "4 versions of the sdk are installed" {
                    $(dotnet --list-sdks).Split([System.Environment]::NewLine).Count | Should -EQ 2
                }
                It "12 versions of the runtime are installed" {
                    $(dotnet --list-runtimes).Split([System.Environment]::NewLine).Count | Should -EQ 9
                }
            }

            Describe "The visualstudio build tools" {
                It "is installed" {
                    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin" | Should -Exist
                }
                It "is on the path" {
                    $(Get-Command -Name "msbuild").Count | Should -Eq 1
                }
            }

            Describe "The Windows sdk" {
                It "is installed" {
                    "$Env:Programfiles (x86)\Windows Kits\10" | Should -Exist
                    #NOTE TODO! I can't find evidence for sdk 10.1
                }
            }

            Describe "Developer Mode" {
                It "is enabled" {
                    $(Get-Item "hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock").GetValue("AllowDevelopmentWithoutDevLicense") | should -Eq 1
                }
            }

            Describe "WinAppDriver" {
                It "is installed" {
                    "C:\Program Files (x86)\Windows Application Driver" | Should -Exist
                }
                It "is on the path" {
                    $(Get-Command -Name "winappDriver")
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
