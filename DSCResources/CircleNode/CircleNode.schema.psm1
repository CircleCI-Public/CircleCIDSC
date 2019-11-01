Configuration CircleNode {
    param (
        # Parameterhelp description
        [Parameter(Mandatory)]
        [String]
        $Version,

        [System.Boolean]
        $DefaultVersion
    )

    Import-DscResource -Module CircleCIDSC
    Import-DscResource -Module cChoco
    CircleChoco choco { }

    cChocoPackageInstaller nvm-portable
    {
        Name      = 'nvm.portable'
        Version   = '1.1.7'
        DependsOn = '[CircleChoco]choco'
    }

    CirclePath nvm-home-path
    {
       PathItem = "C:\ProgramData\nvm"
       DependsOn = '[cChocoPackageInstaller]nvm-portable'
    }

    CirclePath nvm-symlink-path
    {
        PathItem = "C:\Program Files\nodejs"
        DependsOn = '[CirclePath]nvm-home-path'
    }

    Script InstallNode {
        GetScript  = {
            $matches = $null
            $(nvm list) | Where-Object { $_ -match '\d+\.\d+\.\d+' }
            if ($matches) {
                $nvmVersions = $matches
            }
            else {
                $nvmVersions = @()
            }
            $(nvm list) | Where-Object { $_ -match '\* \d+\.\d+\.\d+' }
            if ( $matches ) {
                $selectedVersion = $matches[0]
            }
            else {
                $selectedVersion = @()
            }

            return @{
                Result   = @{
                    Versions =  $nvmVersions;
                    Selected = $selectedVersion
                }
            }
        }
        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke()
            if ($state.Result.Versions -And $state.Result.Versions.Contains($using:Version)) {
                Write-Verbose -Message ('Version {0} present in {1}' -f $using:Version, $state.Result.Versions)
                if ($using:DefaultVersion) {
                    if ($state.Result.Selected -eq $using:Version) {
                        return $true
                        Write-Verbose -Message ('Version {0} selected' -f $state.Selected)
                    }
                    else {
                        Write-Verbose -Message ('Version {0} selected expected {1}' -f $state.Result.Selected, $using:Version)
                        return $false
                    }
                }
                else {
                    return $true
                }
            }
            else {
                Write-Verbose -Message ('Version {0} missing in {1}' -f $using:Version, $state.Result.Versions)
                return $false
            }
        }

        SetScript  = {
            nvm on
            nvm install $using:Version
            if ($using:DefaultVersion) {
                Write-Verbose "setting $using:Version as Default version"
                nvm use $using:Version
                npm install -g yarn
            }
        }
        DependsOn  = '[CirclePath]nvm-symlink-path'
    }
}
