# PowerShell script to set up Docker secrets for secure Nextcloud deployment

Write-Host "Setting up Docker secrets for secure Nextcloud deployment..." -ForegroundColor Green

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges for file permission management." -ForegroundColor Yellow
    Write-Host "Consider running PowerShell as Administrator for best results." -ForegroundColor Yellow
}

# Create secrets directory if it doesn't exist
$secretsDir = "./secrets"
if (-not (Test-Path $secretsDir)) {
    Write-Host "Creating secrets directory..." -ForegroundColor Yellow
    New-Item -Path $secretsDir -ItemType Directory | Out-Null

    # Set restrictive permissions on the secrets directory
    try {
        $acl = Get-Acl -Path $secretsDir
        $acl.SetAccessRuleProtection($true, $false)
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($currentUser, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl -Path $secretsDir -AclObject $acl
        Write-Host "Secured secrets directory with restrictive permissions." -ForegroundColor Green
    }
    catch {
        Write-Host "Warning: Could not set restrictive permissions on secrets directory: $_" -ForegroundColor Yellow
        Write-Host "Please ensure the directory is only accessible to authorized users." -ForegroundColor Yellow
    }
}

# Function to generate a random password
function Generate-SecurePassword {
    param (
        [int]$length = 16
    )

    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?'
    $random = New-Object System.Random
    $password = 1..$length | ForEach-Object { $charSet[$random.Next(0, $charSet.Length)] }
    return -join $password
}

# Function to create a secret file if it doesn't exist
function Create-SecretFile {
    param (
        [string]$fileName,
        [string]$defaultValue,
        [switch]$generateRandom
    )

    $filePath = Join-Path $secretsDir $fileName

    if (-not (Test-Path $filePath)) {
        $value = $defaultValue

        if ($generateRandom) {
            $value = Generate-SecurePassword
        }

        Write-Host "Creating secret file: $fileName" -ForegroundColor Yellow
        Set-Content -Path $filePath -Value $value -NoNewline

        # Set restrictive permissions on the secret file
        try {
            $acl = Get-Acl -Path $filePath
            $acl.SetAccessRuleProtection($true, $false)
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($currentUser, "FullControl", "Allow")
            $acl.AddAccessRule($rule)
            Set-Acl -Path $filePath -AclObject $acl
        }
        catch {
            Write-Host "Warning: Could not set restrictive permissions on $fileName: $_" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Secret file already exists: $fileName" -ForegroundColor Cyan
    }
}

# Create secret files with secure random passwords
Create-SecretFile -fileName "mysql_root_password.txt" -defaultValue "nextcloud" -generateRandom
Create-SecretFile -fileName "mysql_password.txt" -defaultValue "nextcloud" -generateRandom
Create-SecretFile -fileName "redis_password.txt" -defaultValue "nextcloud" -generateRandom
Create-SecretFile -fileName "nextcloud_admin_user.txt" -defaultValue "admin"
Create-SecretFile -fileName "nextcloud_admin_password.txt" -defaultValue "admin" -generateRandom

# Display information about the secrets
Write-Host "`nDocker secrets have been set up successfully!" -ForegroundColor Green
Write-Host "The following secret files have been created:" -ForegroundColor Cyan
Write-Host "- mysql_root_password.txt: MariaDB root password" -ForegroundColor Cyan
Write-Host "- mysql_password.txt: MariaDB nextcloud user password" -ForegroundColor Cyan
Write-Host "- redis_password.txt: Redis password" -ForegroundColor Cyan
Write-Host "- nextcloud_admin_user.txt: Nextcloud admin username" -ForegroundColor Cyan
Write-Host "- nextcloud_admin_password.txt: Nextcloud admin password" -ForegroundColor Cyan

Write-Host "`nIMPORTANT SECURITY NOTES:" -ForegroundColor Yellow
Write-Host "1. These secrets are stored as plain text files and should be protected." -ForegroundColor Yellow
Write-Host "2. Do not commit the 'secrets' directory to version control." -ForegroundColor Yellow
Write-Host "3. Ensure only authorized users have access to these files." -ForegroundColor Yellow
Write-Host "4. For production environments, consider using a dedicated secrets management solution." -ForegroundColor Yellow

Write-Host "`nTo use these secrets with the secure docker-compose configuration:" -ForegroundColor Green
Write-Host "docker-compose -f docker-compose-fixed.yml up -d" -ForegroundColor Cyan
