-- # Demo
--
-- In debugprint.nvim, you can add 'print' statements in all kinds of ways.
--
-- You can:
--
-- 1. Insert a 'plain' debug statement:

foo = 1

-- 2. Insert a debug statement using the variable under the cursor (uses treesitter):

bar = 2

-- 3. Insert a debug statement using the visual selection:

banana = foo + bar

-- 4. Insert a debug statement above the cursor instead of below:

apple = foo - bar

-- 5. Insert a debug statement using a motion:

orange = foo * bar

-- 6. Delete all the debug statements again.

-- Lots more options for customization and usage, please see the README:
-- https://github.com/andrewferrier/debugprint.nvim/blob/main/README.md
--
-- vim: nonumber norelativenumber:
