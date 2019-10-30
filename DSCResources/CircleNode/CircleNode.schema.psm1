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

            return New-Object -TypeName PSCustomObject -Property @{
                'Result'   = @{
                    'Versions' =  $nvmVersions;
                    'Selected' = $selectedVersion
                }
            }
        }
        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke()
            if ($state.Result.Versions -And $state.Result.Versions.Contains($using:Version)) {
                Write-Verbose -Message ('Version {0} present in {1}' -f $using:Version, $state.Result)
                if ($using:DefaultVersion) {
                    if ($state.Result.Selected -eq $using:Version) {
                        return $true
                        Write-Verbose -Message ('Version {0} selected' -f $state.Selected)
                    }
                    else {
                        Write-Verbose -Message ('Version {0} selected expected {1}' -f $state.Result, $using:Version)
                        return $false
                    }
                }
                else {
                    return $true
                }
            }
            else {
                Write-Verbose -Message ('Version {0} missing in {1}' -f $using:Version, $state.Result)
                return $false
            }
        }

        SetScript  = {
            $(nvm install $using:Version)
            if ($using:DefaultVersion) {
                Write-Verbose "setting $using:Version as Default version"
                $(nvm use $using:Version)
                $(nvm on)
                $(npm install -g yarn)
            }
        }
        DependsOn  = '[cChocoPackageInstaller]nvm-portable'
    }
}
