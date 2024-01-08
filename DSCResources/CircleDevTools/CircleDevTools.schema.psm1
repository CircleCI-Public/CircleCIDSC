Configuration CircleDevTools {
    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -Module CircleCIDSC
    CircleChoco choco { }

    $Win2022=$False
    $osVersion = [System.Environment]::OSVersion.Version.Build
    if($osVersion -gt 20000) {
        $Win2022=$True
    }

    cChocoPackageInstaller nunit
    {
        Name      = "nunit-console-runner"
        Version   = "3.16.3"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller nano
    {
        Name      = 'nano'
        Version   = "7.2.36"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller vim
    {
        Name      = 'vim'
        Version   = "9.0.2146"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller jq
    {
        Name      = 'jq'
        Version   = "1.7"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller go
    {
        Name      = 'golang'
        Version   = '1.21.5'
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller java
    {
        Name      = 'openjdk'
        Version   = '21.0.1'
        DependsOn = '[CircleChoco]choco'
    }

    CirclePython "python27" {
        EnvName = 'python27'
        Version = '2.7'
    }

    CirclePython "python3" {
        EnvName        = 'python3'
        Version        = '3.12.1'
        DefaultVersion = $true
    }

    CircleNode "nodejs" {
        Version        = '20.10.0'
        DefaultVersion = $true
    }

    cChocoPackageInstaller ruby {
        Name    = 'ruby'
        Version = '3.1.3.1'
    }

    if ($Win2022) {
        cChocoPackageInstaller docker-engine {
            Name        = 'docker-engine'
            Version     = '24.0.7.20231201'
            Params      =  'Containers Microsoft-Hyper-V --source windowsfeatures'
        }
    }
    
    Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
    .\install-docker-ce.ps1 -NoRestart

    CirclePath 'rubyPath' {
        PathItem = 'C:\tools\ruby31'
    }

    CirclePath 'goPath' {
        PathItem = 'C:\Program Files\Go\bin'
    }
}