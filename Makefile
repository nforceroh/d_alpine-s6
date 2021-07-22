#!/usr/bin/make -f

SHELL := /bin/bash
IMG_NAME := ocp_alpine-s6
IMG_REPO := nforceroh
BUILD_TAG := $(shell date +"v%Y%m%d%H%M" )
VERSION := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ" )
BRANCH := $(shell git branch --show-current)
 
ifeq ($(BRANCH),dev)
	VERSION := dev
else
	VERSION := edge
endif

.PHONY: context all build push gitcommit gitpush
all: context build push 
git: context gitcommit gitpush

context: 
	@echo "Switching docker context to default"
	docker context use default

build: 
	@echo "Building $(IMG_NAME)image"
ifeq ($(VERSION), dev)
	docker buildx build --rm . \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VERSION)" \
		--build-arg BASE_IMAGE="alpine:edge" \
		-t "$(IMG_REPO)/$(IMG_NAME)" \
		-t "$(IMG_REPO)/$(IMG_NAME):dev" 
else
	docker buildx build --rm . \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VERSION)" \
		--build-arg BASE_IMAGE="alpine:edge" \
		-t "$(IMG_REPO)/$(IMG_NAME)" \
		-t "$(IMG_REPO)/$(IMG_NAME):$(BUILD_TAG)" \
		-t "$(IMG_REPO)/$(IMG_NAME):latest" 
endif

gitcommit:
	git push

gitpush:
	@echo "Building $(IMG_NAME):$(BUILD_DATE) image"
	git tag -a $(BUILD_TAG) -m "Update to $(BUILD_TAG)"
	git push --tags

push: 
	@echo "Building $(IMG_NAME):$(VERSION) image"
ifeq ($(VERSION), dev)
	docker push $(IMG_REPO)/$(IMG_NAME):dev
else
	docker push $(IMG_REPO)/$(IMG_NAME):$(BUILD_TAG)
	docker push $(IMG_REPO)/$(IMG_NAME):latest
endif

end:
	@echo "Done!"
