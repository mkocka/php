% php(1)
% Rado Pitonak \<rpitonak@redhat.com\>
% DATE 07.04.2017

# NAME
php - source to image builder of php applications.

# DESCRIPTION
Image for building php application as reproducible Docker image using source to image. Image is based on fedora.
## USAGE

To pull the php container run:

      # docker pull modularitycontainers/php

To build your php application run:

      # s2i build <SOURCE-REPOSITORY> modularitycontainers/php <NAME-OF-APP>

To run your application in docker container:

      # docker run -p 8080:8080 <NAME-OF-APP>

## ENVIROMENT VARIABLES

To set environment variables, you can place them as a key value pair into a `.sti/environment`
file inside your source code repository.

The following environment variables set their equivalent property value in the php.ini file:

ERROR_REPORTING
    Informs PHP of which errors, warnings and notices you would like it to take action for.
    Default: E_ALL & ~E_NOTICE

DISPLAY_ERRORS
    Controls whether or not and where PHP will output errors, notices and warnings.
    Default: ON

DISPLAY_STARTUP_ERRORS
    Cause display errors which occur during PHP's startup sequence to be handled separately from display errors.
    Default: OFF

TRACK_ERRORS
    Store the last error/warning message in $php_errormsg (boolean)
    Default: OFF

HTML_ERRORS
    Link errors to documentation related to the error
    Default: ON

INCLUDE_PATH
    Path for PHP source files
    Default: .:/opt/app-root/src:/usr/share/pear

SESSION_PATH
    Location for session data files
    Default: /tmp/sessions

SHORT_OPEN_TAG
    Determines whether or not PHP will recognize code between <? and ?> tags
    Default: OFF

DOCUMENTROOT
    Path that defines the DocumentRoot for your application (ie. /public)
    Default: /

The following environment variables set their equivalent property value in the opcache.ini file:

OPCACHE_MEMORY_CONSUMPTION
    The OPcache shared memory storage size in megabytes
    Default: 128

OPCACHE_REVALIDATE_FREQ
    How often to check script timestamps for updates, in seconds. 0 will result in OPcache checking for updates on every request.
    Default: 2

You can also override the entire directory used to load the PHP configuration by setting:   

PHPRC
    Sets the path to the php.ini file

PHP_INI_SCAN_DIR
    Path to scan for additional ini configuration files

You can override the Apache MPM prefork settings to increase the performance for of the PHP application. In case you set
the Cgroup limits in Docker, the image will attempt to automatically set the
optimal values. You can override this at any time by specifying the values
yourself:

HTTPD_START_SERVERS
  The StartServers directive sets the number of child server processes created on startup.
  Default: 8

HTTPD_MAX_REQUEST_WORKERS
  The MaxRequestWorkers directive sets the limit on the number of simultaneous requests that will be served.
  `MaxRequestWorkers` was called `MaxClients` before version httpd 2.3.13.
  Default: 256 (this is automatically tuned by setting Cgroup limits for the container using this formula:
    `TOTAL_MEMORY / 15MB`. The 15MB is average size of a single httpd process.

You can use a custom composer repository mirror URL to download packages instead of the default 'packagist.org':

COMPOSER_MIRROR
      Adds a custom composer repository mirror URL to composer configuration. Note: This only affects packages listed in composer.json.

## HOT DEPLOY

In order to immediately pick up changes made in your application source code, you need to run your built image with the `OPCACHE_REVALIDATE_FREQ=0` environment variable passed to the Docker `-e` run flag:

        # docker run -e OPCACHE_REVALIDATE_FREQ=0 -p 8080:8080 php-app

To change your source code in running container, use Docker's exec command:   

        # docker exec -it <CONTAINER_ID> /bin/bash

After you Docker exec into the running container, your current directory is set to `/opt/app-root/src`, where the source code is located.

## SECURITY IMPLICATIONS

-p 8080:8080

     Opens  container  port  8080  and  maps it to the same port on the Host.       
