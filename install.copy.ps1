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
# }

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

$arguments = $args
for ($i = 0; $i -lt $arguments.Length; $i++) {
    $arg = $arguments[$i]
    switch ($arg) {
        "-h" { $SHOW_HELP = $true }
        "-d" { $DEV_INSTALL = $true }
        "-e" { $SOURCE_ETA_INSTALL = $true }
        "-m" { $SCRATCH_MONGODB_INSTALL = $true }
        "-p" { $BUILD_APP = $false }
        "-v" { $VOXEL51_INSTALL = $true }
        default { Show-Help; exit 0 }
    }
}

if ($SHOW_HELP) {
    Show-Help
    exit 0
}

$ErrorActionPreference = "Stop"
$NODE_VERSION = "17.9.0"
$OS = $env:OS
$ARCH = $env:PROCESSOR_ARCHITECTURE

if ($SCRATCH_MONGODB_INSTALL) {
    Write-Host "***** INSTALLING MONGODB FROM SCRATCH *****"
    $MONGODB_VERSION = "6.0.5"
    $INSTALL_MONGODB = $true

    $fiftyoneDir = Join-Path $HOME ".fiftyone"
    $binDir = Join-Path $fiftyoneDir "bin"
    $mongoDir = Join-Path $fiftyoneDir "var/lib/mongo"

    if (Test-Path (Join-Path $binDir "mongod")) {
        $currentVersion = (mongod --version | Select-String -Pattern "db version").ToString().Substring(12)
        if ($currentVersion -eq $MONGODB_VERSION) {
            Write-Host "MongoDB v$MONGODB_VERSION already installed"
            $INSTALL_MONGODB = $false
        }
        else {
            Write-Host "Upgrading MongoDB v$currentVersion to v$MONGODB_VERSION"
        }
    }

    if ($INSTALL_MONGODB) {
        Write-Host "Installing MongoDB v$MONGODB_VERSION"
        if ($OS -eq "Darwin") {
            $MONGODB_BUILD = "mongodb-macos-x86_64-$MONGODB_VERSION"
            Invoke-WebRequest -Uri "https://fastdl.mongodb.org/osx/$MONGODB_BUILD.tgz" -OutFile "mongodb.tgz"
            tar -zxvf mongodb.tgz
            Move-Item -Path "$MONGODB_BUILD/bin/*" -Destination $binDir
            Remove-Item -Path "mongodb.tgz"
            Remove-Item -Path "$MONGODB_BUILD" -Recurse
        }
        elseif ($OS -eq "Linux") {
            $MONGODB_BUILD = "mongodb-linux-x86_64-ubuntu2204-$MONGODB_VERSION"
            Invoke-WebRequest -Uri "https://fastdl.mongodb.org/linux/$MONGODB_BUILD.tgz" -OutFile "mongodb.tgz"
            tar -zxvf mongodb.tgz
            Move-Item -Path "$MONGODB_BUILD/bin/*" -Destination $binDir
            Remove-Item -Path "mongodb.tgz"
            Remove-Item -Path "$MONGODB_BUILD" -Recurse
        }
        else {
            Write-Host "WARNING: unsupported OS, skipping MongoDB installation"
        }
    }
}
else {
    Write-Host "***** INSTALLING FIFTYONE-DB *****"
    pip install fiftyone-db
}

if (-not $VOXEL51_INSTALL) {
    Write-Host "***** INSTALLING FIFTYONE-BRAIN *****"
    pip install --upgrade fiftyone-brain
}

Write-Host "***** INSTALLING FIFTYONE *****"
if ($DEV_INSTALL -or $VOXEL51_INSTALL) {
    Write-Host "Performing dev install"
    pip install -r requirements/dev.txt
    pre-commit install
    pip install -e .
}
else {
    # python -m pip install --upgrade pip
    # python -m pip install pyyaml
    # pip install sse-starlette
    # pip install matplotlib
    pip install -r requirements.txt
    pip install .
}

if ($SOURCE_ETA_INSTALL) {
    Write-Host "***** INSTALLING ETA *****"
    if (-not (Test-Path "eta")) {
        Write-Host "Cloning ETA repository"
        git clone https://github.com/voxel51/eta
    }
    Set-Location "eta"
    if ($DEV_INSTALL -or $VOXEL51_INSTALL) {
        pip install -e .
    }
    else {
        pip install .
    }
    if (-not (Test-Path "eta/config.json")) {
        Write-Host "Installing default ETA config"
        Copy-Item -Path "config-example.json" -Destination "eta/config.json"
    }
    Set-Location ".."
}

# Do this last since `source` can exit Python virtual environments
if ($BUILD_APP) {
    Write-Host "***** INSTALLING FIFTYONE-APP *****"
    Invoke-WebRequest -Uri "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-noinstall.zip" -UseBasicParsing | Invoke-Expression
    # Unzip the file to current directory
    Expand-Archive -Path "nvm-noinstall.zip" -DestinationPath "$HOME/.nvm"
    $NVM_DIR = "$HOME/.nvm"
    [Environment]::SetEnvironmentVariable("NVM_DIR", $NVM_DIR, "User")
    if (Test-Path "$NVM_DIR/nvm.sh") { . "$NVM_DIR/nvm.sh" }
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    npm install -g yarn
    if (Test-Path "$HOME/.bashrc") {
        . "$HOME/.bashrc"
    }
    elseif (Test-Path "$HOME/.bash_profile") {
        . "$HOME/.bash_profile"
    }
    else {
        Write-Host "WARNING: unable to locate a bash profile to 'source'; you may need to start a new shell"
    }
    Set-Location "app"
    Write-Host "Building the App. This will take a minute or two..."
    yarn install > $null
    yarn build
    Set-Location ".."
}

Write-Host "***** INSTALLATION COMPLETE *****"
