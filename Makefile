.PHONY: all clean test

test:
	nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedFile tests/debugprint.lua"
