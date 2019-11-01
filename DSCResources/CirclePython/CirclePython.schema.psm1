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

    Import-DscResource -Module CircleCIDSC
    Import-DscResource -Module cChoco
    CircleChoco choco { }

    File miniconda {
        Type = 'Directory'
        DestinationPath = 'C:\tools\miniconda3'
        Ensure = "Present"
        DependsOn = '[CircleChoco]choco'
    }


    cChocoPackageInstaller miniconda3
    {
        Name      = 'miniconda3'
        Params    = '/D:c:\Tools'
        Version   = '4.7.10'
    }

    CirclePath pythonPath {
        PathItem = "C:\tools\miniconda3\condabin"
        DependsOn = '[cChocoPackageInstaller]miniconda3'
    }


    # Name gets set to "installedPythons" becuase powershell
    Script $EnvName {
        GetScript  = {
            $matches = $null
            # TODO: THIS IS STILL BROKEN, Currently it grabs the path to the python as well as the name
            # But the DSC still gets the job done.
            $envs = $(C:\tools\miniconda3\condabin\conda env list) | Where-Object { $_ -Match "python\d+(\.\d+)?" }
            $pythonVersions = @()
            if ($envs) {
                $pythonVersions = $envs
            }
            return @{Result = $pythonVersions }
        }

        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke()
            if ($state.Result -And $state.Result.Contains($using:EnvName)) {
                Write-Verbose -Message ('Version {0} present in {1}' -f $using:EnvName, $state.Result)
                return $True
            }
            else {
                Write-Verbose -Message ('Version {0} missing in {1}' -f $using:EnvName, $state.Result)
                return $False
            }
        }

        SetScript  = {
            & 'C:\tools\miniconda3\condabin\conda' update -y -n base -c defaults conda
            & 'C:\tools\miniconda3\condabin\conda' create -y -n $using:EnvName python=$using:Version pip
            if ( $using:DefaultVersion ) {
                & 'C:\tools\miniconda3\condabin\conda' config --set changeps1 false
                & 'C:\tools\miniconda3\condabin\conda' init
            }
        }
        DependsOn  = '[CirclePath]pythonPath'
    }
}
