# Nextcloud Apps Directory

This directory contains your Nextcloud apps. It is mounted as `custom_apps` in the Nextcloud container.

## Current Apps

### Appointments-master

A Nextcloud app for scheduling appointments. This app allows users to create and manage appointment slots that others can book.

**Note**: Due to directory naming conventions in Nextcloud, this app is symlinked from `Appointments-master` to `appointments` to ensure proper loading. If you encounter issues with the app not appearing, run the `fix-app-symlink.sh` script.

### calendar-main

The Nextcloud Calendar app, which provides a user interface for CalDAV calendars. This app is a dependency for the Appointments app.

## Adding New Apps

To add a new app:

1. Create a new directory in this folder with your app's ID (e.g., `myapp`)
2. Initialize your app structure
3. Ensure the directory name matches the app ID in `appinfo/info.xml`
4. Restart the Nextcloud container or run `occ app:enable myapp` to enable it

## App Structure

A typical Nextcloud app has the following structure:

```
myapp/
├── appinfo/
│   ├── info.xml            # App metadata
│   └── routes.php          # Route definitions
├── lib/                    # PHP classes
├── templates/              # Templates
├── js/                     # JavaScript files
├── css/                    # CSS files
└── README.md               # Documentation
```

## Development Tips

1. **App ID**: The app ID (defined in `info.xml`) must match the directory name
2. **Permissions**: Ensure files are owned by the www-data user inside the container
3. **Debugging**: Use Xdebug with VS Code for PHP debugging
4. **Frontend**: Use the browser developer tools for JavaScript debugging
5. **Logs**: Check Nextcloud logs with `docker-compose logs nextcloud`

## Resources

- [Nextcloud App Development Documentation](https://docs.nextcloud.com/server/latest/developer_manual/app_development/index.html)
- [Nextcloud App Store](https://apps.nextcloud.com/)
- [Nextcloud App API Documentation](https://docs.nextcloud.com/server/latest/developer_manual/app_development/api/index.html)
