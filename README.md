# <img src=".repo/assets/icon-512x512.png"  width="52" height="52"> TrivialSec

[![pipeline status](https://gitlab.com/trivialsec/python-webhooks/badges/main/pipeline.svg)](https://gitlab.com/trivialsec/python-webhooks/commits/main)

Current tech stack

- docker
- docker-compose
- sysdig
- seccomp
- gnumake / bash
- python 3.8
- flask
- jinja2 components (server-side rendering)
- node.js v14
- Socket.io
- ejs.co templates
- JavaScript (vanilla prototypal inheritance, i.e. no jQuery or libraries using classical inheritence)
- Redis
- MongoDB
- MySQL v8
- M/Monit

Operations / Business Technology

- Amazon AWS
- Ditial Ocean
- JumpCloud
- Mailgun
- reCAPTCHAv3
- Stripe
- Webflow
- Nextcloud
- Gitlab
- Phonito

Desirable (future state)

- CloudFlare
- Elasticsearch
- React native for ios & android
- go (graph API for apps)

## Prerequisits

1. Ensure you have Docker CE installed

2. register [recaptcha v3](https://www.google.com/recaptcha/admin/create)

## Configure

1. Create a `.env` file with the following;

```
cp .env-example .env
cp workers/docker/config-sample.yaml workers/docker/config.yaml
cp web/docker/config-sample.yaml web/docker/config.yaml
```

Replace defaults with your own values. Make sure you are setup to read these automatically or amnually run `source .env` each time.

For debugging make sure you have `web/docker/.flaskenv` with `FLASK_DEBUG` and `FLASK_ENV` set, and rebuild.

2. Make a config file named `config.yaml` in `./web/src` with the following values;

The recaptcha `secret_key` is sensitive and is not shared in this project as it impacts production, you should create one for yourself. Also the `app session secret` value can be anything random that you like for local development, it is used for session storage so production should be rotated with any significant change to session code.

3. Become familiar with the Makefile to run the project components, make sure you run `db-create` and verify schema using;

```bash
docker-compose exec mysql bash -c "mysql -uroot -p -D${MYSQL_DATABASE} -e 'SHOW TABLES;'"
```

## TODO: CVE database

Simply `docker-compose -f docker-compose-cve.yaml build` then run `./scripts/cve-init.sh` if this is the first time. The first run will take a very long time to populate the database.

If you have already run you can just run the usual `docker-compose -f docker-compose-cve.yaml up -d --no-build`.

To update the database at any time run `./scripts/cve-update.sh`.

You can add a user for the cve-search website using `docker-compose -f docker-compose-cve.yaml exec search bash -c 'python /srv/app/sbin/db_mgmt_admin.py -a admin'`

## Remote and Local IDE support

Ensure you have virtualenv and python 3.7+ installed.

```bash
virtualenv -p $(which python3) .venv
pip install -r docker/web/requirements.txt -r docker/worker/requirements.txt -r dev-requirements.txt
```

For the VSCode debugger, you can use the following `launch.json`;

```json
{
    "version": "0.3.0",
    "configurations": [
        {
            "name": "Python: Flask mode",
            "type": "python",
            "request": "launch",
            "module": "flask",
            "console": "integratedTerminal",
            "cwd": "src",
            "env": {
                "FLASK_APP": "routes.py",
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "0",
                "FLASK_RUN_PORT": "5000",
                "CONFIG_FILE": "config.yaml"
            },
            "args": [
                "run",
                "--no-debugger",
                "--no-reload"
            ],
            "jinja": true
        },
        {
            "name": "Python",
            "type": "python",
            "request": "launch",
            "console": "integratedTerminal",
            "cwd": "src",
            "env": {
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "1",
                "FLASK_RUN_PORT": "5000",
                "CONFIG_FILE": "config.yaml"
            },
            "args": [
                "routes.py"
            ],
            "jinja": true
        },
        {
            "name": "Python prod",
            "type": "python",
            "request": "launch",
            "console": "integratedTerminal",
            "cwd": "src",
            "env": {
                "FLASK_ENV": "production",
                "FLASK_DEBUG": "0",
                "FLASK_RUN_PORT": "5000",
                "CONFIG_FILE": "config.yaml"
            },
            "args": [
                "routes.py"
            ],
            "jinja": true
        }
    ]
}
```

## Tasks

### Connect to RDS mysql

ssh to ec2 then

```
mysql -h trivialsec-main.c3qpuhf7bu2e.ap-southeast-2.rds.amazonaws.com -D trivialsec -u trivialsec -p
```

### Backup mysql MyISAM tables

ssh to ec2 then

```
mysqldump -p trivialsec | gzip > /tmp/sql/db_backup.sql.gz
```

use `aws s3 cp` to store the backup

### Debugging tools inside docker

Inside docker most commands are missing, add them back using `apt update && apt install -y ldnsutils procps nano htop` and whatever other tools you need.

  - ssh-keyscan gitlab.langton.cloud -p 3232 >> ~/.ssh/known_hosts
