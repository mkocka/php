FROM modularitycontainers/boltron-preview:latest

# Description
# This image provides an Apache 2.4 + PHP 7.0 environment for running PHP applications.
# Exposed ports:
# * 8080 - alternative port for http

LABEL MAINTAINER Rado Pitonak <rpitonak@redhat.com>

RUN dnf --rpm --nodocs -y install tar unzip findutils gettext python php-opcache && \
    dnf --nodocs -y install php && \
    dnf -y clean all

ENV PHP_VERSION=7.0 \
    NAME=php \
    VERSION=0 \
    RELEASE=1 \
    ARCH=x86_64

ENV HOME=/opt/app-root

LABEL summary="php runtime" \
      name="$FGC/$NAME" \
      version="$VERSION" \
      release="$RELEASE.$DISTTAG" \
      architecture="$ARCH" \
      description="Platform for building and running PHP 7.0 applications." \
      vendor="Fedora Project" \
      com.redhat.component="$NAME" \
      usage="s2i build <SOURCE-REPOSITORY> php <APP-NAME>" \
      org.fedoraproject.component="php" \
      authoritative-source-url="registry.fedoraproject.org" \
      io.k8s.description="Platform for building and running PHP 7.0 applications." \
      io.k8s.display-name="Apache 2.4 with PHP 7.0" \
      io.openshift.tags="builder,php,php70" \
      io.openshift.expose-services="8080:https" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"

# S2I scripts
COPY ./.s2i/bin/ /usr/local/s2i

# Copy executable utilities.
COPY bin/ /usr/bin/

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# Add help file
COPY root /

EXPOSE 8080

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN mkdir -p ${HOME}/src && \
    sed -i -f /opt/app-root/etc/httpdconf.sed /etc/httpd/conf/httpd.conf && \
    head -n151 /etc/httpd/conf/httpd.conf | tail -n1 | grep "AllowOverride All" || exit && \
    echo "IncludeOptional /opt/app-root/etc/conf.d/*.conf" >> /etc/httpd/conf/httpd.conf && \
    mkdir /tmp/sessions && \
    useradd -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
    chown -R 1001:0 /opt/app-root /tmp/sessions && \
    chmod -R a+rwx /tmp/sessions && \
    chmod -R ug+rwx /opt/app-root && \
    chmod -R a+rwx /etc/php.d && \
    chmod -R a+rwx /etc/php.ini && \
    chmod -R a+rwx /run/httpd

USER 1001

WORKDIR ${HOME}/src

# Command which will start service during command `docker run`
CMD /usr/local/s2i/usage
