-- Initialize Nextcloud database with optimized settings

-- Set character set and collation
ALTER DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Optimize MariaDB for Nextcloud
SET GLOBAL innodb_file_format=Barracuda;
SET GLOBAL innodb_large_prefix=ON;
SET GLOBAL innodb_default_row_format='dynamic';

-- Create additional test database for development
CREATE DATABASE IF NOT EXISTS nextcloud_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON nextcloud_test.* TO 'nextcloud'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;