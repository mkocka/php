PHP Source to image builder
============================

This repository contains the source for building various versions of
the PHP application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
This image is port to **fedora** of Software collections [php7.0 s2i](https://github.com/sclorg/s2i-php-container/tree/master/7.0).
The resulting image can be run using [Docker](http://docker.io).

Build
------------------------

Most simple way to build image is using **Makefile**.
```
$ make build
```

This build php image and tag it with name and version specified in **Makefile**:
```
IMAGE_NAME=php
VERSION=7
```

Usage
------------------------

Build your PHP application
```
s2i build <SOURCE-REPOSITORY> php <NAME-OF-APP>
```
Substitute <SOURCE-REPOSITORY> with path to your application or link to GitHub repository.
For example:
```
s2i build https://github.com/fermayo/hello-world-php php hello-world
```

Then run application in docker container:
```
docker run -p 8080:8080 <NAME-OF-APP>
```

So for our example it would be:
```
docker run -p 8080:8080 hello-world
```

**Accessing the application:**
```
curl 127.0.0.1:8080
```
Repository organization
------------------------
* **php**

    * **Dockerfile**

        Fedora based Dockerfile.

    * **Makefile**

        Used to build and run docker image.

    * **openshift-template.yaml**

        Template to build and run PHP applications easily in OpenShift.

    * **`.s2i/bin/`**

        This folder contains scripts that are run by [S2I](https://github.com/openshift/source-to-image):

        *   **assemble**

            Used to install the sources into the location where the application
            will be run and prepare the application for deployment (eg. installing
            modules using npm, etc..)

        *   **run**

            This script is responsible for running the application, by using the
            application web server.
        *   **usage**

            This script is called when someone try to run image using docker.  

    * **`bin/`**

        Helper scripts for fixing permissions and reading limits from cgroup system.

    * **`contrib/`**

        This folder contains a file with commonly used modules.

    * **`root/`**

        Manual pages.

    * **`test/`**

        This folder contains the [S2I](https://github.com/openshift/source-to-image)
        test framework with a sample PHP app.

        * **`test-app/`**

            A simple PHP app used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

        * **run**

            Script that runs the [S2I](https://github.com/openshift/source-to-image) test framework.


Environment variables
---------------------

To set these environment variables, you can place them as a key value pair into a `.sti/environment`
file inside your source code repository.

The following environment variables set their equivalent property value in the php.ini file:
* **ERROR_REPORTING**
  * Informs PHP of which errors, warnings and notices you would like it to take action for
  * Default: E_ALL & ~E_NOTICE
* **DISPLAY_ERRORS**
  * Controls whether or not and where PHP will output errors, notices and warnings
  * Default: ON
* **DISPLAY_STARTUP_ERRORS**
  * Cause display errors which occur during PHP's startup sequence to be handled separately from display errors
  * Default: OFF
* **TRACK_ERRORS**
  * Store the last error/warning message in $php_errormsg (boolean)
  * Default: OFF
* **HTML_ERRORS**
  * Link errors to documentation related to the error
  * Default: ON
* **INCLUDE_PATH**
  * Path for PHP source files
  * Default: .:/opt/app-root/src:/usr/share/pear
* **SESSION_PATH**
  * Location for session data files
  * Default: /tmp/sessions
* **SHORT_OPEN_TAG**
  * Determines whether or not PHP will recognize code between <? and ?> tags
  * Default: OFF
* **DOCUMENTROOT**
  * Path that defines the DocumentRoot for your application (ie. /public)
  * Default: /

The following environment variables set their equivalent property value in the opcache.ini file:
* **OPCACHE_MEMORY_CONSUMPTION**
  * The OPcache shared memory storage size in megabytes
  * Default: 128
* **OPCACHE_REVALIDATE_FREQ**
  * How often to check script timestamps for updates, in seconds. 0 will result in OPcache checking for updates on every request.
  * Default: 2

You can also override the entire directory used to load the PHP configuration by setting:
* **PHPRC**
  * Sets the path to the php.ini file
* **PHP_INI_SCAN_DIR**
  * Path to scan for additional ini configuration files

You can override the Apache [MPM prefork](https://httpd.apache.org/docs/2.4/mod/mpm_common.html)
settings to increase the performance for of the PHP application. In case you set
the Cgroup limits in Docker, the image will attempt to automatically set the
optimal values. You can override this at any time by specifying the values
yourself:

* **HTTPD_START_SERVERS**
  * The [StartServers](https://httpd.apache.org/docs/2.4/mod/mpm_common.html#startservers)
    directive sets the number of child server processes created on startup.
  * Default: 8
* **HTTPD_MAX_REQUEST_WORKERS**
  * The [MaxRequestWorkers](https://httpd.apache.org/docs/2.4/mod/mpm_common.html#maxrequestworkers)
    directive sets the limit on the number of simultaneous requests that will be served.
  * `MaxRequestWorkers` was called `MaxClients` before version httpd 2.3.13.
  * Default: 256 (this is automatically tuned by setting Cgroup limits for the container using this formula:
    `TOTAL_MEMORY / 15MB`. The 15MB is average size of a single httpd process.

  You can use a custom composer repository mirror URL to download packages instead of the default 'packagist.org':

    * **COMPOSER_MIRROR**
      * Adds a custom composer repository mirror URL to composer configuration. Note: This only affects packages listed in composer.json.

Source repository layout
------------------------

You do not need to change anything in your existing PHP project's repository.
However, if these files exist they will affect the behavior of the build process:

* **composer.json**

  List of dependencies to be installed with `composer`. The format is documented
  [here](https://getcomposer.org/doc/04-schema.md).


* **.htaccess**

  In case the **DocumentRoot** of the application is nested within the source directory `/opt/app-root/src`,
  users can provide their own Apache **.htaccess** file.  This allows the overriding of Apache's behavior and
  specifies how application requests should be handled. The **.htaccess** file needs to be located at the root
  of the application source.

Hot deploy
---------------------

In order to immediately pick up changes made in your application source code, you need to run your built image with the `OPCACHE_REVALIDATE_FREQ=0` environment variable passed to the [Docker](http://docker.io) `-e` run flag:

```
$ docker run -e OPCACHE_REVALIDATE_FREQ=0 -p 8080:8080 php-app
```

To change your source code in running container, use Docker's [exec](http://docker.io) command:
```
docker exec -it <CONTAINER_ID> /bin/bash
```

After you [Docker exec](http://docker.io) into the running container, your current directory is set
to `/opt/app-root/src`, where the source code is located.

Test
---------------------
Run:
```
$ make test
```
This will build candidate image and check the basic functionality of s2i image.

Running in OpenShift
---------------------
Login
```
$ oc login -u developer
```

Create new project
```
$ oc new-project sample-project
```

Create template from YAML file
```
$ oc create -f openshift-template.yaml
```

Create new application (php-fedora is template created in previous step)
```
$ oc new-app php-fedora -p APP_NAME=<name> -p SOURCE_REPOSITORY=<your-github-repository>
```
For example:
```
$ oc new-app php-fedora -p APP_NAME=my-app -p SOURCE_REPOSITORY=https://github.com/fermayo/hello-world-php
```
Check if everything is ok
```
$ oc logs -f bc/my-app
