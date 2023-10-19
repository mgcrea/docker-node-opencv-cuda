all: build

build:
	@docker build -t $(USER)/$(shell basename $(CURDIR)) .

.PHONY: all
