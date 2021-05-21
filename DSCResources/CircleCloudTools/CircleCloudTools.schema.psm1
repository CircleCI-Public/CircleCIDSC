Configuration CircleCloudTools {
    Import-DscResource -ModuleName 'PackageManagement' -ModuleVersion '1.0.0.1'
    Import-DscResource -Module cChoco
    Import-DscResource -Module CircleCIDSC
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
        Name      = "webpi"
        Version   = "5.1"
        DependsOn = "[CircleChoco]choco"
    }

    #register package source
    PackageManagementSource Nuget
    {
        Name      = "Nuget"
        ProviderName= "Nuget"
        SourceUri = "https://nuget.org/api/v2/"
        InstallationPolicy ="Trusted"
    }

    # This does get install by the Service fabric SDK
#    PackageManagement ServiceFabric
#    {
#        Name            = "Microsoft.ServiceFabric"
#        RequiredVersion = "6.5.664"
#        DependsOn       = "[PackageManagementSource]Nuget"
#    }


    cChocoPackageInstaller ServiceFabricSDK
    {
        Name      = "service-fabric-sdk"
        DependsOn = "[CircleChoco]choco"
    }
}
