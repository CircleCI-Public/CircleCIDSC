Configuration CircleNvidia {
    Import-DscResource -Module cChoco

    cChocoPackageInstaller installNvidia {
        Name = 'cuda'
        Version = '10.1.243'
        Source = 'chocolatey'
    }
    
    Script InstallCudnn {
        GetScript = {
            return @{
                Result = @{
                    Version = 'v7.6.4.38'
                }
            }
        }

        TestScript = {
            return ($(Test-Path -Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\bin\cudnn64_7.dll') `
              -and $(Test-Path -Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\include\cudnn.h') `
              -and $(Test-Path -Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\lib\x64\cudnn.lib'))
        }

        SetScript = {
            $output = "cudnn.zip"
            $url = "https://storage.googleapis.com/circleci-image-file/cudnn-10.1-windows10-x64-v7.6.4.38.zip"
            (New-Object System.Net.WebClient).DownloadFile($url, $output)
            Expand-Archive -Path $output -DestinationPath C:\cudnn
            
            cp C:\cudnn\cuda\bin\cudnn64_7.dll 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\bin'
            cp C:\cudnn\cuda\include\cudnn.h 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\include'
            cp C:\cudnn\cuda\lib\x64\cudnn.lib 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v10.1\lib\x64'
        }

        DependsOn = "[cChocoPackageInstaller]installNvidia"
    }
}