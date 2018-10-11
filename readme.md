# PhpStorm URL Handler

## Installation

    cp phpstorm-url-handler /usr/bin/phpstorm-url-handler
    desktop-file-install phpstorm-url-handler.desktop
    update-desktop-database

## Symfony project setup
```
# app/config/config.yml
framework:
    ide: 'phpstorm://open?url=file://%%f&line=%%l&/usr/vhosts/unisender.com/>repo/unisender/'
```
