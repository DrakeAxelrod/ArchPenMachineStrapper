-- vim settings
vim.o.cmdheight = 1
-- general lvim settings
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
lvim.leader = "space"
-- builtin plugin settings
lvim.builtin.alpha.active = true
-- lvim.builtin.alpha.mode = "dashboard"
-- lvim.builtin.alpha.dashboard.section.header.val = {
--   [[           _                                  _                     ]],
--   [[          | |                                (_)                    ]],
--   [[          | |    _   _ _ __   __ _ _ ____   ___ _ __ ___            ]],
--   [[          | |   | | | | '_ \ / _` | '__\ \ / / | '_ ` _ \           ]],
--   [[          | |___| |_| | | | | (_| | |   \ V /| | | | | | |          ]],
--   [[          \_____/\__,_|_| |_|\__,_|_|    \_/ |_|_| |_| |_|          ]],
--   [[      .-.      _______                           .  '  *   .  . '   ]],
--   [[     {}``; |==|_______D                                . *  -+-  .  ]],
--   [[     / ('        /|\                             . '   * .    '  *  ]],
--   [[ (  /  |        / | \                                * .  ' .  .-+- ]],
--   ([[  \(_)_%s      /  |  \                           *   *  .   .       ]]):format("]]"),
-- }
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
-- for loop require files in lua dir (order matters)
for _, mod in ipairs({
  "plugs",
  "langs",
  "binds",
  "cmds"
}) do
  require(mod)
end
