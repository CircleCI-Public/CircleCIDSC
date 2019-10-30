Configuration CircleCloudTools {
    Import-DscResource -ModuleName 'PackageManagement' -ModuleVersion '1.0.0.1'
    Import-DscResource -Module cChoco
    Import-DscResource -Mdoule CircleCIDSC
    CircleChoco choco { }

    cChocoPackageInstaller awscli
    {
        Name      = "awscli"
        Version   = "1.16.209"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller azure-cli
    {
        Name      = "azure-cli"
        Version   = "2.0.70"
        DependsOn = "[CircleChoco]choco"
    }

    cChocoPackageInstaller webpicmd
    {
        Name      = "webpicmd"
        DependsOn = "[CircleChoco]choco"
    }

    PackageManagement ServiceFabric
    {
        Name            = "Microsoft.ServiceFabric"
        RequiredVersion = "6.5.664"
    }

    cChocoPackageInstaller ServiceFabricSDK
    {
        Name      = "MicrosoftAzure-ServiceFabric-CoreSDK"
        Source    = "webpi"
        DependsOn = "[cChocoPackageInstaller]webpicmd"
    }
}
