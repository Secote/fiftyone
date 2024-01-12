# Installs the `fiftyone` package and its dependencies.
#
# Usage:
#   PowerShell -File install.ps1

# Show usage information
function Show-Help {
    Write-Host "Usage:  PowerShell -File install.ps1 [-h] [-d] [-e] [-m] [-p] [-v]"
    Write-Host ""
    Write-Host "Getting help:"
    Write-Host "-h      Display this help message."
    Write-Host ""
    Write-Host "Custom installations:"
    Write-Host "-d      Install developer dependencies."
    Write-Host "-e      Source install of voxel51-eta."
    Write-Host "-m      Install MongoDB from scratch, rather than installing fiftyone-db."
    Write-Host "-p      Install only the core python package, not the App."
    Write-Host "-v      Voxel51 developer install (don't install fiftyone-brain)."
}

# httpcore 0.15.0 requires anyio==3.*, but you'll have anyio 4.2.0 which is incompatible.
# httpcore 0.15.0 requires h11<0.13,>=0.11, but you'll have h11 0.14.0 which is incompatible.
# fiftyone 0.21.4 requires fiftyone-brain<0.14,>=0.13, but you'll have fiftyone-brain 0.14.2 which is incompatible.
# fiftyone 0.21.4 requires sse-starlette<1,>=0.10.3, but you'll have sse-starlette 1.8.2 which is incompatible.
# fiftyone 0.21.4 requires starlette<0.27,>=0.24.0, but you'll have starlette 0.27.0 which is incompatible.
# fastapi 0.108.0 requires starlette<0.33.0,>=0.29.0, but you'll have starlette 0.27.0 which is incompatible.
# Parse flags
$SHOW_HELP = $false
$DEV_INSTALL = $false
$SOURCE_ETA_INSTALL = $false
$SCRATCH_MONGODB_INSTALL = $false
$BUILD_APP = $true
$VOXEL51_INSTALL = $false
$NODE_VERSION = "17.9.0"
# Do this last since `source` can exit Python virtual environments
if ($BUILD_APP) {
    Write-Host "***** INSTALLING FIFTYONE-APP *****"
    # $url = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-noinstall.zip"
    # $output = "./nvm-noinstall.zip"

    # Invoke-WebRequest -Uri $url -OutFile $output
    # # Unzip the file to current directory
    # Expand-Archive -Path "nvm-noinstall.zip" -DestinationPath "$HOME/.nvm"
    $NVM_DIR = "$HOME/.nvm"
    [Environment]::SetEnvironmentVariable("NVM_DIR", $NVM_DIR, "User")
    if (Test-Path "$NVM_DIR/nvm.exe") { . "$NVM_DIR/nvm.exe" }
    Write-Host "***** INSTALLING Node $NODE_VERSION *****"
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    Write-Host "***** INSTALLING yarn *****"
    npm install -g yarn
    # if (Test-Path "$HOME/.bashrc") {
    #     . "$HOME/.bashrc"
    # }
    # elseif (Test-Path "$HOME/.bash_profile") {
    #     . "$HOME/.bash_profile"
    # }
    # else {
    #     Write-Host "WARNING: unable to locate a bash profile to 'source'; you may need to start a new shell"
    # }
    Set-Location "app"
    Write-Host "Building the App. This will take a minute or two..."
    yarn install > $null
    yarn build
    Set-Location ".."
}

Write-Host "***** INSTALLATION COMPLETE *****"
