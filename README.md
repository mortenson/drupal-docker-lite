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

# Installation

1. `git clone git@github.com:mortenson/drupal-docker-lite.git your-project`
1. `cd your-project`
1. `./start.sh`

That's it!

Feel free to run `./start.sh` whenever you can't remember the address for your
site, or if your Docker containers are down.

# Codebase requirements

This setup only supports Drupal 8 sites that have Drush locally required. If
your codebase meets these requirements but still isn't working, please file
an issue!

# Other commands

- `./rebuild.sh` will force the Docker images to re-build, and re-start your
containers.
- `./stop.sh` will stop any running containers without removing them.
- `./mail.sh` will open the Mailhog user interface.
- `./proxy.sh` will (re)start a reverse proxy which maps port 80 on the host to
 your drupal-docker-lite instances. This runs automatically with ./start.sh.
- `./url.sh` will print the current URL. Useful for automation, as the domain
 is configurable and port 80 may not be exposed if the proxy is broken.
- `./logs.sh` will print logs from the PHP container. Pass `--tail [NUMBER]` to
limit the log output, and `--follow` to watch new log entries.

# Meta commands

As you may be running multiple instances of drupal-docker-lite, commands are
provided which perform operations on arbitrary instances.

- `./meta/list.sh` will list all running drupal-docker-lite instances.
- `./meta/inspect.sh [NAME]` will list all containers for a given instance.
- `./meta/drush.sh [NAME] [COMMAND]` will run drush for a given instance. To
run commands for the current container, use "self" for the instance name.
- `./meta/stop.sh [NAME]` will stop a given instance's containers.
- `./meta/start.sh [NAME]` will start a given instance's containers.
- `./meta/remove.sh [NAME]` will stop and remove a given instance's containers.
- `./meta/prune.sh` will remove unused Docker volumes and images.
- `./meta/url.sh [NAME]` will print the URL for a given instance.
- `./meta/logs.sh [NAME]` will print logs for a given instance. Pass
`--tail [NUMBER]` to limit the log output, `--follow` to watch new log
entries, and `--since [DATESTRING]` to logs since a date (e.g.
2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes).

## Making meta commands globally available

If you have a lot of local instances, you may want to run meta commands from
any directory. To do this, symlink `meta/ddl.sh` to your local bin folder.

For example:

```
git clone git@github.com:mortenson/drupal-docker-lite.git ~/drupal-docker-lite
ln -s ~/drupal-docker-lite/meta/ddl.sh /usr/local/bin/ddl
```

Now a `ddl` command should be available to you. Run `ddl help` to get started.

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
