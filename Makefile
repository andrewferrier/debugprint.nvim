.PHONY: all clean test

test:
	nvim --headless --clean -u tests/minimal.vim -c "PlenaryBustedFile tests/debugprint.lua" -c ":qall!"
