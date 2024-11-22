.PHONY: test

test:
	nvim --headless --clean -u tests/minimal.lua -c "PlenaryBustedFile tests/debugprint.lua"
