<#
    .SYNOPSIS
        This module should contain shared helper functions that are used by more
        than one test.
#>



function Update-Paths {
    [CmdletBinding()]
    param()
    foreach($level in "Machine","User") {
    [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
        # For Path variables, append the new values, if they're not already in there
        if($_.Name -match 'Path$') {
            $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -split ';' | Select-Object -unique) -join ';'
        }
        $_
    } | Set-Content -Path { "Env:$($_.Name)" }
    }
}

function Remove-ItemFromPath {
    [CmdletBinding()]
    param (
        #The item to remove from the path
        [Parameter(Mandatory)]
        [String] $PathItem
    )
    $path = [System.Environment]::GetEnvironmentVariable(
        'PATH',
        'User'
    )
    # Remove unwanted elements
    $path = ($path.Split(';') | Where-Object { $_.TrimEnd('\') -ne $PathItem }) -join ';'
    # Set the path
    [System.Environment]::SetEnvironmentVariable(
        'PATH',
        $path,
        'User'
    )  
}

<#
    .SYNOPSIS
        Returns $true if the the environment variable APPVEYOR is set to $true,
        and the environment variable CONFIGURATION is set to the value passed
        in the parameter Type.

    .PARAMETER Name
        Name of the test script that is called. Defaults to the name of the
        calling script.

    .PARAMETER Type
        Type of tests in the test file. Can be set to Unit or Integration.

    .PARAMETER Category
        Optional. One or more categories to check if they are set in
        $env:CONFIGURATION. If this are not set, the parameter Type
        is used as category.
#>
function Test-SkipContinuousIntegrationTask
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name = $MyInvocation.PSCommandPath.Split('\')[-1],

        [Parameter(Mandatory = $true)]
        [ValidateSet('Unit', 'Integration')]
        [System.String]
        $Type,

        [Parameter()]
        [System.String[]]
        $Category
    )

    # Support using only the Type parameter as category names.
    if (-not $Category)
    {
        $Category = @($Type)
    }

    $result = $false

    if ($Type -eq 'Integration' -and -not $env:APPVEYOR -eq $true)
    {
        Write-Warning -Message ('{1} test for {0} will be skipped unless $env:APPVEYOR is set to $true' -f $Name, $Type)
        $result = $true
    }

    if ($env:APPVEYOR -eq $true -and $env:CONFIGURATION -notin $Category)
    {
        Write-Verbose -Message ('{1} tests in {0} will be skipped unless $env:CONFIGURATION is set to ''{1}''.' -f $Name, ($Category -join ''', or ''')) -Verbose
        $result = $true
    }

    return $result
}

<#
    .SYNOPSIS
        Returns $true if the the environment variable APPVEYOR is set to $true,
        and the environment variable CONFIGURATION is set to the value passed
        in the parameter Type.

    .PARAMETER Category
        One or more categories to check if they are set in $env:CONFIGURATION.
#>
function Test-ContinuousIntegrationTaskCategory
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Category
    )

    $result = $false

    if ($env:APPVEYOR -eq $true -and $env:CONFIGURATION -in $Category)
    {
        $result = $true
    }

    return $result
}
