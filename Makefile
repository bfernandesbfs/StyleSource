TOOL_NAME = StyleSource
export EXECUTABLE_NAME = StyleSource
VERSION = 1.0.2

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(EXECUTABLE_NAME)
SHARE_PATH = $(PREFIX)/share/$(EXECUTABLE_NAME)

.PHONY: install build uninstall 

install: build
	mkdir -p $(PREFIX)/bin
	cp -f build/$(EXECUTABLE_NAME)/bin/$(EXECUTABLE_NAME) $(INSTALL_PATH)
	mkdir -p $(SHARE_PATH)
	cp -R build/$(EXECUTABLE_NAME)/templates $(SHARE_PATH)/templates
	
build:
	rake cli:build
	rake cli:install  

uninstall:
	rm -f $(INSTALL_PATH)
	rm -rf $(SHARE_PATH)