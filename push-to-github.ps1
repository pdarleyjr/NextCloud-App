# PowerShell script to push files to GitHub repository
# This script uses the GitHub CLI (gh) to push files to a repository

param (
    [Parameter(Mandatory=$false)]
    [string]$repoOwner = "",
    [Parameter(Mandatory=$false)]
    [string]$repoName = "",
    [Parameter(Mandatory=$false)]
    [string]$branch = "master"
)

# Prompt for repository information if not provided
if ([string]::IsNullOrEmpty($repoOwner) -or [string]::IsNullOrEmpty($repoName)) {
    $repoOwner = Read-Host -Prompt "Enter GitHub repository owner"
    $repoName = Read-Host -Prompt "Enter GitHub repository name"
}


# Prompt for token instead of hardcoding it
$token = Read-Host -Prompt "Enter your GitHub token" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
$tokenPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

# Set GitHub token for authentication
# Note: Environment variables are only visible to the current process
$env:GITHUB_TOKEN = $tokenPlain

Write-Host "Pushing files to GitHub repository: $repoOwner/$repoName" -ForegroundColor Green

# Check if gh CLI is installed
if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/" -ForegroundColor Red
    exit 1
}

# Login to GitHub
Write-Host "Logging in to GitHub..." -ForegroundColor Yellow
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "Authenticating with GitHub token..." -ForegroundColor Yellow
    gh auth login --with-token
}

# Clone the repository if it doesn't exist
$tempDir = "temp-github-repo"
if (!(Test-Path $tempDir)) {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    gh repo clone "$repoOwner/$repoName" $tempDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to clone repository. Please check your credentials and repository name." -ForegroundColor Red
        exit 1
    }
}

# Copy files to the cloned repository
Write-Host "Copying files to the repository..." -ForegroundColor Yellow
Copy-Item "DOCKER_PERMISSIONS_README.md" -Destination "$tempDir/" -Force
Copy-Item "fix-docker-permissions.ps1" -Destination "$tempDir/" -Force
Copy-Item "fix-docker-permissions.sh" -Destination "$tempDir/" -Force

# Commit and push changes
Write-Host "Committing and pushing changes..." -ForegroundColor Yellow
Set-Location $tempDir

# Get git user info from environment or prompt
$gitUserName = $env:GIT_USER_NAME
$gitUserEmail = $env:GIT_USER_EMAIL

if ([string]::IsNullOrEmpty($gitUserName)) {
    $gitUserName = Read-Host -Prompt "Enter your Git username"
}
if ([string]::IsNullOrEmpty($gitUserEmail)) {
    $gitUserEmail = Read-Host -Prompt "Enter your Git email"
}

git config user.name "$gitUserName"
git config user.email "$gitUserEmail"
git add .
git commit -m "Add Docker permission fix scripts and documentation"
git push origin "$branch"

# Clean up
Set-Location ..
Write-Host "Files successfully pushed to GitHub repository: $repoOwner/$repoName!" -ForegroundColor Green
