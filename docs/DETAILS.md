# How drupal-docker-lite works

## The Docker setup

This project uses three main containers per-instance:

### PHP & Apache

This container comes with the extensions and settings required by Drupal
baked-in. Drupal Console Launcher and Drush Launcher are also pre-installed
See [mortenson/ddl-web](https://github.com/mortenson/ddl-web) for the image
used by this container.

The container exposes port 80 on a random host port, which is done to avoid
conflicts with other processes. Remembering a ton of random port numbers is
not a great developer experience, so the container also shares a Docker network
with a reverse proxy which runs on port 80.

A local host directory, `code`, is mounted to `/var/www/html` on the container.
This allows users to develop on the host without doing any manual work to see
changes propagate to the container.

### MySQL

The MySQL container is almost identical to the Docker `mysql:5.6` image, the
only changes made are to reduce idle memory usage which is quite high (~400mb)
by default. See [mortenson/ddl-db](https://github.com/mortenson/ddl-db) for the
image used by this container.

MySQL uses a Docker Volume to ensure that data persists even if the container
is stopped or removed. This is important for local development as container
data is typically not persistent.

This container exposes no ports to the host, but shares an internal network
used by PHP so that connections can be made.

### Mailhog

Another container is used to collect and view mail sent by the PHP container.
The admin interface for Mailhog is exposed to the host on a random port. See
[mailhog/MailHog](https://github.com/mailhog/MailHog) for the image used by
this container.

## The reverse proxy

All instances of drupal-docker-lite share one reverse proxy container, which
uses the [containous/traefik](https://github.com/containous/traefik) image.

The proxy takes host traffic on port 80, and proxies it to the appropriate
drupal-docker-lite instance based on the hostname. An administrative console
for Træfik should be available at localhost:8085 if it's running.

It's required that port 80 and port 8085 is available on the host for the proxy
to run. If this isn't a fit for your local setup, don't worry! Using the proxy
is optional and all the code that displays URLs is equipped to handle cases
where the proxy is not running.

## The ddl.sh script

The ddl.sh script was designed to be readable by anyone familiar with Bash and
Docker Compose, which will hopefully make contribution and customization easy.

When you run `./ddl.sh [COMMAND] [NAME]`, the script tries to determine the
docker-compose.yml directory for a given instance name, then sends arguments
to the relevant script in `./scripts`. This is how you can run
`./ddl.sh drush st` to use the local instance and
`./ddl.sh drush [NAME] st` for an arbitrary instance.
