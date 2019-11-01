Configuration CircleMicrosoftTools {
    param (
        # Parameterhelp description
        [System.Boolean]
        $InstallVS=$true
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

    Package dotnet-sdk-3-0
    {
        Name      = 'Microsoft .NET Core SDK 3.0.100 (x64)'
        Path      = 'https://download.visualstudio.microsoft.com/download/pr/53f250a1-318f-4350-8bda-3c6e49f40e76/e8cbbd98b08edd6222125268166cfc43/dotnet-sdk-3.0.100-win-x64.exe'
        ProductId = '2594A057-CD99-4023-8F19-9D8513EE5446'
        Arguments = '/install /quiet /norestart'

    }

    Package dotnet-sdk-4-8
    {
        Name      = 'Microsoft .NET Framework 4.8 SDK'
        Path      = "https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0307177e14752e359fde5423ab583e43/ndp48-devpack-enu.exe"
        ProductId = "949C0535-171C-480F-9CF4-D25C9E60FE88"
        Arguments = '/install /quiet /norestart'
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

    if ($InstallVS) {
        cChocoPackageInstaller visualStudio
        {
            Name      = "visualstudio2019community"
            Version   = "16.2.5.0"
            Params    = "--allWorkloads --includeRecommended --includeOptional --passive --locale en-US"
            DependsOn = "[CircleChoco]choco"
        }
        circlePath vswhere
        {
            PathItem = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\'
        }

        cChocoPackageInstaller visualstudiobuildtools
        {
            Name      = "visualstudio2019buildtools-preview"
            Version   = "16.3.0.40000-preview1"
            DependsOn = "[CircleChoco]choco"
        }

        CirclePath vsbuild
        {
            PathItem = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin'
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

    cChocoPackageInstaller nuget
    {
        Name = 'nuget.commandline'
    }
}
