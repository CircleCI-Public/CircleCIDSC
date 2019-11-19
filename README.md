# circleci-dsc
Windows Powershell DSC


# Community CircleCI DSC Resource

This resource is aimed at people who would like to make a build environment compatible with CircleCI for windows. An example config with all of the software we include on our windows iamge for cloud looks like this.

```pwsh
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

The maximum envelope size for WinRM is not sufficient for installing large packages. To increase the envelope size use `winrm set winrm/config @{MaxEnvelopeSizekb=”153600″}` - this exampe will increase it to 150MB.

### Python DSC resource - Has to be run twice

There is an open bug with our python resource that causes it to have issues getting conda onto the path, the cause is unknown, but in practice it's fine becuase multiple reboots are required to finished a configuration. Over the multiple reboots it seems to work.

### Many Reboots required
Currently we observe that 3 reboots are required to finish our standard configuration. DSC handles resuming gracefully so no user intervention is needed. Just good to be aware of.
