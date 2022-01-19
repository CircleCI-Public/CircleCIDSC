Configuration CircleNvidia {
    Import-DscResource -Module cChoco

    # cuda 11 requires reboot, will address in next release

    cChocoPackageInstaller installNvidia {
        Name = 'cuda'
        Version = '11.5.0.49613'
        Source = 'chocolatey'
    }

    Write-Output "CUDA INSTALL LOG:"
    Get-Content C:\ProgramData\chocolatey\logs\chocolatey.log
    Write-Output "END CUDA INSTALL LOG:"
    
    Script InstallCudnn {
        GetScript = {
            return @{
                Result = @{
                    Version = 'v7.6.4.38'
                }
            }
        }

        TestScript = {
            return ($(Test-Path -Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5\bin\cudnn64_7.dll') `
              -and $(Test-Path -Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5\include\cudnn.h') `
              -and $(Test-Path -Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5\lib\x64\cudnn.lib'))
        }

        SetScript = {
            $output = "cudnn.zip"
            $url = "https://storage.googleapis.com/circleci-image-file/cudnn-10.1-windows10-x64-v7.6.4.38.zip"
            (New-Object System.Net.WebClient).DownloadFile($url, $output)
            Expand-Archive -Path $output -DestinationPath C:\cudnn
            
            cp C:\cudnn\cuda\bin\cudnn64_7.dll 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5\bin'
            cp C:\cudnn\cuda\include\cudnn.h 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5\include'
            cp C:\cudnn\cuda\lib\x64\cudnn.lib 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.5\lib\x64'
        }

        DependsOn = "[cChocoPackageInstaller]installNvidia"
    }
}