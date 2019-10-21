Configuration CircleCloudTools {
    Import-DscResource -ModuleName 'PackageManagement'
    Import-DscResource -Module cChoco
    Import-DscResource -Module CircleDscResources
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

    #register package source       
    PackageManagementSource Nuget
    {
        Name      = "Nuget"
        ProviderName= "Nuget"
        SourceUri = "https://nuget.org/api/v2/"  
        InstallationPolicy ="Trusted"
    }   
    
    PackageManagement ServiceFabric
    {
        Name            = "Microsoft.ServiceFabric"
        RequiredVersion = "6.5.664"
        DependsOn       = "[PackageManagementSource]Nuget"
    }                      

    cChocoPackageInstaller ServiceFabricSDK
    {
        Name      = "MicrosoftAzure-ServiceFabric-CoreSDK"
        Source    = "webpi"
        DependsOn = "[cChocoPackageInstaller]webpicmd"
    }
}
