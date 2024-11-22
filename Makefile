.PHONY: test

test:
	nvim --headless --clean -u tests/run.lua
