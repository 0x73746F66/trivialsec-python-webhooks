# <img src=".repo/assets/icon-512x512.png"  width="52" height="52"> TrivialSec

[![pipeline status](https://gitlab.com/trivialsec/python-webhooks/badges/main/pipeline.svg)](https://gitlab.com/trivialsec/python-webhooks/commits/main)

Current tech stack

- docker
- docker-compose
- sysdig
- seccomp
- gnumake / bash
- python 3.9
- flask
- jinja2 components (server-side rendering)
- node.js v14
- Socket.io
- handlebars templates
- JavaScript (vanilla prototypal inheritance, i.e. no jQuery or libraries using classical inheritence)
- Redis
- Elasticsearch
- MySQL v8

Operations / Business Technology

- Gitlab

Desirable (future state)

- CloudFlare
- React native for ios & android
- go (graph API for apps)

## Prerequisits

1. Ensure you have Docker CE installed

2. register [recaptcha v3](https://www.google.com/recaptcha/admin/create)

3. GCP API keys for [SafeBrowsing API](https://console.cloud.google.com/apis/api/safebrowsing.googleapis.com/credentials)

4. [JumpCloud](https://console.jumpcloud.com)

- [Sendgrid](https://app.sendgrid.com)

6. [Stripe](https://dashboard.stripe.com)

7. [Gitlab](https://gitlab.com/trivialsec)

8. [Linode](https://cloud.linode.com/)

## Configure

1. Create a `.env` file in each project, with the following;

```
cp .env-example .env
```

Replace defaults with your own values. Make sure you are setup to read these automatically or amnually run `source .env` each time.

For debugging make sure you have `web/docker/.flaskenv` with `FLASK_DEBUG` and `FLASK_ENV` set, and rebuild.

2. Make a config file of your own. First ensure your own `APP_NAME` value is set, then update the `app-config-development.yaml` with the following values;

The recaptcha `secret_key` is sensitive and is not shared in this project as it impacts production, you should create one for yourself. Also the `app session secret` value can be anything random that you like for local development, it is used for session storage so production should be rotated with any significant change to session code.

And then run `bin/update-app-configs`

3. Become familiar with the Makefile to run the project components, make sure you run `db-create` and verify schema using;

```bash
docker-compose exec mysql-main bash -c "mysql -uroot -p -Dtrivialsec -e 'SHOW TABLES;'"
```

## TODO: elasticsearch

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
