#
# xs-node-build-minimal
#
# Make & Register image to docker.io/$(ORG)"
# $ make build
# $ make tag
# $ make login
# $ make push
#
# Start Jenkins using newest image
# $ make up
#
# TODO: ECR push
# TODO: Version bump & tagging
#
# Make environment
ORG := xybersolve
NAME := xs-node-minimal-build
PROJECT := $(NAME)
VERSION := 1.0.4
IMAGE := $(NAME)
CONTAINER := $(NAME)
BACKUP_DIR := ./archives

# targets
.PHONY: build tag push test deploy archive ssh help tag login push \
				tag-ecr login-ecr push-ecr

# Environment specifics for this build
#include ./env.mk

# Versioning
#VERSION=$(shell node -pe "require('./package.json').version")
HASH_LONG := $(shell git log -1 --pretty=%H)
HASH_SHORT := $(shell git log -1 --pretty=%h)
TAG_GIT := $(IMAGE):$(HASH_SHORT)
TAG_VER := $(IMAGE):$(VERSION)
TAG_LATEST := "$(IMAGE):latest"
REPO_GIT := $(ORG)/$(TAG_GIT)
REPO_VER := $(ORG)/$(TAG_VER)
REPO_LATEST := $(ORG)/$(TAG_LATEST)
# Archive
DATE_TIME := $(shell date +"%Y%m%d" )
BACKUP_FILE := $(IMAGE)-$(DATE_TIME)-$(HASH_SHORT).tgz
BACKUP_PATH := "$(BACKUP_DIR)/$(BACKUP_FILE)"


# AWS Envirnoment specifics for tag & push to ECR
# include Makefile.ecr
#ECR_URI := $(AWS_ACCT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
ECR_GIT := $(ECR_URI)/$(IMAGE):$(HASH_SHORT)
ECR_VER := $(ECR_URI)/$(IMAGE):$(VERSION)
ECR_LATEST := $(ECR_URI)/$(IMAGE):latest

build: ## Build docker image
	@echo 'build'
	@docker build -t "${IMAGE}" .

tag: ## Tag for DockerHub Registry
	@echo 'Tag image as follows:'
	#@echo "REPO_VER: $(REPO_VER)"
	@echo "GIT: $(IMAGE) $(ORG)/$(IMAGE):$(HASH_SHORT)"
	@echo "LATEST: $(IMAGE) $(ORG)/$(IMAGE):latest"
	#@docker tag $(IMAGE) $(REPO_VER)
	@docker tag $(IMAGE) $(ORG)/$(IMAGE):$(HASH_SHORT)
	@docker tag $(IMAGE) $(ORG)/$(IMAGE):latest
	#@docker tag $(IMAGE) $(REPO_GIT)
	#@docker tag $(IMAGE) $(REPO_LATEST)

test: ## Test whatever needs testing
	@echo 'Test what needs testing'

login: ## Login to DockerHub
	# from terminal
	@docker login -u ${DOCKER_USER} -p ${DOCKER_PASS} #${DOCKER_HOST}
	# from jenkins
	# @docker login -u $(user) -p $(pass)

push: login ## Push to DockerHub registry
	@echo 'Push to registry, as follows:'
	#@echo "REPO_VER: $(REPO_VER)"
	@echo "REPO_GIT: $(REPO_GIT)"
	@echo "REPO_LATEST: $(REPO_LATEST)"

	#@docker push $(REPO_VER)
	@docker push $(ORG)/$(IMAGE):$(HASH_SHORT)
	@docker push $(ORG)/$(IMAGE):latest

tag-ecr: ## Tag for AWS ECR
	# docker tag <image>:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/<image>:<tag>
	# <AWS_ACCT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/$(IMAGES):$(TAG)
	#@docker tag $(IMAGE) $(ECR_VER)
	@echo 'Tag for AWS ECR, as follows:'
	@echo "ECR_GIT: $(IMAGE) -> $(ECR_GIT)"
	@echo "ECR_LATEST: $(IMAGE) -> $(ECR_LATEST)"
	#@docker tag $(IMAGE) $(ECR_GIT)
	#@docker tag $(IMAGE) $(ECR_LATEST)

login-ecr: ## Login to AWS ECR
	@eval $$( aws ecr get-login --no-include-email )

push-ecr: login-ecr ## Push to AWS ECR
	#@docker push $(ECR_URI)/$(ECR_VER)
	@echo 'Push to AWS ECR, as follows:'
	@echo "ECR_GIT: $(ECR_GIT)"
	@echo "ECR_LATEST: $(ECR_LATEST)"
	#@docker push $(ECR_URI)/$(ECR_GIT)
	#@docker push $(ECR_URI)/$(ECR_LATEST)

deploy: build tag login push  ## Deploy into repo
# make build steps
# $ make build
# $ make tag
# $ make login
# $ make push

up: ## Run the newest created image
	# no run for build image - is base to be used by others
	
down: ## Bring down the running container
	docker container stop $(CONTAINER)
	docker container rmi $(CONTAINER)


clean: ## Delete the image
	@docker image rmi $(IMAGE)
	@docker image rmi $(REPO_LATEST)

archive: ## Archive image locally (compressed tar file)
	$(test -d $(OBJDIR) || shell mkdir -p $(BACKUP_DIR))
	@docker save -o $(BACKUP_PATH) $(IMAGE)

ssh: ## SSH into image
	@docker run -it --rm $(IMAGE):latest /bin/bash

help:
	@echo ''
	@echo ''
	@echo ''
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'
