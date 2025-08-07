-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        "   /$$                                     /$$                         /$$",
        "  | $$                                    | $$                        | $$",
        " /$$$$$$    /$$$$$$  /$$$$$$$  /$$   /$$ /$$$$$$    /$$$$$$   /$$$$$$$| $$$$$$$",
        "|_  $$_/   /$$__  $$| $$__  $$| $$  | $$|_  $$_/   /$$__  $$ /$$_____/| $$__  $$",
        "  | $$    | $$  \\ $$| $$  \\ $$| $$  | $$  | $$    | $$$$$$$$| $$      | $$  \\ $$",
        "  | $$ /$$| $$  | $$| $$  | $$| $$  | $$  | $$ /$$| $$_____/| $$      | $$  | $$",
        "  |  $$$$/|  $$$$$$/| $$  | $$|  $$$$$$$  |  $$$$/|  $$$$$$$|  $$$$$$$| $$  | $$",
        "   \\___/   \\______/ |__/  |__/ \\____  $$   \\___/   \\_______/ \\_______/|__/  |__/",
        "                               /$$  | $$",
        "                              |  $$$$$$/",
        "                               \\______/",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  -- === ADD NOE-TREE.NVIM PLUGIN CONFIGURATION HERE ===
  -- Neo-tree is now file explorer
  -- Hidden files are always visible
  -- Shortcut <C-n> opens the file explorer on the left
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      require("neo-tree").setup {
        filesystem = {
          filtered_items = {
            visible = true,
            show_hidden_count = true,
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_by_name = {
              -- add extension names you want to explicitly exclude
              -- '.git',
              -- '.DS_Store',
              -- 'thumbs.db',
            },
            never_show = {},
          },
        },
      }
      vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
    end,
  },
}
