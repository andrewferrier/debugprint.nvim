# Changelog

## [4.0.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.7.0...v4.0.0) (2024-12-11)


### ⚠ BREAKING CHANGES

* Use persistent counter - closes #143

### Features

* Add COBOL support ([357117c](https://github.com/andrewferrier/debugprint.nvim/commit/357117c435597bbd50a907072d298df0cd847daa))
* Add support for svelte and vue ([0480f2f](https://github.com/andrewferrier/debugprint.nvim/commit/0480f2fc3fc93249f9f90336d840360c2ae40b6c))
* Use persistent counter - closes [#143](https://github.com/andrewferrier/debugprint.nvim/issues/143) ([26ba69f](https://github.com/andrewferrier/debugprint.nvim/commit/26ba69f06d126eaa09eaea9ae872611b2b86ebcf))


### Bug Fixes

* Don't use vim.fs.rm(), it's not in stable yet ([3b7d34c](https://github.com/andrewferrier/debugprint.nvim/commit/3b7d34c37ecc4737f998498b10432e7538536627))
* simpler implementation of vim.fs.joinpath() ([4a798ae](https://github.com/andrewferrier/debugprint.nvim/commit/4a798ae5f5bb65131334e4d9b8cafa52c858c8ab))
* Stop using joinpath() ([8a54467](https://github.com/andrewferrier/debugprint.nvim/commit/8a544678a950809cf07ae03dd019dfa98751aa6a))
* Support empty or false to remove default keybindings ([bf6c457](https://github.com/andrewferrier/debugprint.nvim/commit/bf6c457d6dc5b1c7b053361ead34954714618983))

## [3.7.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.6.0...v3.7.0) (2024-11-24)


### Features

* Add support for Lisp ([391f013](https://github.com/andrewferrier/debugprint.nvim/commit/391f01348d26d3d1d5bf96a21fe7402eb5090928))
* Add support for tcl ([efbce12](https://github.com/andrewferrier/debugprint.nvim/commit/efbce12f0f7c59133aa583913bbc117302089a08))


### Bug Fixes

* Add missing validation for insert mode ([392bd6c](https://github.com/andrewferrier/debugprint.nvim/commit/392bd6c2a093d2272df6aa6fff0da6eae8da5208))

## [3.6.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.5.0...v3.6.0) (2024-11-08)


### Features

* Support insert mode - closes [#86](https://github.com/andrewferrier/debugprint.nvim/issues/86) ([bb47042](https://github.com/andrewferrier/debugprint.nvim/commit/bb470420456907e5c58e2656bbe20a2739640ba4))


### Bug Fixes

* Correct key descriptions ([575f2e3](https://github.com/andrewferrier/debugprint.nvim/commit/575f2e320770e342894e2a53701bd8e38189809e))
* get insert mode variable working with noice - closes [#86](https://github.com/andrewferrier/debugprint.nvim/issues/86) ([6a08653](https://github.com/andrewferrier/debugprint.nvim/commit/6a08653800e5f29483c44c43e90c37c25241c4e6))
* Type annotations ([3bdd861](https://github.com/andrewferrier/debugprint.nvim/commit/3bdd8619198811ce0ad173ba91ddd9b6b85096ca))
* typecheck issue ([7b7a02c](https://github.com/andrewferrier/debugprint.nvim/commit/7b7a02c76d372818ed21f9d0755e342a25a64d31))

## [3.5.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.4.0...v3.5.0) (2024-11-03)


### Features

* Override display_* on a per-filetype basis - closes [#135](https://github.com/andrewferrier/debugprint.nvim/issues/135) ([30e3fb3](https://github.com/andrewferrier/debugprint.nvim/commit/30e3fb35a91f2f82a4d4eb9a8bbbd04a7ac8ffd3))


### Bug Fixes

* Add missing function to display_counter ([c14ac8d](https://github.com/andrewferrier/debugprint.nvim/commit/c14ac8d1a72cf14c23bf400efadceda3c6aa5cc3))
* Correct link for adding filetypes ([358340a](https://github.com/andrewferrier/debugprint.nvim/commit/358340a38ade149df8bc097f19336dac1f10b4f2))
* Failing test on earlier NeoVim versions ([f8b1f2f](https://github.com/andrewferrier/debugprint.nvim/commit/f8b1f2fbc52d3c012b2bdb157224140ebcac985e))
* Remove 'commands' from validate name also ([90764e4](https://github.com/andrewferrier/debugprint.nvim/commit/90764e464c7504bb1723b9ca0465824d61d1735a))
* Typing issue ([3859e21](https://github.com/andrewferrier/debugprint.nvim/commit/3859e219a98fcdea94a0b558bcf849368e9d8488))
* Typing issues ([52ced26](https://github.com/andrewferrier/debugprint.nvim/commit/52ced26fe43160853989b34d2684dbdc27c0995b))
* validating nonexistent field `commands_toggle_comment_debug_prints` ([943afa6](https://github.com/andrewferrier/debugprint.nvim/commit/943afa65569458146388b9cd0572b6664f62b22c))

## [3.4.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.3.0...v3.4.0) (2024-10-29)


### Features

* Add support for Zig ([424d367](https://github.com/andrewferrier/debugprint.nvim/commit/424d36714491c21b364ac96cb01522acad935b86))


### Bug Fixes

* typo in plain above desc ([daf79f3](https://github.com/andrewferrier/debugprint.nvim/commit/daf79f38f30049a4eaed04952c305922f42c55d1))

## [3.3.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.2.1...v3.3.0) (2024-10-26)


### Features

* Dummy ([e02ca84](https://github.com/andrewferrier/debugprint.nvim/commit/e02ca840e4fdd47c9ccdfa75d07f334d9fb4ac59))

## [3.2.1](https://github.com/andrewferrier/debugprint.nvim/compare/v3.2.0...v3.2.1) (2024-10-26)


### Bug Fixes

* Trigger for luarocks ([6083ff3](https://github.com/andrewferrier/debugprint.nvim/commit/6083ff3a3d8e2faccbe15f10be348208693bea94))
* Try using 'published' instead for luarocks ([600746d](https://github.com/andrewferrier/debugprint.nvim/commit/600746d90f9eec90b026302662b5b1883cae7457))

## [3.2.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.1.2...v3.2.0) (2024-10-26)


### Features

* Add display_location and enhance tests - closes [#122](https://github.com/andrewferrier/debugprint.nvim/issues/122) ([0a2a860](https://github.com/andrewferrier/debugprint.nvim/commit/0a2a8607179062326131080ba8da7fef922a45e1))
* Add luarocks support ([7358de8](https://github.com/andrewferrier/debugprint.nvim/commit/7358de804a1b796f072d88bf6607ce34f3d06078))
* support Apex language ([0228c0e](https://github.com/andrewferrier/debugprint.nvim/commit/0228c0e94fb52c2406ef33fb0e467efb79760f10))


### Bug Fixes

* Handle empty print_tag ([4e84b47](https://github.com/andrewferrier/debugprint.nvim/commit/4e84b47836ebd527efd3f341e090cb9b2c0e6e26))
* Remove redundant 'lua' ([f71c14e](https://github.com/andrewferrier/debugprint.nvim/commit/f71c14e8b6a3b276ca2fcc0963cbdf599f06b443))

## [3.1.2](https://github.com/andrewferrier/debugprint.nvim/compare/v3.1.1...v3.1.2) (2024-08-30)


### Bug Fixes

* variable_above_alwaysprompt key - closes [#115](https://github.com/andrewferrier/debugprint.nvim/issues/115) ([9d09893](https://github.com/andrewferrier/debugprint.nvim/commit/9d09893caf62c5182a881fb794e7b12ab1fec090))

## [3.1.1](https://github.com/andrewferrier/debugprint.nvim/compare/v3.1.0...v3.1.1) (2024-08-11)


### Bug Fixes

* Remove specific version numbers in deprecation warnings ([31588c4](https://github.com/andrewferrier/debugprint.nvim/commit/31588c410a733606f2cbb046eb1eb1b6df323144))

## [3.1.0](https://github.com/andrewferrier/debugprint.nvim/compare/v3.0.0...v3.1.0) (2024-07-28)


### Features

* Introduce lazy.nvim package spec - closes [#109](https://github.com/andrewferrier/debugprint.nvim/issues/109) ([7c9b7f0](https://github.com/andrewferrier/debugprint.nvim/commit/7c9b7f0a3ead18f762a02c26869fe6d257edda32))


### Bug Fixes

* Change back to not supplying lazy-loading config - closes [#111](https://github.com/andrewferrier/debugprint.nvim/issues/111) ([96e6d32](https://github.com/andrewferrier/debugprint.nvim/commit/96e6d324d83b2c31e67681f2c100260128b0c517))
* Temporary workaround for lazy-loading issue ([265b070](https://github.com/andrewferrier/debugprint.nvim/commit/265b0706e83a60817bbda7475fc549832a9e467a))

## [3.0.0](https://github.com/andrewferrier/debugprint.nvim/compare/v2.0.1...v3.0.0) (2024-05-18)


### ⚠ BREAKING CHANGES

* Deprecate global-level ignore_treesitter option - closes #100
* Remove support for NeoVim 0.8

### Features

* Add support for AppleScript ([0811b50](https://github.com/andrewferrier/debugprint.nvim/commit/0811b5090990f3b6cc9dce98d0c4603b26c0c22f))
* Customizable display_counter - closes [#104](https://github.com/andrewferrier/debugprint.nvim/issues/104) ([1400e08](https://github.com/andrewferrier/debugprint.nvim/commit/1400e089ee350c09313046ae889b163a8b1ddd49))
* Show number of lines on delete/toggle - closes [#101](https://github.com/andrewferrier/debugprint.nvim/issues/101) ([77be09b](https://github.com/andrewferrier/debugprint.nvim/commit/77be09b879756c4c48f7f6af3a2d12ed5427ae5b))
* Use smarter variable finding - closes [#27](https://github.com/andrewferrier/debugprint.nvim/issues/27) ([052693a](https://github.com/andrewferrier/debugprint.nvim/commit/052693a60afd76dd43903e83e2f3acb482df2e90))


### Bug Fixes

* Get node name correctly for default case ([1c93860](https://github.com/andrewferrier/debugprint.nvim/commit/1c938607af581a6ecc850850a51c0f5526c53032))
* Use tbl_get to support 0.8 ([40fc629](https://github.com/andrewferrier/debugprint.nvim/commit/40fc629ffdfdcc94049bd9809e9b7992cda5fb1d))


### Miscellaneous Chores

* Deprecate global-level ignore_treesitter option - closes [#100](https://github.com/andrewferrier/debugprint.nvim/issues/100) ([7d49362](https://github.com/andrewferrier/debugprint.nvim/commit/7d4936251a117c9a9d9e505f12bec9311646c707))
* Remove support for NeoVim 0.8 ([1f03985](https://github.com/andrewferrier/debugprint.nvim/commit/1f03985c69ed28f17cbdfcfc7baeafe85126ac50))

## [2.0.1](https://github.com/andrewferrier/debugprint.nvim/compare/v2.0.0...v2.0.1) (2024-04-24)


### Bug Fixes

* Lazy loading - no autocmds/warn on unmodifiable buffers - closes [#97](https://github.com/andrewferrier/debugprint.nvim/issues/97) ([61dbc50](https://github.com/andrewferrier/debugprint.nvim/commit/61dbc504ec8245dfa7637cb6f2a07f0547132593))

## [2.0.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.9.0...v2.0.0) (2024-04-17)


### ⚠ BREAKING CHANGES

* New keymap/command configuration - closes #44

### Features

* add elixir support ([0ac7f57](https://github.com/andrewferrier/debugprint.nvim/commit/0ac7f57d340e6ab326ebd28de2dd6e3944307f76))
* Implement comment toggle - closes [#85](https://github.com/andrewferrier/debugprint.nvim/issues/85) ([7fac302](https://github.com/andrewferrier/debugprint.nvim/commit/7fac302c9dc4f687edb7ce6ce9637fa235fa875f))
* Keybinding: delete_debug_lines - closes [#87](https://github.com/andrewferrier/debugprint.nvim/issues/87) ([6ef8571](https://github.com/andrewferrier/debugprint.nvim/commit/6ef8571d04368fe9c5638545780e743164dbc980))
* **keymap:** map keys only on `modifiable` buffers and make keymaps buffer-local ([319edf0](https://github.com/andrewferrier/debugprint.nvim/commit/319edf00fdf5941695d8c3b51a438050df8987b7))
* New keymap/command configuration - closes [#44](https://github.com/andrewferrier/debugprint.nvim/issues/44) ([ee9d6ff](https://github.com/andrewferrier/debugprint.nvim/commit/ee9d6ffa00709f90c51c69afe913fafa9400c9ed))
* Simplify configuration warning text ([7e8ccd4](https://github.com/andrewferrier/debugprint.nvim/commit/7e8ccd42607c50a5d1bc728d7552fbafc7978c7e))


### Bug Fixes

* Debug Print Not generating for c_shrarp file type ([3d00dd0](https://github.com/andrewferrier/debugprint.nvim/commit/3d00dd0551841b867b479c1f0d81c04044a70e81))
* g?v for comments in lua ([f9b9b87](https://github.com/andrewferrier/debugprint.nvim/commit/f9b9b87dbb87b6b785b7108f524eaa32ff60b855))
* Mapping TS lang → filetype - closes [#93](https://github.com/andrewferrier/debugprint.nvim/issues/93) ([3b21eba](https://github.com/andrewferrier/debugprint.nvim/commit/3b21eba7b8796c4787b43b7119ce17fc6f5bbff4))
* Only map TSLang → ft on NeoVim 0.9+ ([8c7a872](https://github.com/andrewferrier/debugprint.nvim/commit/8c7a8721a1eb9e125204bd31581c04920c0a5e52))
* Only warn once about NeoVim version ([005430d](https://github.com/andrewferrier/debugprint.nvim/commit/005430d3128808649e6c274c39fce0a1b45aeaa5))
* Remove conflicts with nvim-notify - closes [#91](https://github.com/andrewferrier/debugprint.nvim/issues/91) ([bb6d1c9](https://github.com/andrewferrier/debugprint.nvim/commit/bb6d1c934f5c42435e4c0bf76fbb10f5b6a109bc))
* Setup of function callbacks ([32137d7](https://github.com/andrewferrier/debugprint.nvim/commit/32137d76ae2b4b1341677c9e107e48b2d4f1c82f))
* Use feedkeys to work with noice.nvim - closes [#80](https://github.com/andrewferrier/debugprint.nvim/issues/80) ([a326cad](https://github.com/andrewferrier/debugprint.nvim/commit/a326cadf61a1ebf564c109155333f8d8cf236e82))
* Use non-deprecated API ([63e9017](https://github.com/andrewferrier/debugprint.nvim/commit/63e901772418be8ecdd532c48fc4ba4f4b0272d7))

## [1.9.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.8.0...v1.9.0) (2024-03-29)


### Features

* Support `left_var` - closes [#82](https://github.com/andrewferrier/debugprint.nvim/issues/82) ([3e8e393](https://github.com/andrewferrier/debugprint.nvim/commit/3e8e393d8ef538baf4398f5657f2f50040a2648b))
* Use dynamic lang detect - closes [#9](https://github.com/andrewferrier/debugprint.nvim/issues/9) ([a9a09ae](https://github.com/andrewferrier/debugprint.nvim/commit/a9a09ae307c120e8eb103399ebe57b6a861ea986))


### Bug Fixes

* Accuracy finding embedded langs - closes [#84](https://github.com/andrewferrier/debugprint.nvim/issues/84) ([b813797](https://github.com/andrewferrier/debugprint.nvim/commit/b813797c8a78fb8683b495453de9ba7c4c4d2416))
* Make validation work ([fdc30b2](https://github.com/andrewferrier/debugprint.nvim/commit/fdc30b2572bdc65587e9e57d9d09f1b20e587010))
* Take a fresh copy of options object each time ([c63b01d](https://github.com/andrewferrier/debugprint.nvim/commit/c63b01dbcf024647de999714fd97f518f6d0c4e7))

## [1.8.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.7.0...v1.8.0) (2024-02-22)


### Features

* Add Fortran support ([63a28d1](https://github.com/andrewferrier/debugprint.nvim/commit/63a28d1b3a585dd08e273bc8b735e845387e49e6))
* Add Haskell support ([d8bc418](https://github.com/andrewferrier/debugprint.nvim/commit/d8bc418262c51b43e282945c4f8d47f4ae8226f2))

## [1.7.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.6.0...v1.7.0) (2024-01-21)


### Features

* Make MIT Licensed ([189c13b](https://github.com/andrewferrier/debugprint.nvim/commit/189c13b410d2a7fff9ace474a4aede6db3bbdcbc))


### Bug Fixes

* License link ([f3633cb](https://github.com/andrewferrier/debugprint.nvim/commit/f3633cb2206299d263e107acd64698dcd6b47a55))

## [1.6.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.5.1...v1.6.0) (2023-11-28)


### Features

* Add 'R' support ([89a791b](https://github.com/andrewferrier/debugprint.nvim/commit/89a791ba9eda248f892eb6675ebc02d5805f8ce5))
* Add CMake support ([78f6400](https://github.com/andrewferrier/debugprint.nvim/commit/78f64000415357e3351f9e8a0882e021c804b653))
* Add dosbatch support ([33aefa6](https://github.com/andrewferrier/debugprint.nvim/commit/33aefa6076c80beda623300152e15003662cfbbd))
* Add fish support ([37cba86](https://github.com/andrewferrier/debugprint.nvim/commit/37cba864e0a127c2cb50f66114c21a9016328cc8))
* Add perl support ([f1fda1c](https://github.com/andrewferrier/debugprint.nvim/commit/f1fda1c95a7777aabde7660b74c2c8adef8fb949))


### Bug Fixes

* JavaScript logging debug → warn ([c8341fd](https://github.com/andrewferrier/debugprint.nvim/commit/c8341fddca633ffe8b50474601c3651f260dbeed))
* Remove stderr for Python ([a3f8beb](https://github.com/andrewferrier/debugprint.nvim/commit/a3f8bebb76b1ce44a9a3cdd3ae748e1ba883d325))
* Try to fix demo video link ([dafd4db](https://github.com/andrewferrier/debugprint.nvim/commit/dafd4db801174cc9544715cdcb3b72fd8f65ce2d))

## [1.5.1](https://github.com/andrewferrier/debugprint.nvim/compare/v1.5.0...v1.5.1) (2023-11-24)


### Bug Fixes

* Don't make keybindings unique - closes [#69](https://github.com/andrewferrier/debugprint.nvim/issues/69) ([08a4dff](https://github.com/andrewferrier/debugprint.nvim/commit/08a4dff0c73d80efad06bbd28b933b3a309af9f6))
* populate runtimepath correctly - closes [#65](https://github.com/andrewferrier/debugprint.nvim/issues/65) ([e12671b](https://github.com/andrewferrier/debugprint.nvim/commit/e12671b96050a79606d63504e196f4df0fccc2e2))

## [1.5.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.4.0...v1.5.0) (2023-11-15)


### Features

* Add Kotlin support ([0676e6d](https://github.com/andrewferrier/debugprint.nvim/commit/0676e6d2b9ac6faef0ca5a664af632af658d84ed))
* Add support for Powershell/ps1 ([d1fb0c1](https://github.com/andrewferrier/debugprint.nvim/commit/d1fb0c1ff41c7d823fa870c316de8320d202144d))
* Support Swift ([49e83ea](https://github.com/andrewferrier/debugprint.nvim/commit/49e83ea3c2cec7b4cff836b7c773110dcf1ed528))


### Bug Fixes

* get_node_at_cursor works again on 0.8.x - closes [#64](https://github.com/andrewferrier/debugprint.nvim/issues/64) ([b141128](https://github.com/andrewferrier/debugprint.nvim/commit/b14112882ab1247dd3480eabe3bac7b20ffe3334))

## [1.4.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.3.0...v1.4.0) (2023-11-06)


### Features

* Handle variables in Makefiles - closes [#37](https://github.com/andrewferrier/debugprint.nvim/issues/37) ([52c82f6](https://github.com/andrewferrier/debugprint.nvim/commit/52c82f6c3c01f09c7812793bbce50206a4c20030))

## [1.3.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.2.0...v1.3.0) (2023-11-02)


### Features

* Use a default value for variable input - closes [#59](https://github.com/andrewferrier/debugprint.nvim/issues/59) ([775de28](https://github.com/andrewferrier/debugprint.nvim/commit/775de28f3477f3f3498a55e267cbfde1d7a7a39d))


### Bug Fixes

* Property identifier for Typescript - closes [#60](https://github.com/andrewferrier/debugprint.nvim/issues/60) ([e811865](https://github.com/andrewferrier/debugprint.nvim/commit/e81186571ea7358f65536a8d72197f5b6bea12ba))

## [1.2.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.1.0...v1.2.0) (2023-10-07)


### Features

* Ignore blank calc'ing snippet - closes [#55](https://github.com/andrewferrier/debugprint.nvim/issues/55) ([6ad5606](https://github.com/andrewferrier/debugprint.nvim/commit/6ad5606eebe7b872da1683c90ad5ec2bb071919a))
* Make keymappings unique ([92a6dd1](https://github.com/andrewferrier/debugprint.nvim/commit/92a6dd1a5958a7f951aa70c37d48ebdd20cd8203))
* Make uses stderr, JS uses console.debug - closes [#48](https://github.com/andrewferrier/debugprint.nvim/issues/48) ([f7f88de](https://github.com/andrewferrier/debugprint.nvim/commit/f7f88de9791ecee16cab028907cacfd88df289d2))

## [1.1.0](https://github.com/andrewferrier/debugprint.nvim/compare/v1.0.0...v1.1.0) (2023-04-20)


### Features

* Improve Rust variables - closes [#52](https://github.com/andrewferrier/debugprint.nvim/issues/52) ([4af9d23](https://github.com/andrewferrier/debugprint.nvim/commit/4af9d23b34a63cb2f371dad654b4141554d3d194))

## 1.0.0 (2023-04-17)


### ⚠ BREAKING CHANGES

* Require NeoVim 0.8+

### Features

* Add 'display_counter' toggle - closes [#32](https://github.com/andrewferrier/debugprint.nvim/issues/32) ([a814776](https://github.com/andrewferrier/debugprint.nvim/commit/a8147760ca08a86a0d44696048d37d3dac352095))
* Add 'display_counter' toggle - closes [#32](https://github.com/andrewferrier/debugprint.nvim/issues/32) ([b1fd07f](https://github.com/andrewferrier/debugprint.nvim/commit/b1fd07f96bee7e50a26b675e9c160c8cb262c69a))
* Add alternative comparison table ([f1b4005](https://github.com/andrewferrier/debugprint.nvim/commit/f1b4005781cd32fc1f3611fa2a23b5cf5fa6ca59))
* Add description for each of default keybinds - closes [#47](https://github.com/andrewferrier/debugprint.nvim/issues/47) ([4ed72da](https://github.com/andrewferrier/debugprint.nvim/commit/4ed72da2f8c8f881113b6d10d5a566fc3a6e200c))
* Add Docker support ([390a081](https://github.com/andrewferrier/debugprint.nvim/commit/390a08146aa7ac22ea2c37b23bcd61066bb84a58))
* Add js-like languages ([e1f932b](https://github.com/andrewferrier/debugprint.nvim/commit/e1f932b4bdfe444c0c6fd2d1e9b3a4a4adbcc166))
* Add support for C/C++/Rust - closes [#8](https://github.com/andrewferrier/debugprint.nvim/issues/8) ([8c58a7d](https://github.com/andrewferrier/debugprint.nvim/commit/8c58a7d4bb00c58b3e4ddbfef34bfef4e001148c))
* Add support for C# ([002318e](https://github.com/andrewferrier/debugprint.nvim/commit/002318e07225773a514de41ab7840727b4b62eeb))
* Add support for golang ([3bd0110](https://github.com/andrewferrier/debugprint.nvim/commit/3bd0110ed8cb84a2e1a3c40c016c043058afc32b))
* Add support for Java ([c5e875f](https://github.com/andrewferrier/debugprint.nvim/commit/c5e875f701def6130371f344edaa580170b20d01))
* Add support for Makefiles ([317197a](https://github.com/andrewferrier/debugprint.nvim/commit/317197a9a9feacf03f840747489c8b9356d0d75d))
* Add support for PHP ([4ac6e97](https://github.com/andrewferrier/debugprint.nvim/commit/4ac6e979e68217e82c92596480cc7d62b106a3db))
* Add support for Python ([f8ebf7c](https://github.com/andrewferrier/debugprint.nvim/commit/f8ebf7c455f925df7cc83a9408841f5156a60a8d))
* Add support for ruby ([d7381f9](https://github.com/andrewferrier/debugprint.nvim/commit/d7381f97fa5c492691e35d7d145d2da86f937eb9))
* Add support for shell ([5501c0d](https://github.com/andrewferrier/debugprint.nvim/commit/5501c0d1648e59c6848b9e7d3a062da2f4e8ee19))
* Change all 'dq' keymappings to 'g?' ([a8900d7](https://github.com/andrewferrier/debugprint.nvim/commit/a8900d7fcc7a639968654c711492340e0af93f6f))
* **filetypes:** add dart support ([4e79853](https://github.com/andrewferrier/debugprint.nvim/commit/4e798533dea5805fd96f6890082105400eea309f))
* First commit ([7727353](https://github.com/andrewferrier/debugprint.nvim/commit/7727353b047c114e1d22d3f210a0d0ceb66276e8))
* Include snippets - closes [#33](https://github.com/andrewferrier/debugprint.nvim/issues/33) ([ffaaee1](https://github.com/andrewferrier/debugprint.nvim/commit/ffaaee1d8863ab6aa5e032d4f57136396e653d78))
* Introduce 'print_tag' - closes [#4](https://github.com/andrewferrier/debugprint.nvim/issues/4), [#15](https://github.com/andrewferrier/debugprint.nvim/issues/15) ([9716266](https://github.com/andrewferrier/debugprint.nvim/commit/97162667cbbe388d050037bf8be3a8cb93b30220))
* Make moving to inserted line optional ([8c31df6](https://github.com/andrewferrier/debugprint.nvim/commit/8c31df616aedc3442f92faed67e227340a5439ce))
* Move counter to the beginning ([4d49972](https://github.com/andrewferrier/debugprint.nvim/commit/4d49972a7dd60ca727b8b1ead44d29e4eb292ef5))
* Now prints to stderr by default ([7c3a43c](https://github.com/andrewferrier/debugprint.nvim/commit/7c3a43cf18d955fe2bca3811cb3e80b9b79e7f78))
* Pick up variable under cursor - closes [#2](https://github.com/andrewferrier/debugprint.nvim/issues/2) ([9a6aaa9](https://github.com/andrewferrier/debugprint.nvim/commit/9a6aaa9980bbbadb0f64970a9b8b402e15ad3aee))
* Support command for deleting lines - closes [#14](https://github.com/andrewferrier/debugprint.nvim/issues/14) ([1896124](https://github.com/andrewferrier/debugprint.nvim/commit/18961241133c328497edc4e0191463c3bc35c7ad))
* Support dot-repeat - closes [#3](https://github.com/andrewferrier/debugprint.nvim/issues/3) ([7048b21](https://github.com/andrewferrier/debugprint.nvim/commit/7048b2122ef2e0112164db878c3915d10398a0b5))
* Support motion mode - closes [#23](https://github.com/andrewferrier/debugprint.nvim/issues/23) ([5f628f5](https://github.com/andrewferrier/debugprint.nvim/commit/5f628f5624e86645149a14e858c5354b0bd599c8))
* Support variable insertion - closes [#1](https://github.com/andrewferrier/debugprint.nvim/issues/1) ([b843178](https://github.com/andrewferrier/debugprint.nvim/commit/b84317886123055a1567cc691d98cf0dc33f7c74))
* Support visual keymapping - closes [#22](https://github.com/andrewferrier/debugprint.nvim/issues/22) ([8116969](https://github.com/andrewferrier/debugprint.nvim/commit/8116969b41abca1f2447b5c19199a08a2fbc3be9))
* Try release-please ([cb7cf19](https://github.com/andrewferrier/debugprint.nvim/commit/cb7cf19d0fc0c007d2b68d10ef74038945e2fe88))
* Try to support 0.6.1 ([fe2ff7a](https://github.com/andrewferrier/debugprint.nvim/commit/fe2ff7a61c054681bbbe740c907e01c06778be60))


### Bug Fixes

* Abort testing if treesitter not available ([5ade616](https://github.com/andrewferrier/debugprint.nvim/commit/5ade616b401e4d34db5e25c283676d588acc06e5))
* Add .stylua.toml ([6db4985](https://github.com/andrewferrier/debugprint.nvim/commit/6db4985264aeb616a1feb031a97e51f1c2f7bd5a))
* Add missing 'jobs' ([abeb5e7](https://github.com/andrewferrier/debugprint.nvim/commit/abeb5e74f197d20645678e044d670ab424137b94))
* Add missing newlines - closes [#50](https://github.com/andrewferrier/debugprint.nvim/issues/50) ([807793c](https://github.com/andrewferrier/debugprint.nvim/commit/807793c7dc0104e236fdeb6996c128e79aa763ff))
* Add missing validation ([72b1ba7](https://github.com/andrewferrier/debugprint.nvim/commit/72b1ba7fb6242426cd781d0175a064abdb4a00df))
* Add missing validation ([bcc1ac8](https://github.com/andrewferrier/debugprint.nvim/commit/bcc1ac88eb00e3c9d2f86ef9d4c63b0033359441))
* Add missing validation rules ([238dc89](https://github.com/andrewferrier/debugprint.nvim/commit/238dc891bbd4a7a897d683a8ac89bb676d0eaaa6))
* Add runtime call ([49f3e2c](https://github.com/andrewferrier/debugprint.nvim/commit/49f3e2cc30a24a32258a695d0dfc95d89bf7aaec))
* Broken xs ([7949d4e](https://github.com/andrewferrier/debugprint.nvim/commit/7949d4efebc90c860e2c887e0cec1fe3f38ebd57))
* By default, indent Makefile lines with a tab ([c529cbc](https://github.com/andrewferrier/debugprint.nvim/commit/c529cbc8d7cb2c2afe50a3bfa69fa423e1b8d9a4))
* Check filetype before prompt for variable ([acd90b4](https://github.com/andrewferrier/debugprint.nvim/commit/acd90b436ec8a67161c5432bf633685b419a2b85))
* Code snippet in README.md ([784fef0](https://github.com/andrewferrier/debugprint.nvim/commit/784fef05ed6436be039286d5b496febe688a3fa8))
* Correct leading space calculation ([0086efa](https://github.com/andrewferrier/debugprint.nvim/commit/0086efaed7b7eb999b854924b9b0d6c4d4bb9389))
* Deprecated vim.treesitter.query.get_node_text ([1c63f65](https://github.com/andrewferrier/debugprint.nvim/commit/1c63f65ab34fa8a59ec184211d527c17677c8cb1))
* Explicitly add treesitter for testing ([1474cae](https://github.com/andrewferrier/debugprint.nvim/commit/1474cae7de1ba6d51d34ac665e1c709e9b766f81))
* Feed surplus &lt;CR&gt; to make tests work ([2edc44f](https://github.com/andrewferrier/debugprint.nvim/commit/2edc44f5192ba9715076fd981686bd7b61a5352b))
* Handle no variable name ([48d5f39](https://github.com/andrewferrier/debugprint.nvim/commit/48d5f39f96fc28fecd46d4e16000d36670509aa5))
* Handle not finding node ([d4e4355](https://github.com/andrewferrier/debugprint.nvim/commit/d4e4355e6ba1ee9c2f2539fc5ae68857037251c5))
* Ignore any generated tags ([c1e1799](https://github.com/andrewferrier/debugprint.nvim/commit/c1e1799c0415331b39bf17f75db63beca849eec5))
* Inaccuracy in C# support ([7017ca6](https://github.com/andrewferrier/debugprint.nvim/commit/7017ca637402521acc4077b09462aa081d0c84fe))
* Incorrect lua syntax in test files ([7f63cc5](https://github.com/andrewferrier/debugprint.nvim/commit/7f63cc53c6e5632841e5afeb74d4710748bd248e))
* Indent line correctly - closes [#6](https://github.com/andrewferrier/debugprint.nvim/issues/6) ([3ae60ba](https://github.com/andrewferrier/debugprint.nvim/commit/3ae60bab16680231254ade067427e34a50270b39))
* Install lua treesitter parser ([9e13c44](https://github.com/andrewferrier/debugprint.nvim/commit/9e13c445c6f1932d34730b414933828428c9ff01))
* Missed markup ([6a7281d](https://github.com/andrewferrier/debugprint.nvim/commit/6a7281d8a583dbc4a94ee3a4edf3b9ba10af1124))
* Red doesn't work on GitHub ([41f4809](https://github.com/andrewferrier/debugprint.nvim/commit/41f4809711ccfc1e0b6c2cf565bae15173793260))
* Remove accidental duplicate ([6f55f22](https://github.com/andrewferrier/debugprint.nvim/commit/6f55f225751e559eff858cd22c55a31f6684701b))
* Remove more characters from generated sample ([22bb8f0](https://github.com/andrewferrier/debugprint.nvim/commit/22bb8f03f153d385a48155075b020240be26a089))
* Require NeoVim 0.8+ ([e182774](https://github.com/andrewferrier/debugprint.nvim/commit/e1827741b7b8937c4d71fd9b0a7233b94e1a62b2))
* Silence vim.notify warnings ([c373014](https://github.com/andrewferrier/debugprint.nvim/commit/c37301425f5444921a31e9fd3b30d0ce13a104d3))
* Support variables in sh ([c8b644c](https://github.com/andrewferrier/debugprint.nvim/commit/c8b644c012125f010192271def6f3feb8cd890ef))
* Test relied on not clearing buffer ([77f5131](https://github.com/andrewferrier/debugprint.nvim/commit/77f51315d7585a40750265c6dd2b75635ca75f99))
* Tests after merging stderr change ([8e93ab9](https://github.com/andrewferrier/debugprint.nvim/commit/8e93ab97ba3f4a3ee733349bdfa9089f96003e23))
* Treesitter directory ([89e2a73](https://github.com/andrewferrier/debugprint.nvim/commit/89e2a730b5227af138b88f5e2be5113de028970f))
* Try different syntax ([5877206](https://github.com/andrewferrier/debugprint.nvim/commit/5877206a1f08ebfc3f4efc976f39a5b5bd22eb3e))
* Try loading treesitter in minimal.vim ([f097ee8](https://github.com/andrewferrier/debugprint.nvim/commit/f097ee8f165fade0ce04982d4caf5d9ffdae9b06))
* Try packadd ([2bec88b](https://github.com/andrewferrier/debugprint.nvim/commit/2bec88b13f6d4854065ee4326409e8dad14e532e))
* Unknown filetypes ([b22480e](https://github.com/andrewferrier/debugprint.nvim/commit/b22480e7a5de281d620a399fef70649050e389bd))
* Update to NeoVim 0.7.2 ([706127f](https://github.com/andrewferrier/debugprint.nvim/commit/706127fd32a5a7c072fcd841763b998ace586b43))
* Use dynamic filename ([91e5ccd](https://github.com/andrewferrier/debugprint.nvim/commit/91e5ccd37f6124618af026b46f1a068eb6954db5))
* Version of stylua check ([5b52d8f](https://github.com/andrewferrier/debugprint.nvim/commit/5b52d8f1e2a173322c537156b9b2f127c73071ee))


### Performance Improvements

* Combine g?v, g?V keys ([d18401e](https://github.com/andrewferrier/debugprint.nvim/commit/d18401ef50cf1ecadcd520c87b085b633214aeb6))
