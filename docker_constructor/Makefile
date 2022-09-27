ORG=prjemian
REPO=constructor
LOGFILE=build-log.txt
NET=host-bridge

FULLNAME=$(ORG)/$(REPO)

build ::
	# docker build --tag my_iocs ./ 2>&1 | tee $(LOGFILE)

	docker build \
		-t $(FULLNAME)  \
		./  \
		2>&1 | tee $(LOGFILE)

shell :: build
	# docker run -it --rm my_iocs bash

	docker run \
		-it \
		--rm \
		--net=$(NET) \
		--name=$(REPO) \
		$(FULLNAME) \
		/bin/bash

# push ::
# 	docker push $(FULLNAME)

net ::
	docker network create \
		--driver bridge \
		$(NET)
