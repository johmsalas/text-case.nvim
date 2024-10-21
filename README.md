# text-case.nvim

An all in one plugin for converting text case in Neovim.
It converts a piece of text to an indicated string case and also is capable of bulk replacing content inside texts without changing the case.

![CI/CD](https://github.com/johmsalas/text-case.nvim/actions/workflows/ci.yml/badge.svg?branch=main)
![Tests Neovim Nightly](https://github.com/johmsalas/text-case.nvim/actions/workflows/neovim-nightly.yml/badge.svg?branch=main)

This plugin runs its tests against the following versions of Neovim:

| Neovim version | Remarks                                                                                                |
| -------------- | ------------------------------------------------------------------------------------------------------ |
| `0.10.0`       | All features work                                                                                      |
| `0.9.4`        | All features work                                                                                      |
| `0.8.3`        | The Telescope extension is not working because Telescope itself requires at least Neovim version 0.9.0 |

Note this plugin is oriented towards code and the cases used for tokens in programming languages.
If you are looking for title-case or others as used in natural language prose there are contextual grammar considerations not covered here.
Consider the [decasify](https://github.com/alerque/decasify) plugin for locale and style-guide aware casing functions.

## Features

### Quick conversion

Converts text under cursor to another case. Only 3 keys to convert the current text.
<sub>Repeatable using `.`</sub>

Smartly guesses the current object using the following strategies:

- Tree Sitter (if available) [WIP]
- Word under cursor
- Ignore word separators

### LSP conversion

Converts definition under cursor to another case. Use Language Server Protocol to modify the definition, references and usages of the word under cursor
<sub>Repeatable using `.`</sub>

### Targeted conversion

Converts given objects, it might require more key presses than the quick conversion but allows to control the specific target.
<sub>Repeatable using `.`</sub>

Supported targets:

- Vim objects: w, iw, aw, e, p, ...
- Selected text in visual mode

### Bulk smart replacement

Converts all forms of a specific text, the replaced text will keep the original text case.

If not specified, it replaces every instance of the text in the current file; But it could be also scoped to the selected block:

![animation: Bulk Replacement](screens/bulk-change-case-visual-block.gif)

### String case conversions

It is also a library of text case conversion methods. Useful for your LUA code.

| Case            | Example     | Method                          |
| --------------- | ----------- | ------------------------------- |
| Upper case      | LOREM IPSUM | textcase.api.to_constant_case   |
| Lower case      | lorem ipsum | textcase.api.to_lower_case      |
| Snake case      | lorem_ipsum | textcase.api.to_snake_case      |
| Dash case       | lorem-ipsum | textcase.api.to_dash_case       |
| Title Dash case | Lorem-Ipsum | textcase.api.to_title_dash_case |
| Constant case   | LOREM_IPSUM | textcase.api.to_constant_case   |
| Dot case        | lorem.ipsum | textcase.api.to_dot_case        |
| Comma case      | lorem,ipsum | textcase.api.to_comma_case      |
| Camel case      | loremIpsum  | textcase.api.to_camel_case      |
| Pascal case     | LoremIpsum  | textcase.api.to_pascal_case     |
| Title case      | Lorem Ipsum | textcase.api.to_title_case      |
| Path case       | lorem/ipsum | textcase.api.to_path_case       |
| Phrase case     | Lorem ipsum | textcase.api.to_phrase_case     |

### Character compatibility

It is possible to transform the letter case of the latin alphabet (`[a-z]`) as well as the special characters related to the latin alphabet (e.g. `á = Á` or `ö` => `Ö`).

## Setup

Install with your favorite plugin manager.

### Example in LUA using Packer.nvim with default options

```lua
use { "johmsalas/text-case.nvim",
  config = function()
    require('textcase').setup {}
  end
}
```

### Example for LazyVim

```lua
{
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("textcase").setup({})
    require("telescope").load_extension("textcase")
  end,
  keys = {
    "ga", -- Default invocation prefix
    { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
  },
  cmd = {
    -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
    "Subs",
    "TextCaseOpenTelescope",
    "TextCaseOpenTelescopeQuickChange",
    "TextCaseOpenTelescopeLSPChange",
    "TextCaseStartReplacingCommand",
  },
  -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
  -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
  -- available after the first executing of it or after a keymap of text-case.nvim has been used.
  lazy = false,
}
```

### All options with their default value

```lua
{
  -- Set `default_keymappings_enabled` to false if you don't want automatic keymappings to be registered.
  default_keymappings_enabled = true,
  -- `prefix` is only considered if `default_keymappings_enabled` is true. It configures the prefix
  -- of the keymappings, e.g. `gau ` executes the `current_word` method with `to_upper_case`
  -- and `gaou` executes the `operator` method with `to_upper_case`.
  prefix = "ga",
  -- If `substitude_command_name` is not nil, an additional command with the passed in name
  -- will be created that does the same thing as "Subs" does.
  substitude_command_name = nil,
  -- By default, all methods are enabled. If you set this option with some methods omitted,
  -- these methods will not be registered in the default keymappings. The methods will still
  -- be accessible when calling the exact lua function e.g.:
  -- "<CMD>lua require('textcase').current_word('to_snake_case')<CR>"
  enabled_methods = {
    "to_upper_case",
    "to_lower_case",
    "to_snake_case",
    "to_dash_case",
    "to_title_dash_case",
    "to_constant_case",
    "to_dot_case",
    "to_comma_case",
    "to_phrase_case",
    "to_camel_case",
    "to_pascal_case",
    "to_title_case",
    "to_path_case",
    "to_upper_phrase_case",
    "to_lower_phrase_case",
  },
}
```

### Example in VimScript using Plug with custom keybindings

```vimscript
call plug#begin('~/.local/share/nvim/plugged')
Plug 'johmsalas/text-case.nvim'
call plug#end()

-- Example of custom keymapping
nnoremap gau :lua require('textcase').current_word('to_upper_case')<CR>
nnoremap gal :lua require('textcase').current_word('to_lower_case')<CR>
nnoremap gas :lua require('textcase').current_word('to_snake_case')<CR>
nnoremap gad :lua require('textcase').current_word('to_dash_case')<CR>
nnoremap gan :lua require('textcase').current_word('to_constant_case')<CR>
nnoremap gad :lua require('textcase').current_word('to_dot_case')<CR>
nnoremap ga, :lua require('textcase').current_word('to_comma_case')<CR>
nnoremap gaa :lua require('textcase').current_word('to_phrase_case')<CR>
nnoremap gac :lua require('textcase').current_word('to_camel_case')<CR>
nnoremap gap :lua require('textcase').current_word('to_pascal_case')<CR>
nnoremap gat :lua require('textcase').current_word('to_title_case')<CR>
nnoremap gaf :lua require('textcase').current_word('to_path_case')<CR>

nnoremap gaU :lua require('textcase').lsp_rename('to_upper_case')<CR>
nnoremap gaL :lua require('textcase').lsp_rename('to_lower_case')<CR>
nnoremap gaS :lua require('textcase').lsp_rename('to_snake_case')<CR>
nnoremap gaD :lua require('textcase').lsp_rename('to_dash_case')<CR>
nnoremap gaN :lua require('textcase').lsp_rename('to_constant_case')<CR>
nnoremap gaD :lua require('textcase').lsp_rename('to_dot_case')<CR>
nnoremap ga, :lua require('textcase').lsp_rename('to_comma_case')<CR>
nnoremap gaA :lua require('textcase').lsp_rename('to_phrase_case')<CR>
nnoremap gaC :lua require('textcase').lsp_rename('to_camel_case')<CR>
nnoremap gaP :lua require('textcase').lsp_rename('to_pascal_case')<CR>
nnoremap gaT :lua require('textcase').lsp_rename('to_title_case')<CR>
nnoremap gaF :lua require('textcase').lsp_rename('to_path_case')<CR>

nnoremap geu :lua require('textcase').operator('to_upper_case')<CR>
nnoremap gel :lua require('textcase').operator('to_lower_case')<CR>
nnoremap ges :lua require('textcase').operator('to_snake_case')<CR>
nnoremap ged :lua require('textcase').operator('to_dash_case')<CR>
nnoremap gen :lua require('textcase').operator('to_constant_case')<CR>
nnoremap ged :lua require('textcase').operator('to_dot_case')<CR>
nnoremap ge, :lua require('textcase').operator('to_comma_case')<CR>
nnoremap gea :lua require('textcase').operator('to_phrase_case')<CR>
nnoremap gec :lua require('textcase').operator('to_camel_case')<CR>
nnoremap gep :lua require('textcase').operator('to_pascal_case')<CR>
nnoremap get :lua require('textcase').operator('to_title_case')<CR>
nnoremap gef :lua require('textcase').operator('to_path_case')<CR>
```

## How to use it

[Visit the wiki](https://github.com/johmsalas/text-case.nvim/wiki)

## Integrations

### Telescope integration

To list conversion options using Telescope, register the extension in telescope and setup keybindings for normal and visual mode

```lua
config = function()
  require('textcase').setup {}
  require('telescope').load_extension('textcase')
  vim.api.nvim_set_keymap('n', 'ga.', '<cmd>TextCaseOpenTelescope<CR>', { desc = "Telescope" })
  vim.api.nvim_set_keymap('v', 'ga.', "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
end
```

In the example above, when using in normal mode, it shows options for quick and LSP conversion of the string. It is also possible to trigger a list of options only for Quick Conversion, or only for LSP conversion
It only works for normal mode, because LSP does not make sense for visual mode

```
vim.api.nvim_set_keymap('n', 'gaa', "<cmd>TextCaseOpenTelescopeQuickChange<CR>", { desc = "Telescope Quick Change" })
vim.api.nvim_set_keymap('n', 'gai', "<cmd>TextCaseOpenTelescopeLSPChange<CR>", { desc = "Telescope LSP Change" })
```

### Which key integration

If which-key is preset, text-case.nvim registers descriptions for the conversion groups

![screenshot: which-key menu](screens/whichkey.png)

## Troubleshooting

- Conversion based on LSP not working

A requirement for LSP rename to work is to have LSP set in the buffer and the Language Server should have the rename capability enabled.

To triage it, trigger LSP renaming using `:lua vim.lsp.buf.rename()` while the cursor is on the symbol. If it works, file an issue on this plugin

## Development

Useful commands are defined in the [`Justfile`](Justfile) and can be listed with [`just`](https://github.com/casey/just).

### Required packages to run tests

```console
npm install -g typescript-language-server typescript
```

### Testing with Neotest

The test runs executed in [`tests/run.sh`](tests/run.sh) work via different environments defined in the folder [`tests/environments`](tests/environments). This is not compatible with the default [Neotest setup](https://github.com/nvim-neotest/neotest-plenary#minimal-initlua) though, because it will look for a `tests/minimal_init.lua` file. Hence, there is a universal [`tests/minimal_init.lua` file](tests/minimal_init.lua) that is just used for running tests with Neotest and that contains the setup of all environments combined. Neotest enables us to run single tests easily.
