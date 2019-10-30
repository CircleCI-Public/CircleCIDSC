Configuration CirclePython {
    [CmdletBinding()]
    param
    (
        # The name of this python env
        [parameter(Mandatory)]
        [String] $EnvName,

        # The version of python to install in this environment
        [Parameter(Mandatory)]
        [String] $Version,

        [System.Boolean] $DefaultVersion = $false
    )

    Import-DscResource -Module CricleCIDSC
    Import-DscResource -Module cChoco
    CircleChoco choco { }

    cChocoPackageInstaller miniconda3
    {
        Name      = 'miniconda3'
        Params    = '/AddToPath:1'
        DependsOn = '[CircleChoco]choco'
    }


    # Name gets set to "installedPythons" becuase powershell
    Script $EnvName {
        GetScript  = {
            $matches = $null
            # TODO: THIS IS STILL BROKEN, Currently it grabs the path to the python as well as the name
            # But the DSC still gets the job done.
            $envs = $(conda env list) | Where-Object { $_ -Match "python\d+(\.\d+)?" }
            $pythonVersions = @()
            if ($envs) {
                $pythonVersions = $envs
            }
            return New-Object -TypeName PSCustomObject -Property @{'Result' = $pythonVersions }
        }

        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke()
            if ($state.Result -And $state.Result.Contains($using:EnvName)) {
                Write-Verbose -Message ('Version {0} present in {1}' -f $using:EnvName, $state.Result)
            }
            else {
                Write-Verbose -Message ('Version {0} missing in {1}' -f $using:EnvName, $state.Result)
                return $false
            }
            return $true
        }

        SetScript  = {
            $(conda update -y -n base -c defaults conda)
            $(conda create -y -n $using:EnvName python=$using:Version pip)
            if ( $using:DefaultVersion ) {
                $(conda config --set changeps1 false)
                $(conda init)
            }
        }
        DependsOn  = '[cChocoPackageInstaller]miniconda3'
    }
}
