.PHONY: dev build


dev:
	openfl test html5 -nolaunch


build:
	openfl build html5 -final
