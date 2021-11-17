Configuration CircleMicrosoftTools {
    param (
        # Parameterhelp description
        [System.Boolean]
        $InstallVS=$True,

        # DotNet has to have a restart, this won't work for testing
        [System.Boolean]
        $InstallDotNet=$True,

        # WinAppDriver needs a restart, this won't work for testing
        [System.Boolean]
        $InstallWinAppDriver=$True
    )


    Import-DscResource -Module CircleCIDSC
    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    CircleChoco choco { }

    cChocoPackageInstaller dotnetfx
    {
        Name      = "dotnetfx"
        DependsOn = "[CircleChoco]choco"
    }


    cChocoPackageInstaller netcore-sdk2-2
    {
        Name      = "dotnetcore-sdk"
        Version   = "2.2.401"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller netcore-sdk5-0
    {
        Name      = "dotnet-5.0-sdk"
        Version   = "5.0.401"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller windowssdk-10-0
    {
        Name      = "windows-sdk-10.0"
        Version   = "10.0.26624"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller windowssdk-10-1
    {
        Name      = "windows-sdk-10.1"
        Version   = "10.1.18362.1"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller installSQLExpress {
        Name                 = 'sql-server-express'
        Ensure               = 'Present'
        Version              = "2019.20200409"
        Params               = "/ACTION:INSTALL /IACCEPTSQLSERVERLICENSETERMS /INSTANCEID:MSSQLSERVER /INSTANCENAME:MSSQLSERVER /UPDATEENABLED:FALSE /SECURITYMODE:SQL /SAPWD:r22rbf8*PUHjqzb3 /QUIET"
        DependsOn            = '[CircleChoco]choco'
    }

    cChocoPackageInstaller installSQLManagementStudio {
        Name                 = 'sql-server-management-studio'
        Ensure               = 'Present'
        DependsOn            = '[CircleChoco]choco'
    }

    # choco install sql-server-management-studio

    if ($InstallVS) {
        cChocoPackageInstaller visualStudio
        {
            Name      = "visualstudio2019community"
            Version   = "16.11.4.0"
            Params    = "--allWorkloads --includeRecommended --no-update --includeOptional --passive --noUpdateInstaller --locale en-US"
            DependsOn = "[CircleChoco]choco"
        }
        
        circlePath vswhere
        {
            PathItem = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\'
        }

        cChocoPackageInstaller visualstudiobuildtools
        {
            Name      = "visualstudio2019buildtools"
            Version   = "16.11.4.0"
            DependsOn = "[CircleChoco]choco"
        }
        
        Script DisableUpdates
        {
            SetScript = {
                $vsWherePath = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
                $installPath = &$vsWherePath -all -latest -property installationPath
                $vsregedit = Join-Path $installPath 'Common7\IDE\vsregedit.exe'
                $statejson = Join-Path $installPath 'Common7\IDE\Extensions\MachineState.json'
                &$vsregedit set $installPath HKCU ExtensionManager AutomaticallyCheckForUpdates2Override dword 0
                &$vsregedit set $installPath HKCU ExtensionManager EnableAdminExtensions dword 0
                &$vsregedit set $installPath HKCU ExtensionManager AutomaticallyUpdateExtensions dword 0
                &$vsregedit set $installPath HKCU ExtensionManager AutomaticallyCheckForUpdates2 dword 0
                &$vsregedit set $installPath HKCU ExtensionManager EnableAdminExtensionsOverride dword 0
                &$vsregedit set $installPath HKCU ExtensionManager AutomaticallyUpdateExtensionsOverride dword 0
                Set-Content -Path $statejson -Value '{"Extensions":[],"ShouldAutoUpdate":false,"ShouldCheckForUpdates":false}'
            
            }
            TestScript = { return $False }
            GetScript = { @{ Result = "" } }
            DependsOn = "[cChocoPackageInstaller]visualStudio"
        }


        CirclePath vsbuild
        {
            PathItem = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin'
        }
        
        Registry DisableUpdateReg
        {
            Key       = "HKEY_LOCAL_MACHINE\Policies\Microsoft\VisualStudio"
            ValueName = "SQM"
            ValueType = "DWORD"
            ValueData = "0"
            DependsOn = "[cChocoPackageInstaller]visualStudio"
        }

    }

    Registry DeveloperMode
    {
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        ValueName = "AllowDevelopmentWithoutDevLicense"
        ValueType = "DWORD"
        ValueData = "1"
    }

    Registry Sideloading
    {
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        ValueName = "AllowAllTrustedApps"
        ValueType = "DWORD"
        ValueData = "1"
    }

    if ($InstallWinAppDriver) {
      Package InstallWinAppDriver
      {
          Name      = 'Windows Application Driver'
          Path      = "https://github.com/Microsoft/WinAppDriver/releases/download/v1.1/WindowsApplicationDriver.msi"
          ProductId = "C4903086-429C-4455-86DD-044914BBA07B"
      }

      circlePath winAppDriver
      {
          PathItem = 'C:\Program Files (x86)\Windows Application Driver'
      }
    }

    cChocoPackageInstaller nuget
    {
        Name = 'nuget.commandline'
    }

    if ($InstallDotNet) {
        # These are last. This is becuase despite my best efforts
        # They inspire the machine to require a reboot
        Package dotnet-sdk-3-0
        {
            Name      = 'Microsoft .NET Core SDK 3.0.100 (x64)'
            Path      = 'https://download.visualstudio.microsoft.com/download/pr/53f250a1-318f-4350-8bda-3c6e49f40e76/e8cbbd98b08edd6222125268166cfc43/dotnet-sdk-3.0.100-win-x64.exe'
            ProductId = '2594A057-CD99-4023-8F19-9D8513EE5446'
            Arguments = '/install /quiet /norestart'
        }

        Package dotnet-sdk-3-1
        {
            Name      = 'Microsoft .NET Core SDK 3.1.406 (x64)'
            Path      = 'https://download.visualstudio.microsoft.com/download/pr/cc28204e-58d7-4f2e-9539-aad3e71945d9/d4da77c35a04346cc08b0cacbc6611d5/dotnet-sdk-3.1.406-win-x64.exe'
            ProductId = '894da14d-4e5a-4915-a1b8-bc5db37f77a5'
            Arguments = '/install /quiet /norestart'
        }

        Package dotnet-sdk-4-8
        {
            Name      = 'Microsoft .NET Framework 4.8 SDK'
            Path      = "https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0307177e14752e359fde5423ab583e43/ndp48-devpack-enu.exe"
            ProductId = "949C0535-171C-480F-9CF4-D25C9E60FE88"
            Arguments = '/install /quiet /norestart'
        }
    }
}
