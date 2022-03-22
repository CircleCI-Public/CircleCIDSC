Configuration CircleDevTools {
    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -Module CircleCIDSC
    CircleChoco choco { }


    cChocoPackageInstaller nunit
    {
        Name      = "nunit-console-runner"
        Version   = "3.10.0"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller nano
    {
        Name      = 'nano'
        Version   = "2.5.3"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller vim
    {
        Name      = 'vim'
        Version   = "8.0.604"
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
        Version   = '1.17.6'
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller java
    {
        Name      = 'openjdk'
        Version   = '12.0.2'
        DependsOn = '[CircleChoco]choco'
    }

    CirclePython "python27" {
        EnvName = 'python27'
        Version = '2.7'
    }

    CirclePython "python3" {
        EnvName        = 'python3'
        Version        = '3.9'
        DefaultVersion = $true
    }

    CircleNode "node14" {
        Version        = '14.17.5'
        DefaultVersion = $true
    }

    cChocoPackageInstaller ruby {
        Name    = 'ruby'
        Version = '2.6.3.1'
    }

    CirclePath 'rubyPath' {
        PathItem = 'C:\tools\ruby26'
    }

    CirclePath 'goPath' {
        PathItem = 'C:\Program Files\Go\bin'
    }
}
