.PHONY: init test

init:
	luarocks init --no-gitignore
	luarocks install busted 2.2.0-1

test:
	luarocks test --local
