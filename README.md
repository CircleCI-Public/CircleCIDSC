# circleci-dsc
Windows Powershell DSC


# Community CircleCI DSC Resource

This resource is aimed at people who would like to make a build environment compatible with CircleCI for windows. An example config with all of the software we include on our windows iamge for cloud looks like this. A full example including setting up all the packages needed is below.

```pwsh
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Write-Host "Setting local execution policy"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine  -ErrorAction Continue | Out-Null
Get-ExecutionPolicy -List
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
& mkdir 'C:\Program Files\WindowsPowerShell\Modules\cChoco\'
Invoke-WebRequest -Uri 'https://github.com/chocolatey/cChoco/archive/development.zip' -OutFile 'C:\cChoco.zip'
Expand-Archive -LiteralPath 'C:\cChoco.zip' -DestinationPath 'C:\\'
Copy-Item -Path 'C:\cChoco-development\*' -Recurse -Destination 'C:\Program Files\WindowsPowerShell\Modules\cChoco\'
Install-Module -Name ComputerManagementDsc -Force
Install-Module -Name CircleCIDSC -RequiredVersion 1.0.879 -Force
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 512000

Configuration CircleBuildHost {
    Import-DscResource -Module CircleDscResources
    Import-DscResource -Module cChoco
    Import-DscResource -ModuleName 'PackageManagement' -ModuleVersion '1.0.0.1'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'

    node localhost {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $False
        }

        CircleUsers "users" { }
        CircleBuildAgentPreReq buildAgentPreReq { }
        CircleCloudTools cloudTools { }
        CircleDevTools devTools { }
        CircleMicrosoftTools MicrosoftTools { }
    }
}

$cd = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}
CircleBuildHost -ConfigurationData $cd
Start-DscConfiguration -Path .\CircleBuildHost  -Wait -Force -Verbose
```
Included are resources are:

* CircleUsers, for creating the users and groups circleCI needs to login to the box.
* CircleBuildAgentPreReq, for installing everything the circleCI build agent needs to run.
* CircleCloudTools, for installing aws, azure, and gcp tooling.
* CircleDevTools, for installing ruby, node, python (there are some cavets with python), and a varity of common tools.
* CircleMicrosoftTools, for installing visual studio, .net, the windows sdk, winAppDriver
* CircleNvidia, for installing nvidia drivers and cuda. 
* CirclePython, for installing python, can be parametrized with version, and if it should be the default installation. Uses miniconda to manage versions.
* CircleNode,   for installing node, can be parametrized with version and if it should be the default version. Uses nvm to manage versions.
* CirclePath,   Will ensure that a value is present once on the machine path.

Examples for all of the above resources are included in the examples directory.

## Building an image based of off this DSC resource

Check out the ExamplePacker repo for a end-to-end example of building a image based off of this resource. More documentation on how to use it is in the readme.

## Contributing

Happy to accept new features and fixes. Outstanding issues which can be worked on tagged `Up For Grabs` under issues.

### Submitting a PR

Here's the general process of fixing an issue in the DSC Resource Kit:
1. Fork the repository.
3. Clone your fork to your machine.
4. It's preferred to create a non-master working branch where you store updates.
5. Make changes.
6. Write pester tests to ensure that the issue is fixed.
7. Submit a pull request to the development branch.
8. Make sure all tests are passing in AppVeyor for your pull request.
9. Make sure your code does not contain merge conflicts.
10. Address comments (if any).

### Build and Publishing

CircleCI is used to package up the resource and publish to the PowerShell Gallery (on successful on master only). When you push to a branch all of the resources which have tests will execute. We keep master green.

## Known Issues / Troubleshooting

### WS-Management - Exceeds the maximum envelope size allowed

The maximum envelope size for WinRM is not sufficient for installing large packages. To increase the envelope size use `winrm set winrm/config @{MaxEnvelopeSizekb=”153600″}` - this exampe will increase it to 150MB. The PackerExample repo has an example of this.

### Python DSC resource - Has to be run twice

There is an open bug with our python resource that causes it to have issues getting conda onto the path, the cause is unknown, but in practice it's fine becuase multiple reboots are required to finished a configuration. Over the multiple reboots it seems to work.

### Many Reboots required
Currently we observe that 3 reboots are required to finish our standard configuration. DSC handles resuming gracefully so no user intervention is needed. Just good to be aware of.

### Code signing and authenticated sessions
When the build agent sshs into the build it lacks the credentials that would typically be present in a windows environement, consequently some work arounds may be helpful for privilaged operations.

The simpliest way to do so is to simply reset the password of the CircleCI user and create a set of powershell credentials then do the operation in a more privilaged subshell.

```pwsh
Add-Type -AssemblyName System.web
$raw_password = [System.Web.Security.Membership]::GeneratePassword(42, 10)
$password = ConvertTo-SecureString $raw_password -AsPlainText -Force
Set-LocalUser -Name "circleci" -Password $password
$username = "circleci"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
Start-Job -Credential $cred -ScriptBlock { # Certificate publisher
  #Do privilaged operation here
}

```

### cChoco Development version
For some reason the cChoco DSC resource has not been updated on the powershell gallery in quite some time. The development version has some needed parameters so we use that.

