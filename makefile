#  Copyright 2023 The Nephio Authors.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

.SHELLFLAGS = -ec

GO_VERSION ?= 1.20.2
VERSION ?= latest
REGISTRY ?= docker.io/nephio
ITFIMG ?= $(REGISTRY)/interface-fn:${VERSION}
DNNIMG ?= $(REGISTRY)/dnn-fn:${VERSION}
NADIMG ?= $(REGISTRY)/nad-fn:${VERSION}
IPAMIMG ?= $(REGISTRY)/ipam-fn:${VERSION}
VLANIMG ?= $(REGISTRY)/vlan-fn:${VERSION}
UPFIMG ?= $(REGISTRY)/upf-deploy-fn:${VERSION}
AMFIMG ?= $(REGISTRY)/amf-deploy-fn:${VERSION}
SMFIMG ?= $(REGISTRY)/smf-deploy-fn:${VERSION}

# find all subdirectories with a go.mod file in them
GO_MOD_DIRS = $(shell find . -name 'go.mod' -exec sh -c 'echo \"$$(dirname "{}")\" ' \; )
# NOTE: the above line is complicated due to the limited capabilities of busybox's `find`.
# It meant to be equivalent with this:  find . -name 'go.mod' -printf "'%h' " 


.PHONY: all
all: test fmt vet

.PHONY: build
all: docker-build docker-push

.PHONY: test fmt vet
# delegate these targets to the Makefiles of individual go modules
test fmt vet: 
	for dir in $(GO_MOD_DIRS); do \
		$(MAKE) -C "$$dir" $@ ; \
	done

include default-go-test.mk
include default-go-lint.mk
include default-gosec.mk
include default-go-misc.mk

docker-build:  ## Build docker images.
	docker buildx build --load --tag  ${ITFIMG} -f ./interface-fn/Dockerfile .
	docker buildx build --load --tag  ${DNNIMG} -f ./dnn-fn/Dockerfile .
	docker buildx build --load --tag  ${NADIMG} -f ./nad-fn/Dockerfile .
	docker buildx build --load --tag  ${IPAMIMG} -f ./ipam-fn/Dockerfile .
	docker buildx build --load --tag  ${VLANIMG} -f ./vlan-fn/Dockerfile .
	docker buildx build --load --tag  ${UPFIMG} -f ./nfdeploy-fn/upfdeployfn/Dockerfile .
	docker buildx build --load --tag  ${SMGIMG} -f ./nfdeploy-fn/smfdeployfn/Dockerfile .
	docker buildx build --load --tag  ${AMFIMG} -f ./nfdeploy-fn/amfdeployfn/Dockerfile .

docker-push: ## Build docker images.
	docker buildx build --push --tag  ${ITFIMG} -f ./interface-fn//Dockerfile .
	docker buildx build --push --tag  ${DNNIMG} -f ./dnn-fn//Dockerfile .
	docker buildx build --push --tag  ${NADIMG} -f ./nad-fn//Dockerfile .
	docker buildx build --push --tag  ${IPAMIMG} -f ./ipam-fn//Dockerfile .
	docker buildx build --push --tag  ${VLANIMG} -f ./vlan-fn//Dockerfile .
	docker buildx build --push --tag  ${UPFIMG} -f ./nfdeploy-fn/upfdeployfn/Dockerfile .
	docker buildx build --push --tag  ${SMGIMG} -f ./nfdeploy-fn/smfdeployfn/Dockerfile .
	docker buildx build --push --tag  ${AMFIMG} -f ./nfdeploy-fn/amfdeployfn/Dockerfile .

