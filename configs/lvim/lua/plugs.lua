lvim.plugins = {
  { "j-hui/fidget.nvim",
    event = { "BufWinEnter", "BufRead", "BufReadPre" },
    config = function()
      fidget.setup({
        text = {
          spinner = "pipe", -- animation shown when tasks are ongoing
          done = "", -- character shown when all tasks are complete
          commenced = "Started", -- message shown when task starts
          completed = "Completed", -- message shown when task completes
        },
        align = {
          bottom = true, -- align fidgets along bottom edge of buffer
          right = true, -- align fidgets along right edge of buffer
        },
        timer = {
          spinner_rate = 125, -- frame rate of spinner animation, in ms
          fidget_decay = 2000, -- how long to keep around empty fidget, in ms
          task_decay = 1000, -- how long to keep around completed task, in ms
        },
        window = {
          relative = "win", -- where to anchor, either "win" or "editor"
          blend = 0, -- &winblend for the window
          zindex = nil, -- the zindex value for the window
        },
        fmt = {
          leftpad = true, -- right-justify text in fidget box
          stack_upwards = true, -- list of tasks grows upwards
          max_width = 0, -- maximum width of the fidget box
          -- function to format fidget title
          fidget = function(fidget_name, spinner)
            return string.format("%s %s", spinner, fidget_name)
          end,
          -- function to format each task line
          task = function(task_name, message, percentage)
            return string.format("%s%s [%s]", message, percentage and string.format(" (%s%%)", percentage) or "", task_name)
          end,
        },
        sources = { -- Sources to configure
          ["*"] = { -- Name of source
            ignore = false, -- Ignore notifications from this source
          },
        },
        debug = {
          logging = false, -- whether to enable logging, for debugging
          strict = false, -- whether to interpret LSP strictly
        },
      })
    end,
  },
  { "gelguy/wilder.nvim",
    requires = { "romgrk/fzy-lua-native" },
    config = function()
      local wilder = require("wilder")
      local accent_color = "#4aa5f0"
      wilder.setup({ modes = { ":", "/", "?" } })
      wilder.set_option("use_python_remote_plugin", 0) -- Disable Python remote plugin
      wilder.set_option("pipeline", {
        wilder.branch(
          wilder.cmdline_pipeline({
            fuzzy = 1,
            fuzzy_filter = wilder.lua_fzy_filter(),
          }),
          wilder.vim_search_pipeline()
        ),
      })
      wilder.set_option(
        "renderer",
        wilder.popupmenu_renderer({
          highlighter = wilder.lua_fzy_highlighter(),
          highlights = {
            accent = wilder.make_hl(
              "WilderAccent",
              "Pmenu",
              { { a = 1 }, { a = 1 }, { foreground = accent_color } }
            ),
          },
          left = { " ", wilder.popupmenu_devicons() },
          right = { " ", wilder.popupmenu_scrollbar() },
          pumblend = 0,
          max_height = "50%", -- max height of the palette
          min_height = 0, -- set to the same as "max_height" for a fixed height window
          prompt_position = "top", -- "top" or "bottom" to set the location of the prompt
          reverse = 0, -- set to 1 to reverse the order of the list, use in combination with "prompt_position"
        })
      )
    end,
  },
  {
    "phaazon/hop.nvim",
    branch = "v1",
    event = { "BufRead", "BufReadPre" },
    cmd = { "HopWord", "HopLine", "HopChar1" },
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    end
  },
  {
    "sudormrfbin/cheatsheet.nvim",
    config = function()
      require("cheatsheet").setup({
        -- Whether to show bundled cheatsheets
        -- For generic cheatsheets like default, unicode, nerd-fonts, etc
        -- bundled_cheatsheets = {
        --     enabled = {},
        --     disabled = {},
        -- },
        bundled_cheatsheets = true,
        -- For plugin specific cheatsheets
        -- bundled_plugin_cheatsheets = {
        --     enabled = {},
        --     disabled = {},
        -- }
        bundled_plugin_cheatsheets = true,
        -- For bundled plugin cheatsheets, do not show a sheet if you
        -- don't have the plugin installed (searches runtimepath for
        -- same directory name)
        include_only_installed_plugins = true,
        -- Key mappings bound inside the telescope window
        telescope_mappings = {
            ['<CR>'] = require('cheatsheet.telescope.actions').select_or_fill_commandline,
            ['<A-CR>'] = require('cheatsheet.telescope.actions').select_or_execute,
            ['<C-Y>'] = require('cheatsheet.telescope.actions').copy_cheat_value,
            ['<C-E>'] = require('cheatsheet.telescope.actions').edit_user_cheatsheet,
        }
    })
    end,
  }
}
