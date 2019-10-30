Configuration CircleBuildAgentPreReq {
    Import-DscResource -Module cChoco
    Import-DscResource -Module CircleCIDSC

    CircleChoco choco { }

    cChocoPackageInstaller installGit
    {
        Name      = "git"
        Params    = "/GitAndUnixToolsOnPath"
        Source    = "chocolatey"
    }
    cChocoPackageInstallerSet buildAgentTools
    {
        Source    = "chocolatey"
        Name      = @(
            "git-lfs"
            "7zip.portable"
            "gzip")
        DependsOn = "[cChocoPackageInstaller]installGit"
    }
}
