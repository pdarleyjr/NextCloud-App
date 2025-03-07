# PowerShell script to identify and fix insecure random number generation in PHP code
# This script scans PHP files for insecure random functions and suggests secure alternatives

Write-Host "Scanning for insecure random number generation in PHP files..." -ForegroundColor Green

# Define patterns for insecure random functions
$insecurePatterns = @(
    'rand\s*\(',
    'mt_rand\s*\(',
    'array_rand\s*\(',
    'shuffle\s*\(',
    'str_shuffle\s*\(',
    'uniqid\s*\('
)

# Define secure alternatives
$secureAlternatives = @{
    'rand\s*\(' = 'random_int() - Cryptographically secure random integers'
    'mt_rand\s*\(' = 'random_int() - Cryptographically secure random integers'
    'array_rand\s*\(' = 'Use array_rand() with random_int() as a source of randomness'
    'shuffle\s*\(' = 'Custom shuffle implementation using random_int()'
    'str_shuffle\s*\(' = 'Custom string shuffle using random_int()'
    'uniqid\s*\(' = 'bin2hex(random_bytes()) - Cryptographically secure random bytes'
}

# Function to check if a file contains insecure random functions
function Find-InsecureRandom {
    param (
        [string]$filePath
    )

    $fileContent = Get-Content -Path $filePath -Raw
    $results = @()

    foreach ($pattern in $insecurePatterns) {
        if ($fileContent -match $pattern) {
            $matches = [regex]::Matches($fileContent, $pattern)
            foreach ($match in $matches) {
                $lineNumber = 0
                $lines = $fileContent.Substring(0, $match.Index).Split("`n")
                $lineNumber = $lines.Count

                $line = ($fileContent -split "`n")[$lineNumber - 1]
                $results += [PSCustomObject]@{
                    FilePath = $filePath
                    LineNumber = $lineNumber
                    Pattern = $pattern
                    Line = $line.Trim()
                    Alternative = $secureAlternatives[$pattern]
                }
            }
        }
    }

    return $results
}

# Function to generate a secure replacement for insecure random code
function Get-SecureReplacement {
    param (
        [string]$insecureCode,
        [string]$pattern
    )

    switch -Regex ($pattern) {
        'rand\s*\(' {
            if ($insecureCode -match 'rand\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)') {
                $min = $Matches[1]
                $max = $Matches[2]
                return "random_int($min, $max)"
            }
            else {
                return "random_int(0, PHP_INT_MAX)"
            }
        }
        'mt_rand\s*\(' {
            if ($insecureCode -match 'mt_rand\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)') {
                $min = $Matches[1]
                $max = $Matches[2]
                return "random_int($min, $max)"
            }
            else {
                return "random_int(0, PHP_INT_MAX)"
            }
        }
        'array_rand\s*\(' {
            if ($insecureCode -match 'array_rand\s*\(\s*(\$\w+)\s*,\s*(\d+|\$\w+)\s*\)') {
                $array = $Matches[1]
                $num = $Matches[2]
                return "array_rand($array, $num, true) // Use the secure random flag"
            }
            else {
                return "// Replace with a secure implementation using random_int()"
            }
        }
        'shuffle\s*\(' {
            if ($insecureCode -match 'shuffle\s*\(\s*(\$\w+)\s*\)') {
                $array = $Matches[1]
                return @"
// Secure shuffle implementation
function secureArrayShuffle(&`$array) {
    `$count = count(`$array);
    for (`$i = `$count - 1; `$i > 0; `$i--) {
        `$j = random_int(0, `$i);
        `$temp = `$array[`$i];
        `$array[`$i] = `$array[`$j];
        `$array[`$j] = `$temp;
    }
    return `$array;
}
secureArrayShuffle($array);
"@
            }
            else {
                return "// Replace with a secure shuffle implementation using random_int()"
            }
        }
        'str_shuffle\s*\(' {
            if ($insecureCode -match 'str_shuffle\s*\(\s*(.*?)\s*\)') {
                $string = $Matches[1]
                return @"
// Secure string shuffle implementation
function secureStrShuffle(`$string) {
    `$chars = str_split(`$string);
    `$count = count(`$chars);
    for (`$i = `$count - 1; `$i > 0; `$i--) {
        `$j = random_int(0, `$i);
        `$temp = `$chars[`$i];
        `$chars[`$i] = `$chars[`$j];
        `$chars[`$j] = `$temp;
    }
    return implode('', `$chars);
}
secureStrShuffle($string);
"@
            }
            else {
                return "// Replace with a secure string shuffle implementation using random_int()"
            }
        }
        'uniqid\s*\(' {
            return "bin2hex(random_bytes(16)) // Cryptographically secure random ID"
        }
        default {
            return "// Replace with a secure alternative"
        }
    }
}

# Recursively find all PHP files in the Repos directory
$phpFiles = Get-ChildItem -Path "Repos" -Filter "*.php" -Recurse -File

$totalFiles = $phpFiles.Count
$scannedFiles = 0
$insecureFiles = 0
$insecureInstances = 0

# Create a report file
$reportFile = "insecure-random-report.md"
$reportContent = @"
# Insecure Random Number Generation Report

This report identifies instances of insecure random number generation in PHP code and provides secure alternatives.

## Summary

- Total PHP files scanned: 0
- Files with insecure random functions: 0
- Total instances of insecure random functions: 0

## Detailed Findings

"@

# Scan each PHP file
foreach ($file in $phpFiles) {
    $scannedFiles++
    Write-Progress -Activity "Scanning PHP files" -Status "Scanning $($file.FullName)" -PercentComplete (($scannedFiles / $totalFiles) * 100)

    $results = Find-InsecureRandom -filePath $file.FullName

    if ($results.Count -gt 0) {
        $insecureFiles++
        $insecureInstances += $results.Count

        $reportContent += @"

### File: $($file.FullName)

"@

        foreach ($result in $results) {
            $secureCode = Get-SecureReplacement -insecureCode $result.Line -pattern $result.Pattern

            $reportContent += @"
- **Line $($result.LineNumber)**: `$($result.Line)`
  - **Issue**: Using insecure random function
  - **Recommendation**: Replace with `$($result.Alternative)`
  - **Suggested code**:
```php
$secureCode
```

"@
        }
    }
}

# Update the summary in the report
$reportContent = $reportContent -replace "Total PHP files scanned: 0", "Total PHP files scanned: $scannedFiles"
$reportContent = $reportContent -replace "Files with insecure random functions: 0", "Files with insecure random functions: $insecureFiles"
$reportContent = $reportContent -replace "Total instances of insecure random functions: 0", "Total instances of insecure random functions: $insecureInstances"

# Add recommendations section
$reportContent += @"
## Security Recommendations

### Secure Alternatives for PHP Random Functions

1. **For generating random integers**:
   ```php
   // Instead of rand() or mt_rand()
   $secureRandomInt = random_int($min, $max);
   ```

2. **For generating random bytes**:
   ```php
   // Instead of uniqid()
   $randomBytes = random_bytes($length);
   $hexString = bin2hex($randomBytes);
   ```

3. **For shuffling arrays**:
   ```php
   // Instead of shuffle()
   function secureArrayShuffle(&$array) {
       $count = count($array);
       for ($i = $count - 1; $i > 0; $i--) {
           $j = random_int(0, $i);
           $temp = $array[$i];
           $array[$i] = $array[$j];
           $array[$j] = $temp;
       }
       return $array;
   }
   ```

4. **For shuffling strings**:
   ```php
   // Instead of str_shuffle()
   function secureStrShuffle($string) {
       $chars = str_split($string);
       $count = count($chars);
       for ($i = $count - 1; $i > 0; $i--) {
           $j = random_int(0, $i);
           $temp = $chars[$i];
           $chars[$i] = $chars[$j];
           $chars[$j] = $temp;
       }
       return implode('', $chars);
   }
   ```

### Implementation Notes

- `random_int()` and `random_bytes()` are available in PHP 7.0 and later
- For PHP 5.x, consider using the paragonie/random_compat polyfill library
- Always use cryptographically secure random functions for:
  - Security tokens
  - Password reset codes
  - Session identifiers
  - Encryption keys
  - Any security-sensitive random values

### Additional Resources

- [PHP random_int() documentation](https://www.php.net/manual/en/function.random-int.php)
- [PHP random_bytes() documentation](https://www.php.net/manual/en/function.random-bytes.php)
- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
"@

# Save the report
Set-Content -Path $reportFile -Value $reportContent

Write-Host "`nScan completed!" -ForegroundColor Green
Write-Host "Total PHP files scanned: $scannedFiles" -ForegroundColor Cyan
Write-Host "Files with insecure random functions: $insecureFiles" -ForegroundColor Cyan
Write-Host "Total instances of insecure random functions: $insecureInstances" -ForegroundColor Cyan
Write-Host "Report saved to: $reportFile" -ForegroundColor Green

if ($insecureInstances -gt 0) {
    Write-Host "`nRecommendation:" -ForegroundColor Yellow
    Write-Host "Review the report and update the code to use secure random functions." -ForegroundColor Yellow
    Write-Host "For PHP 7.0+, use random_int() and random_bytes() for cryptographically secure randomness." -ForegroundColor Yellow
} else {
    Write-Host "`nNo insecure random functions found. Good job!" -ForegroundColor Green
}
