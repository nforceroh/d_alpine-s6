#!/usr/bin/make -f

SHELL := /bin/bash
IMG_NAME := d_alpine-s6
IMG_REPO := nforceroh
DATE_VERSION := $(shell date +"v%Y%m%d" )
BRANCH := $(shell git branch --show-current)
 
ifeq ($(BRANCH),master)
	VERSION := dev
else
	VERSION := $(BRANCH)
endif


.PHONY: context all build push gitcommit gitpush
all: context build push 
git: context gitcommit gitpush

context: 
	@echo "Switching docker context to default"
	docker context use default

build: 
	@echo "Building $(IMG_NAME)image"
	docker build --rm --tag=$(IMG_REPO)/$(IMG_NAME) .
ifeq ($(VERSION), dev)
	docker tag $(IMG_REPO)/$(IMG_NAME) $(IMG_REPO)/$(IMG_NAME):dev
else
	docker tag $(IMG_REPO)/$(IMG_NAME) $(IMG_REPO)/$(IMG_NAME):$(DATE_VERSION)
	docker tag $(IMG_REPO)/$(IMG_NAME) $(IMG_REPO)/$(IMG_NAME):$(VERSION)
	docker tag $(IMG_REPO)/$(IMG_NAME) $(IMG_REPO)/$(IMG_NAME):latest
endif

gitcommit:
	git push

gitpush:
	@echo "Building $(IMG_NAME):$(VERSION) image"
	git tag -a $(VERSION) -m "Update to $(VERSION)"
	git push --tags

push: 
	@echo "Building $(IMG_NAME):$(VERSION) image"
ifeq ($(VERSION), dev)
	docker push $(IMG_REPO)/$(IMG_NAME):dev
else
	docker push $(IMG_REPO)/$(IMG_NAME):$(DATE_VERSION)
	docker push $(IMG_REPO)/$(IMG_NAME):$(VERSION)
	docker push $(IMG_REPO)/$(IMG_NAME):latest
endif

end:
	@echo "Done!"
