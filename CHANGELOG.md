# Changelog

## [1.2.0](https://github.com/johmsalas/text-case.nvim/compare/v1.1.0...v1.2.0) (2024-02-23)


### Features

* Add start_replacing_command_with_first_part ([0b0afd6](https://github.com/johmsalas/text-case.nvim/commit/0b0afd658abb1a393f7eb103cac75774ed6b0f55))
* **VSCode:** Open the Command Palette instead of Telescope ([#140](https://github.com/johmsalas/text-case.nvim/issues/140)) ([d6f121e](https://github.com/johmsalas/text-case.nvim/commit/d6f121ec471118afb4fc7ed8cafb08eef3e9b307))


### Bug Fixes

* **docs:** Update LazyVim config - lazy loading commands ([f4735e2](https://github.com/johmsalas/text-case.nvim/commit/f4735e218bfc8330a84041b058833c5de8b3c8c1))
* **docs:** Updates LazyVim example setup to lazy load on all default invocations ([#155](https://github.com/johmsalas/text-case.nvim/issues/155)) ([6bc91cd](https://github.com/johmsalas/text-case.nvim/commit/6bc91cde614bbec6f0befbaf7fcd302415d803fb))
* don't create select mode mappings ([5d85b74](https://github.com/johmsalas/text-case.nvim/commit/5d85b7495c3cf8e842e4d2528edc68e6fe7c92c8))
* Error when passing an empty string via API methods ([#146](https://github.com/johmsalas/text-case.nvim/issues/146)) ([51fba4b](https://github.com/johmsalas/text-case.nvim/commit/51fba4b76ff39e2a3264a7201be3c9310cfcdb58))
* **subs:** Avoid modifying a match that has already been altered. ([#147](https://github.com/johmsalas/text-case.nvim/issues/147)) ([b812d89](https://github.com/johmsalas/text-case.nvim/commit/b812d890220bf9df358df3a5683b171b46d29c75))

## [1.1.0](https://github.com/johmsalas/text-case.nvim/compare/v1.0.0...v1.1.0) (2023-12-20)


### Features

* **Subs:** adjustable name for substitude command ([25f965c](https://github.com/johmsalas/text-case.nvim/commit/25f965c9a6f440b1a9f4cfb6388257f227945652))

## 1.0.0 (2023-12-18)


### Features

* Add description to keymaps and WhichKey ([#8](https://github.com/johmsalas/text-case.nvim/issues/8)) ([576e774](https://github.com/johmsalas/text-case.nvim/commit/576e774133f1a0687b0aa76424124d5eb068cf83))
* Add WhichKey name for keybindings && removed calling setup as a hard requirement ([b3410fe](https://github.com/johmsalas/text-case.nvim/commit/b3410fe57425b47fd6dd3c2c63f7ca068e290081))
* Improve unicode casing ([70272ff](https://github.com/johmsalas/text-case.nvim/commit/70272ff3b4fe13ee6bdadfea63f329a2103a4ba9))
* Incremental substitution ([533d91a](https://github.com/johmsalas/text-case.nvim/commit/533d91a2bcd3577329208fa25e609e48b30e42ae))
* LSP rename converts next word if located in a non word character ([#114](https://github.com/johmsalas/text-case.nvim/issues/114)) ([2567488](https://github.com/johmsalas/text-case.nvim/commit/25674885329142c3a56d302ff33abf6c4131d893))
* Notify when LSP renaming failed ([#60](https://github.com/johmsalas/text-case.nvim/issues/60)) ([21ee7f8](https://github.com/johmsalas/text-case.nvim/commit/21ee7f8536488d41667995b0b22aaef4839fd28a))
* Provide command to trigger bulk replacement ([54e3d9d](https://github.com/johmsalas/text-case.nvim/commit/54e3d9dd4023283dc598aecc0fae7182324fb41c))
* Provide default picker in telescope extension ([487b75c](https://github.com/johmsalas/text-case.nvim/commit/487b75ce879fb8296263f806a8294afd1784fba3))
* Use option enabled_methods for Telescope ([985b7de](https://github.com/johmsalas/text-case.nvim/commit/985b7dec435c34145e011c4d776af82a93aedee6))


### Bug Fixes

* buf_request_all test ([9ea38f0](https://github.com/johmsalas/text-case.nvim/commit/9ea38f02be53a013713a10a8736affe33ac6386a))
* Correct documentation for LazyVim ([#121](https://github.com/johmsalas/text-case.nvim/issues/121)) ([b25eee2](https://github.com/johmsalas/text-case.nvim/commit/b25eee29b7dcca43b52f24ac66f2b40e698833cd))
* Ignore unicode chars with more than 2 bytes ([4fd525e](https://github.com/johmsalas/text-case.nvim/commit/4fd525ed89939d4713855885f7e4bb275ce023bd))
* **LSP:** Apply changes from the language server that touches the most files ([1f981c3](https://github.com/johmsalas/text-case.nvim/commit/1f981c3df09ecca101d9384bb85d6c1d1d988430))
* non-alphabetical characters are removed ([#46](https://github.com/johmsalas/text-case.nvim/issues/46)) ([ed83149](https://github.com/johmsalas/text-case.nvim/commit/ed8314943ebc55521a3cb2751f446615e00c0dbc))
* Some Subs test cases were not executed ([d1ef3c0](https://github.com/johmsalas/text-case.nvim/commit/d1ef3c0a52eeb0126c8fc5410fd0af69a3abe31e))
* **Subs:** Allow to select a part of a single line ([bf08365](https://github.com/johmsalas/text-case.nvim/commit/bf08365c222b58d080879b97229f816dec163812))
* **Subs:** distinguish visual block mode and visual line mode ([#118](https://github.com/johmsalas/text-case.nvim/issues/118)) ([fe04c80](https://github.com/johmsalas/text-case.nvim/commit/fe04c80c6d2f65b86166170e7d304e5b9811ef89))
* **Subs:** Make sure Subs command only changes text in visual range ([9904f58](https://github.com/johmsalas/text-case.nvim/commit/9904f5826d49ecf2fd75857949922ad66b83e925))
* visual block selection with Telescope ([7a64758](https://github.com/johmsalas/text-case.nvim/commit/7a6475884c26eabaf0658e0c6910ce71d062c937))


### Reverts

* undo previous commit (fix [#40](https://github.com/johmsalas/text-case.nvim/issues/40)) ([#41](https://github.com/johmsalas/text-case.nvim/issues/41)) ([cd7cc65](https://github.com/johmsalas/text-case.nvim/commit/cd7cc65a412beb713e68f3b84e45990a939b7b6b))
