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
1. Node

# Installation

1. `git clone git@github.com:mortenson/drupal-docker-lite.git`
1. `cd drupal-docker-lite`
1. `./start.sh`

That's it!

Feel free to run `./start.sh` whenever you can't remember the address for your
site, or if your Docker containers are down.

# Other commands

- `./rebuild.sh` will force the Docker images to re-build, and re-start your
containers.
- `./stop.sh` will stop any running containers without removing them.

# Drush support

If you run Drush while in the drupal-docker-lite directory or any sub-directory,
commands will be ran within Docker auto-magically.

# Alternatives

There are loads of good Drupal Docker projects out there. Here are some I'm
aware of:

1. [Drupal VM](https://github.com/geerlingguy/drupal-vm)
1. [Docksal](https://github.com/docksal/docksal)
1. [docker4drupal](https://github.com/wodby/docker4drupal)
