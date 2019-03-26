# Setup variables for the Makefile
NAME=runscope-agent
REPO=virtuslab/runscope-agent
DOCKER_REGISTRY=quay.io

# Set POSIX sh for maximum interoperability
SHELL := /bin/sh
PATH  := $(GOPATH)/bin:$(PATH)

# Set an output prefix, which is the local directory if not specified
PREFIX?=$(shell pwd)

# Populate version variables
# Add to compile time flags
VERSION := $(shell cat VERSION.txt)
GITCOMMIT := $(shell git rev-parse --short HEAD)
GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
GITIGNOREDBUTTRACKEDCHANGES := $(shell git ls-files -i --exclude-standard)
ifneq ($(GITUNTRACKEDCHANGES),)
    GITCOMMIT := $(GITCOMMIT)-dirty
endif
ifneq ($(GITIGNOREDBUTTRACKEDCHANGES),)
    GITCOMMIT := $(GITCOMMIT)-dirty
endif

VERSION_TAG := $(VERSION)-$(GITCOMMIT)
LATEST_TAG := latest

ARGS ?= $(EXTRA_ARGS)

.DEFAULT_GOAL := help

.PHONY: all
all: clean init verify docker-build ## Ensure deps, test, verify, docker build
	@echo "+ $@"

.PHONY: init
init: ## Initializes this Makefile dependencies: checkmake
	@echo "+ $@"
	go get -u github.com/mrtazz/checkmake

.PHONY: verify
verify: checkmake ## Runs a checkmake

.PHONY: clean
clean: ## Cleanup
	@echo "+ $@"

.PHONY: spring-clean
spring-clean: ## Cleanup git ignored files (interactive)
	@echo "+ $@"
	git clean -Xdi

.PHONY: test
test: ## Runs the go tests
	@echo "+ $@"

.PHONY: docker-build
docker-build: ## Build the container
	@echo "+ $@"
	docker build -t $(REPO):$(GITCOMMIT) .

.PHONY: docker-login
docker-login: ## Log in into the repository
	@echo "+ $@"
	@docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}" $(DOCKER_REGISTRY)

.PHONY: docker-images
docker-images: ## List all local containers
	@echo "+ $@"
	@docker images

.PHONY: docker-push
docker-push: docker-login ## Push the container
	@echo "+ $@"
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(VERSION)
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(VERSION_TAG)
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(LATEST_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(VERSION)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(VERSION_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(LATEST_TAG)

.PHONY: docker-run
docker-run: docker-build ## Build and run the container
	@echo "+ $@"
	docker run -i -t -v $(PWD):/host \
		$(REPO):$(GITCOMMIT) --version

.PHONY: bump-version
BUMP := patch
bump-version: ## Bump the version in the version file. Set BUMP to [ patch | major | minor ]
	@echo "+ $@"
	go get -u github.com/jessfraz/junk/sembump # update sembump tool
	$(eval NEW_VERSION=$(shell sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION.txt from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION.txt
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in README.md"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g README.md
	git add VERSION.txt README.md
	git commit -vseam "Bump version to $(NEW_VERSION)"
	@echo "Run make tag to create and push the tag for new version $(NEW_VERSION)"

.PHONY: tag
tag: ## Create a new git tag to prepare to build a release
	@echo "+ $@"
	git tag -s -a $(VERSION) -m "$(VERSION)"
	git push origin $(VERSION)

.PHONY: help
help:
	@grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: checkmake
checkmake: ## Check this Makefile
	@echo "+ $@"
	@checkmake Makefile

.PHONY: status
status: ## Shows git and dep status
	@echo "+ $@"
	@echo "Commit: $(GITCOMMIT), VERSION: $(VERSION)"
	@echo
ifneq ($(GITUNTRACKEDCHANGES),)
	@echo "Changed files:"
	@git status --porcelain --untracked-files=no
	@echo
endif
ifneq ($(GITIGNOREDBUTTRACKEDCHANGES),)
	@echo "Ignored but tracked files:"
	@git ls-files -i --exclude-standard
	@echo
endif
	@echo "Dependencies:"
	@dep status
	@echo
