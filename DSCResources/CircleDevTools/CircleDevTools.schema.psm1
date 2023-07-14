Configuration CircleDevTools {
    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -Module CircleCIDSC
    CircleChoco choco { }


    cChocoPackageInstaller nunit
    {
        Name      = "nunit-console-runner"
        Version   = "3.16.3"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller nano
    {
        Name      = 'nano'
        Version   = "7.2.25"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller vim
    {
        Name      = 'vim'
        Version   = "9.0.1425"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller jq
    {
        Name      = 'jq'
        Version   = "1.6"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller go
    {
        Name      = 'golang'
        Version   = '1.20.5'
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller java
    {
        Name      = 'openjdk'
        Version   = '20.0.1'
        DependsOn = '[CircleChoco]choco'
    }

    CirclePython "python27" {
        EnvName = 'python27'
        Version = '2.7'
    }

    CirclePython "python3" {
        EnvName        = 'python3'
        Version        = '3.11.4'
        DefaultVersion = $true
    }

    CircleNode "node14" {
        Version        = '14.21.3'
        DefaultVersion = $true
    }

    cChocoPackageInstaller ruby {
        Name    = 'ruby'
        Version = '3.1.3.1'
    }

    CirclePath 'rubyPath' {
        PathItem = 'C:\tools\ruby31'
    }

    CirclePath 'goPath' {
        PathItem = 'C:\Program Files\Go\bin'
    }
}
