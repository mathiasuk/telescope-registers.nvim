# telescope-registers

An extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), similar to builtin.registers but with the following changes:

 * Ignore empty registers
 * Include a preview of the full registers' content, especially useful for multi-lines contents

## Setup

[Lazy](https://lazy.folke.io/):
```
{
    'mathiasuk/telescope-registers.nvim',
    config = function()
        require('telescope').load_extension('registers_preview')
    end,
    keys = {
        -- Example keymap:
        {'<leader>fc', '<cmd>Telescope registers_preview<cr>', desc='Telescope registers},
    }
}
```