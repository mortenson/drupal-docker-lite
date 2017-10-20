# drupal-docker-lite
A simple Docker setup for lazy developers like me.

This project exists because local development in Drupal 8 is just too darn
complicated. I wanted a tool that had minimal dependencies and a single command
that set up everything for me, so I wrote one!

If you want a more complicated setup, see [Alternatives](#alternatives).

# Requirements

1. Docker 17.05 or later. This project has admittedly only been tested with
Docker for Mac.
1. Composer
1. Drush

# Installation

1. `git clone git@github.com:mortenson/drupal-docker-lite.git your-project`
1. `cd your-project`
1. `./start.sh`

That's it!

Feel free to run `./start.sh` whenever you can't remember the address for your
site, or if your Docker containers are down.

# Other commands

- `./rebuild.sh` will force the Docker images to re-build, and re-start your
containers.
- `./stop.sh` will stop any running containers without removing them.
- `./mail.sh` will open the Mailhog user interface.
- `./proxy.sh` will (re)start a reverse proxy which maps port 80 on the host to
 your drupal-docker-lite instances. This runs automatically with ./start.sh.
- `./url.sh` will print the current URL. Useful for automation, as the domain
 is configurable and port 80 may not be exposed if the proxy is broken.

# Meta commands

As you may be running multiple instances of drupal-docker-lite, commands are
provided which perform operations on arbitrary instances.

- `./meta/list.sh` will list all running drupal-docker-lite instances.
- `./meta/inspect.sh [NAME]` will list all containers for a given instance.
- `./meta/stop.sh [NAME]` will stop a given instance's containers.
- `./meta/start.sh [NAME]` will start a given instance's containers.
- `./meta/remove.sh [NAME]` will stop and remove a given instance's
containers.

# Drush support

If you run Drush while in the drupal-docker-lite directory or any sub-directory,
commands will be ran within Docker auto-magically.

For Drush Launcher users, you have to run `./drush` to run Drush commands in
the container. Sorry! 😩

Also note that the PHP container for this project uses Drush Launcher, so your
project will need to include Drush locally. This is common for all recent
[Drupal Project](https://github.com/drupal-composer/drupal-project) based
projects.

# Multiple instances

Since this project just uses stock docker-compose, you should be able to clone
it into multiple directories and spin up/down instances without any issues.

# Alternatives

There are loads of good Drupal Docker projects out there. Here are some I'm
aware of:

1. [Drupal VM](https://github.com/geerlingguy/drupal-vm)
1. [Docksal](https://github.com/docksal/docksal)
1. [docker4drupal](https://github.com/wodby/docker4drupal)
