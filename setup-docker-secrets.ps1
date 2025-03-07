# Setup Docker Secrets for Nextcloud App Development

# Create secrets directory if it doesn't exist
if (-not (Test-Path -Path "./secrets")) {
    New-Item -ItemType Directory -Path "./secrets" | Out-Null
    Write-Host "Created secrets directory" -ForegroundColor Green
}

# Function to generate a random password
function Get-RandomPassword {
    param (
        [int]$Length = 16
    )
    $CharSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?'
    $Password = ''
    for ($i = 0; $i -lt $Length; $i++) {
        $RandomIndex = Get-Random -Minimum 0 -Maximum $CharSet.Length
        $Password += $CharSet[$RandomIndex]
    }
    return $Password
}

# Function to create a secret file
function Set-SecretFile {
    param (
        [string]$Name,
        [string]$DefaultValue,
        [bool]$GenerateRandom = $false,
        [int]$RandomLength = 16
    )

    $FilePath = "./secrets/$Name.txt"
    
    if (Test-Path -Path $FilePath) {
        Write-Host "Secret file $Name already exists" -ForegroundColor Yellow
        return
    }

    if ($GenerateRandom) {
        $Value = Get-RandomPassword -Length $RandomLength
    } else {
        $Value = Read-Host -Prompt "Enter value for $Name (leave empty for default: $DefaultValue)"
        if ([string]::IsNullOrWhiteSpace($Value)) {
            $Value = $DefaultValue
        }
    }

    Set-Content -Path $FilePath -Value $Value -NoNewline
    Write-Host "Created secret file for $Name" -ForegroundColor Green
}

# Create secret files
Write-Host "Setting up Docker secrets for Nextcloud..." -ForegroundColor Cyan

# Database secrets
Set-SecretFile -Name "mysql_root_password" -DefaultValue "nextcloud" -GenerateRandom $true
Set-SecretFile -Name "mysql_password" -DefaultValue "nextcloud" -GenerateRandom $true

# Redis secret
Set-SecretFile -Name "redis_password" -DefaultValue "nextcloud" -GenerateRandom $true

# Nextcloud admin credentials
Set-SecretFile -Name "nextcloud_admin_user" -DefaultValue "admin"
Set-SecretFile -Name "nextcloud_admin_password" -DefaultValue "admin" -GenerateRandom $true

# Set proper permissions on secrets directory
Write-Host "Setting proper permissions on secrets directory..." -ForegroundColor Cyan

# On Windows, we can use icacls to set permissions
if ($IsWindows -or $env:OS -match "Windows") {
    icacls "./secrets" /inheritance:r | Out-Null
    icacls "./secrets" /grant:r "$env:USERNAME:(OI)(CI)F" | Out-Null
    Write-Host "Permissions set for Windows" -ForegroundColor Green
}

# Add .gitignore entry for secrets directory if not already present
if (-not (Select-String -Path ".gitignore" -Pattern "/secrets/" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -Path ".gitignore" -Value "`n# Secrets directory`n/secrets/`n"
    Write-Host "Added secrets directory to .gitignore" -ForegroundColor Green
}

Write-Host "`nDocker secrets setup complete!" -ForegroundColor Green
Write-Host "IMPORTANT: Never commit the 'secrets' directory to version control!" -ForegroundColor Red
Write-Host "You can now start your Nextcloud environment with: docker-compose up -d" -ForegroundColor Cyan
