#!/bin/bash
# Bash script to push files to GitHub repository
# This script uses the GitHub CLI (gh) to push files to a repository

# Default configuration
BRANCH="master"

# Get repository information from arguments or prompt
if [ $# -ge 2 ]; then
    REPO_OWNER="$1"
    REPO_NAME="$2"
    [ $# -ge 3 ] && BRANCH="$3"
else
    echo "Enter GitHub repository owner:"
    read REPO_OWNER
    echo "Enter GitHub repository name:"
    read REPO_NAME
fi

# Prompt for token securely
echo "Enter your GitHub token:"
read -s TOKEN

# Set GitHub token for authentication
export GITHUB_TOKEN="$TOKEN"

echo "Pushing files to GitHub repository: $REPO_OWNER/$REPO_NAME"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/"
    exit 1
fi

# Login to GitHub
echo "Logging in to GitHub..."
gh auth status
if [ $? -ne 0 ]; then
    echo "Authenticating with GitHub token..."
    gh auth login --with-token < <(echo "$TOKEN")
fi

# Clone the repository if it doesn't exist
TEMP_DIR="temp-github-repo"
if [ ! -d "$TEMP_DIR" ]; then
    echo "Cloning repository..."
    gh repo clone "$REPO_OWNER/$REPO_NAME" "$TEMP_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository. Please check your credentials and repository name."
        exit 1
    fi
fi

# Copy files to the cloned repository
echo "Copying files to the repository..."
cp "DOCKER_PERMISSIONS_README.md" "$TEMP_DIR/"
cp "fix-docker-permissions.ps1" "$TEMP_DIR/"
cp "fix-docker-permissions.sh" "$TEMP_DIR/"

# Commit and push changes
echo "Committing and pushing changes..."
cd "$TEMP_DIR"

# Get git user info from environment or prompt
GIT_USER_NAME="${GIT_USER_NAME:-$(git config --global user.name)}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-$(git config --global user.email)}"

if [ -z "$GIT_USER_NAME" ]; then
    echo "Enter your Git username:"
    read GIT_USER_NAME
fi
if [ -z "$GIT_USER_EMAIL" ]; then
    echo "Enter your Git email:"
    read GIT_USER_EMAIL
fi

git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"
git add .
git commit -m "Add Docker permission fix scripts and documentation"
git push origin "$BRANCH"

echo "Files successfully pushed to GitHub repository: $REPO_OWNER/$REPO_NAME!"
