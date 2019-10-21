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
            $path = $(Get-MachinePath).split(';')
            return New-Object -TypeName PSCustomObject -Property @{'Result' = $path }
        }
        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke().Result
            if ($state -contains $using:PathItem) {
                Write-Verbose -Message "$using:PathItem is present in machine path"
                return $true
            }
            else {
                Write-Verbose -Message "$using:PathItem is missing in machine path"
                return $false
            }
        }
        SetScript  = {
            Write-Verbose -Message "adding $using:PathItem to path"
            Add-MachinePathItem $using:PathItem
        }
    }

}