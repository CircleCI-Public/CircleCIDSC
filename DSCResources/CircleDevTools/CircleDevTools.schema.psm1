Configuration CircleDevTools {
    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
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
        Version   = "1.5"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller go
    {
        Name      = 'golang'
        Version   = '1.12.7'
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
        Version        = '3.7'
        DefaultVersion = $true
    }

    CircleNode "node12" {
        Version        = '12.11.1'
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
        PathItem = 'C:\Go\bin'
    }
}