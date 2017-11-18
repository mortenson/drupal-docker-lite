# drupal-docker-lite
A simple Docker setup for lazy developers like me.

This project exists because local development in Drupal 8 is just too darn
complicated. I wanted a tool that had minimal dependencies and a single command
that set up everything for me, so I wrote one!

If you want a more complicated setup, see [Alternatives](#alternatives).

# System requirements

1. Docker 17.05 or later. This project has admittedly only been tested with
Docker for Mac.
1. Composer

# Codebase requirements

This setup only supports Drupal 8 sites that have Drush locally required. If
your codebase meets these requirements but still isn't working, please file
an issue!

# Installation

1. `git clone git@github.com:mortenson/drupal-docker-lite.git your-project`
1. `cd your-project`
1. `./ddl.sh start`

That's it!

Feel free to run `./ddl.sh start` whenever you can't remember the address for your
site, or if your Docker containers are down.

# ddl.sh commands

Common operations have been abstracted into commands that can be run with
`ddl.sh`. Omitting the instance name for any command will use the local
drupal-docker-lite instance.

- `create [DIR]` - Creates a new instance in a given directory.
- `customize` - Customizes instance to use local images for PHP and MySQL.
- `drupal [NAME] [COMMAND]` - Run Drupal Console for a given instance.
- `drush [NAME] [COMMAND]` - Run drush for a given instance.
- `exec [NAME] [COMMAND]` - Executes a single command for a given instance.
- `export [NAME] [DESTINATION]` - Exports a database dump to a given directory.
- `import [NAME] [SOURCE]` - Imports a given database dump.
- `inspect [NAME]` - List all containers for a given instance.
- `list` - List all running drupal-docker-lite instances.
- `logs [NAME] [OPTIONS]` - Print logs for a given instance. Run "docker help logs" for options.
- `mail [NAME]` - Open the Mailhog interface for a given instance.
- `proxy` - Restarts the reverse proxy.
- `prune` - Remove unused Docker volumes and images.
- `rebuild [NAME]` - Rebuilds a given instance.
- `remove [NAME]` - Stop and remove a given instance, permanently.
- `start [NAME]` - Start a given instance.
- `stop [NAME]` - Stop a given instance.
- `update` - Makes sure that drupal-docker-lite is up to date for all instances.
- `url [NAME]` - Print the URL for a given instance.

## Making ddl.sh globally available

If you have a lot of local instances, you may want to run ddl from any
directory. To do this, symlink `ddl.sh` to your local bin folder.

For example:

```
git clone git@github.com:mortenson/drupal-docker-lite.git ~/drupal-docker-lite
ln -s ~/drupal-docker-lite/ddl.sh /usr/local/bin/ddl
```

Now a `ddl` command should be available to you. Run `ddl help` to get started.

# Multiple instances

Since this project just uses stock docker-compose, you should be able to clone
it into multiple directories and spin up/down instances without any issues.

# Running PHPUnit tests

PHP unit tests can be run using the `ddl exec` command, ex:

```
ddl exec ./docroot/vendor/bin/phpunit -c ./docroot/core ./docroot/core/tests/Drupal/KernelTests/Core/Form/FormCacheTest.php
```

If you need to run a Javascript test, you can run PhantomJS in one session:

```
ddl exec phantomjs --ssl-protocol=any --ignore-ssl-errors=true ./docroot/vendor/jcalderonzumba/gastonjs/src/Client/main.js 8510 1024 768
```

then in another session run the Javascript test.

# How does it all work?

Please see [DETAILS](docs/DETAILS.md) for information about this project's
implementation.

# Alternatives

There are loads of good Drupal Docker projects out there. Here are some I'm
aware of:

1. [Drupal VM](https://github.com/geerlingguy/drupal-vm)
1. [Docksal](https://github.com/docksal/docksal)
1. [docker4drupal](https://github.com/wodby/docker4drupal)
