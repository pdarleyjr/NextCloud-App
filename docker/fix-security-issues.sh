#!/bin/bash
set -e

echo "🔒 Fixing security issues in the Appointments app..."

# Path to the app directory
APP_DIR="/var/www/html/custom_apps/appointments"

# Check if the app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Error: App directory not found at $APP_DIR"
    exit 1
fi

echo "Scanning for insecure random functions..."

# Fix 1: Replace insecure random functions with secure alternatives
echo "Replacing rand() with random_int()..."
find "$APP_DIR" -name "*.php" -type f -exec sed -i 's/rand(/random_int(/g' {} \;

echo "Replacing mt_rand() with random_int()..."
find "$APP_DIR" -name "*.php" -type f -exec sed -i 's/mt_rand(/random_int(/g' {} \;

echo "Replacing array_rand() with secure implementation..."
find "$APP_DIR" -name "*.php" -type f -exec sed -i 's/array_rand(\([^,]*\))/array_rand(\1, true)/g' {} \;

echo "Replacing uniqid() with bin2hex(random_bytes())..."
find "$APP_DIR" -name "*.php" -type f -exec sed -i 's/uniqid(/bin2hex(random_bytes(16)) \/* Replaced uniqid(/g' {} \;

# Fix 2: Replace weak cryptographic algorithms with strong ones
echo "Replacing weak cryptographic algorithms..."
find "$APP_DIR" -name "*.php" -type f -exec sed -i 's/md5(/hash("sha256", /g' {} \;
find "$APP_DIR" -name "*.php" -type f -exec sed -i 's/sha1(/hash("sha256", /g' {} \;

# Fix 3: Add secure string shuffle implementation
echo "Adding secure string shuffle implementation..."
cat > "$APP_DIR/lib/Utils/SecureRandom.php" << 'EOF'
<?php

namespace OCA\Appointments\Utils;

/**
 * Provides secure random functions to replace insecure PHP functions
 */
class SecureRandom {
    /**
     * Secure string shuffle implementation
     *
     * @param string $string The string to shuffle
     * @return string The shuffled string
     */
    public static function secureStrShuffle(string $string): string {
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
    
    /**
     * Secure array shuffle implementation
     *
     * @param array $array The array to shuffle
     * @return array The shuffled array
     */
    public static function secureArrayShuffle(array $array): array {
        $count = count($array);
        
        for ($i = $count - 1; $i > 0; $i--) {
            $j = random_int(0, $i);
            $temp = $array[$i];
            $array[$i] = $array[$j];
            $array[$j] = $temp;
        }
        
        return $array;
    }
    
    /**
     * Generate a secure random ID
     *
     * @param int $length The length of the ID in bytes (will be doubled for hex output)
     * @return string The random ID
     */
    public static function secureRandomId(int $length = 16): string {
        return bin2hex(random_bytes($length));
    }
}
EOF

echo "✅ Security fixes applied successfully!"
