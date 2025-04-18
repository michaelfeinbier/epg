# EPG [![update](https://github.com/iptv-org/epg/actions/workflows/update.yml/badge.svg)](https://github.com/iptv-org/epg/actions/workflows/update.yml)

Tools for downloading the EPG (Electronic Program Guide) for thousands of TV channels from hundreds of sources.

## Table of contents

- ✨ [Installation](#installation)
- 🚀 [Usage](#usage)
- 💫 [Update](#update)
- 📺 [Playlists](#playlists)
- 🗄 [Database](#database)
- 👨‍💻 [API](#api)
- 🐋 [Docker](#docker)
- 📚 [Resources](#resources)
- 💬 [Discussions](#discussions)
- 🛠 [Contribution](#contribution)
- 📄 [License](#license)

## Installation

First, you need to install [Node.js](https://nodejs.org/en) on your computer. You will also need to install [Git](https://git-scm.com/downloads) to follow these instructions.

After that open the [Console](https://en.wikipedia.org/wiki/Windows_Console) (or [Terminal](<https://en.wikipedia.org/wiki/Terminal_(macOS)>) if you have macOS) and type the following command:

```sh
git clone --depth 1 -b master https://github.com/iptv-org/epg.git
```

Then navigate to the downloaded `epg` folder:

```sh
cd epg
```

And install all the dependencies:

```sh
npm install
```

## Usage

To start the download of the guide, select one of the supported sites from [SITES.md](SITES.md) file and paste its name into the command below:

```sh
npm run grab --- --site=example.com
```

Then run it and wait for the guide to finish downloading. When finished, a new `guide.xml` file will appear in the current directory.

You can also customize the behavior of the script using this options:

```sh
Usage: npm run grab --- [options]

Options:
  -s, --site <name>             Name of the site to parse (env: SITE)
  -c, --channels <path>         Path to *.channels.xml file (required if the "--site" attribute is
                                not specified) (env: CHANNELS)
  -o, --output <path>           Path to output file (default: "guide.xml", env: OUTPUT)
  -l, --lang <code>             Filter channels by language (ISO 639-2 code) (env: LANG)
  -t, --timeout <milliseconds>  Override the default timeout for each request (env: TIMEOUT)
  -d, --delay <milliseconds>    Override the default delay between request (env: DELAY)
  --days <days>                 Override the number of days for which the program will be loaded
                                (defaults to the value from the site config) (env: DAYS)
  --maxConnections <number>     Limit on the number of concurrent requests (default: 5, env:
                                MAX_CONNECTIONS)
  --cron <expression>           Schedule a script run (example: "0 0 * * *") (env: CRON)
  --gzip                        Create a compressed version of the guide as well (default: false,
                                env: GZIP)
  -h, --help                    display help for command
```

### Access the guide by URL

You can make the guide available via URL by running your own server:

```sh
npm run serve
```

After that, the guide will be available at the link:

```
http://localhost:3000/guide.xml
```

In addition it will be available to other devices on the same local network at the address:

```
```

### Parallel downloading

By default, the guide for each channel is downloaded one by one, but you can change this behavior by increasing the number of simultaneous requests using the `--maxConnections` attribute:

```sh
npm run grab --- --site=example.com --maxConnections=10
```

But be aware that under heavy load, some sites may start return an error or completely block your access.

### Use custom channel list

Create an XML file and copy the descriptions of all the channels you need from the [/sites](sites) into it:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<channels>
  <channel site="arirang.com" lang="en" xmltv_id="ArirangTV.kr" site_id="CH_K">Arirang TV</channel>
  ...
</channels>
```

And then specify the path to that file via the `--channels` attribute:

```sh
npm run grab --- --channels=path/to/custom.channels.xml
```

### Run on schedule

To download the guide on a schedule, you can use the included process manager. Just run it with desire [cron expression](https://crontab.guru/) and the `grab` options:

```sh
npx pm2 start npm --no-autorestart --cron-restart="0 0,12 * * *" -- run grab --- --site=example.com
```

To track the process, you can use the command:

```sh
npx pm2 logs
```

For more info go to [pm2](https://pm2.keymetrics.io/docs/usage/quick-start/) documentation.

### Access the guide by URL

You can make the guide available via URL by running your own server. The easiest way to do this is to run this command:

```sh
npx serve
```

After that, the guide will be available at the link:

```
http://localhost:3000/guide.xml
```

In addition it will be available to other devices on the same local network at the address:

```
http://<your_local_ip_address>:3000/guide.xml
```

For more info go to [serve](https://github.com/vercel/serve) documentation.

## Update

If you have downloaded the repository code according to the instructions above, then to update it will be enough to run the command:

```sh
git pull
```

And then update all the dependencies:

```sh
npm install
```

## Database

All channel data is taken from the [iptv-org/database](https://github.com/iptv-org/database) repository. If you find any errors please open a new [issue](https://github.com/iptv-org/database/issues) there.

## API

The API documentation can be found in the [iptv-org/api](https://github.com/iptv-org/api) repository.

## Docker

This repository provides a `Dockerfile` that you can use to build a Docker image. To do this, you need to have [Docker](https://docs.docker.com/get-docker/) installed on your computer.

Build your image using the following command:

```sh
docker build -t epg .
```
You can then run the image. The container supports currently two modes:

- If you supply an `CRON` environment variable, the container will start in cron-mode. The container will grab an initial set of EPG data according to your configuration, start a webserver on port 3000 and then run the cron job according to your `CRON` configuration.

  Example:
  ```sh
  docker run -d -e CRON="0 0 * * *" -e SITE=example.com -p 3000:3000 --name epg epg
  ```

  This will grab the EPG data from `example.com` every day at midnight, store the file inside the container at `/build/public/guide.xml` and `/build/public/guide.xml.gz`, and start a webserver on port 3000 to serve the files via http.

- If you don't supply a `CRON` environment variable, the container will start in an one-off mode. The container will grab an initial set of EPG data according to your configuration and then exit.

  Example:
  ```sh
  docker run --rm -e SITE=example.com -v "${PWD}:/build/public" epg
  ```

  This will grab the EPG data from `example.com` and store the file in your current working directory.

### Configuration

You can configure the `grab` command by setting environment variables. All available options are listed in the [Usage](#usage) section with the corresponding environment variable names. Docker uses the same defaults of the options like the script with the execption of the `OUTPUT` and the `GZIP` option. The most important environment values are:

| Environment variable | Default value | `npm run` option  |
| -------------------- | ------------- | ----------------- |
| `OUTPUT`             | `/build/public/guide.xml`   | `--output`        |
| `GZIP`               | `true`        | `--gzip`          |
| `SITE`               |               | `--site`          |
| `CRON`               |               | `--cron`          |


## Resources

Links to other useful IPTV-related resources can be found in the [iptv-org/awesome-iptv](https://github.com/iptv-org/awesome-iptv) repository.

## Discussions

If you have a question or an idea, you can post it in the [Discussions](https://github.com/orgs/iptv-org/discussions) tab.

## Contribution

Please make sure to read the [Contributing Guide](https://github.com/iptv-org/epg/blob/master/CONTRIBUTING.md) before sending [issue](https://github.com/iptv-org/epg/issues) or a [pull request](https://github.com/iptv-org/epg/pulls).

And thank you to everyone who has already contributed!

### Backers

<a href="https://opencollective.com/iptv-org"><img src="https://opencollective.com/iptv-org/backers.svg?width=890" /></a>

### Contributors

<a href="https://github.com/iptv-org/epg/graphs/contributors"><img src="https://opencollective.com/iptv-org/contributors.svg?width=890" /></a>

## License

[![CC0](http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/cc-zero.svg)](LICENSE)
