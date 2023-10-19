PLATFORM:=linux/amd64

all: build

run:
	@docker run -it --rm --platform $(PLATFORM) $(USER)/$(shell basename $(CURDIR)) /bin/sh

build:
	@docker build --platform $(PLATFORM) --tag $(USER)/$(shell basename $(CURDIR)) .

.PHONY: all
