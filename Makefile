SHELL := /bin/bash
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

CMD_AWS := aws
ifdef AWS_PROFILE
CMD_AWS += --profile $(AWS_PROFILE)
endif
ifdef AWS_REGION
CMD_AWS += --region $(AWS_REGION)
endif

prep:
	mkdir -p worker_datadir mysql_datadir redis_datadir
	find . -type f -name '*.pyc' -delete 2>/dev/null || true
	find . -type d -name '__pycache__' -delete 2>/dev/null || true
	find . -type f -name '*.DS_Store' -delete 2>/dev/null || true

wheel: prep
	rm -rf common/build common/dist common/trivialsec_common.egg-info web/docker/build workers/docker/build web/docker/packages workers/docker/packages
	pip uninstall -y trivialsec-common || true
	cd common; python3.8 setup.py check && pip --no-cache-dir wheel --wheel-dir=build/wheel -r requirements.txt && \
		python3.8 setup.py bdist_wheel --universal
	pip install --no-cache-dir --find-links=common/build/wheel --no-index common/dist/trivialsec_common-*-py2.py3-none-any.whl
	cp -r common/build/wheel web/docker/build
	cp common/dist/trivialsec_common-*.whl web/docker/build/
	cp -r common/build/wheel workers/docker/build
	cp common/dist/trivialsec_common-*.whl workers/docker/build/

watch:
	while [[ 1 ]]; do inotifywait -e modify --exclude build common/setup.py ; make build-wheel && make rebuild-workers && make run-workers && docker-compose build --compress web && make run-web ; done

install-dev:
	pip install -q -U pip setuptools pylint wheel awscli
	pip install -q -U --no-cache-dir --isolated -r ./common/requirements.txt
	pip install -q -U --no-cache-dir --isolated -r ./web/docker/requirements.txt
	pip install -q -U --no-cache-dir --isolated -r ./workers/docker/requirements.txt

lint:
	cd workers/src; pylint --jobs=0 --persistent=y --errors-only **/*.py
	cd web/src; pylint --jobs=0 --persistent=y --errors-only **/*.py

update:
	git pull
	docker-compose pull redis mongo mysql

build-runner:
	docker-compose build --no-cache --compress gitlab-runner

buildnc-base:
	docker-compose build --no-cache --compress python-base
	docker tag $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/trivialsec/python-base trivialsec/python-base
	docker-compose build --no-cache --compress node-base
	docker tag $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/trivialsec/node-base trivialsec/node-base

build-base:
	docker-compose build --compress python-base
	docker tag $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/trivialsec/python-base trivialsec/python-base
	# docker-compose build --compress node-base
	# docker tag $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/trivialsec/node-base trivialsec/node-base

build: package
	docker-compose build --compress web sockets workers

buildnc: buildnc-base package
	docker-compose build --no-cache --compress web sockets workers

rebuild: down build

docker-clean:
	docker rmi $(docker images -qaf "dangling=true")
	yes | docker system prune
	sudo service docker restart

docker-purge:
	docker rmi $(docker images -qa)
	yes | docker system prune
	sudo service docker stop
	sudo rm -rf /tmp/docker.backup/
	sudo cp -Pfr /var/lib/docker /tmp/docker.backup
	sudo rm -rf /var/lib/docker
	sudo service docker start

up: prep
	docker-compose up -d web sockets workers

down:
	docker-compose stop web sockets workers
	yes|docker-compose rm web sockets workers
