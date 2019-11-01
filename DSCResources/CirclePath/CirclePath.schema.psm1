Configuration CirclePath {
    [CmdletBinding()]
    param
    (
        #The item to add to the path
        [Parameter(Mandatory)]
        [String] $PathItem
    )

    Script "SetPath" {
        GetScript  = {
            $currentPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
            return @{Result = $currentPath}
        }
        TestScript = {
            $result = [scriptblock]::Create($GetScript).Invoke().Result
            $state = $result.split(';')
            if ($state -contains $using:PathItem) {
                Write-Verbose -Message "$using:PathItem is present in machine path"
                return $True
            }
            else {
                Write-Verbose -Message $result
                Write-Verbose -Message "$using:PathItem is missing in machine path"
                return $False
            }
        }
        SetScript  = {
            Write-Verbose -Message "adding $using:PathItem to path"
            $currentPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
            $newPath = $using:PathItem + ';' + $currentPath
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
            foreach($level in "Machine","User") {
                [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
                    # For Path variables, append the new values, if they're not already in there
                    if($_.Name -match '^Path$') {
                        $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -split ';' | Select-Object -unique) -join ';'
                    }
                    Write-Information -Message "$($_.Name) : $($_.Value)"
                    $_
                } | Set-Content -Path { "Env:$($_.Name)" }
            }

        }
    }
}
