local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local entry_display = require "telescope.pickers.entry_display"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"

-- Copy of make_entry.gen_from_keymaps but ignore empty registries.
function gen_from_registers(opts)
  local displayer = entry_display.create {
    separator = " ",
    hl_chars = { ["["] = "TelescopeBorder", ["]"] = "TelescopeBorder" },
    items = {
      { width = 3 },
      { remaining = true },
    },
  }

  local make_display = function(entry)
    local content = entry.content
	content = string.gsub(content, "^%s+", "")
    return displayer {
      { "[" .. entry.value .. "]", "TelescopeResultsNumber" },
      type(content) == "string" and content:gsub("\n", "\\n") or content,
    }
  end

  return function(entry)
    local contents = vim.fn.getreg(entry, 1)
	if contents == "" then
			return  nil
	end
    return make_entry.set_default_entry_mt({
      value = entry,
      ordinal = string.format("%s %s", entry, contents),
      content = contents,
      display = make_display,
    }, opts)
  end
end

local previewer = previewers.new_buffer_previewer {
	title = "Registers Preview",
	dyn_title = function(_, entry)
		return entry.value
	end,
	get_buffer_by_name = function(_, entry)
		return "registers_" .. tostring(entry.value)
	end,
	define_preview = function(self, entry)
		if self.state.bufname then
			return
		end

		local content = {}
		for line in string.gmatch(entry.content .. '\n', '(.-)\n') do
			table.insert(content, line)
		end
		vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
	end,
}

return function(opts)
	local registers_table = { '"', "-", "#", "=", "/", "*", "+", ":", ".", "%" }

	-- named
	for i = 0, 9 do
		table.insert(registers_table, tostring(i))
	end

	-- alphabetical
	for i = 65, 90 do
		table.insert(registers_table, string.char(i))
	end

	opts = opts or {}
	pickers.new(opts, {
		prompt_title = "Registers",
		finder = finders.new_table {
			results = registers_table,
			entry_maker = opts.entry_maker or gen_from_registers(opts),
		},
		previewer = previewer,
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				-- print(vim.inspect(selection))
				vim.api.nvim_put({ selection[1] }, "", false, true)
			end)
			return true
		end,
	}):find()
end

-- to execute the function
-- colors(require("telescope.themes").get_dropdown{})
