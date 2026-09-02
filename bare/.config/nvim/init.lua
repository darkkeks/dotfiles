-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Enable line numbers and disable wrapping
vim.o.number = true
vim.o.wrap = false

-- Always use 4 spaces for indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.expandtab = true

-- Cursor shape restoration on neovim enter/resume and suspend/exit
vim.api.nvim_create_autocmd({"VimEnter", "VimResume"}, {
  callback = function(ev)
    vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
  end
})
vim.api.nvim_create_autocmd({"VimLeave", "VimSuspend"}, {
  callback = function(ev)
    vim.o.guicursor = 'a:hor25'
  end
})

-- Copy to system buffer
vim.keymap.set('n', '<leader>Y', '<Cmd>:%y*<CR>', {})

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "catppuccin/nvim",
      priority = 1000,
      config = function()
        vim.cmd("colorscheme catppuccin")
      end
    },
    {
      'nvim-telescope/telescope.nvim', branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        -- Default telescope keybinds
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "java",
            "kotlin",
            "python",
          },
          highlight = { enable = true },
        })
      end
    },
    {
      'neovim/nvim-lspconfig',
      config = function()
        require('lspconfig').pyright.setup({})
        require('lspconfig').clangd.setup({})

        -- Defaults from kickstart.nvim.
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
          callback = function(event)
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end
            map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
            map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
            map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
            map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          end,
        })
      end
    },

    { -- Autocompletion
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        {
          'L3MON4D3/LuaSnip',
        --   build = (function()
        --     -- Build Step is needed for regex support in snippets.
        --     -- This step is not supported in many windows environments.
        --     -- Remove the below condition to re-enable on windows.
        --     if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
        --       return
        --     end
        --     return 'make install_jsregexp'
        --   end)(),
        --   dependencies = {
        --     -- `friendly-snippets` contains a variety of premade snippets.
        --     --    See the README about individual language/framework/plugin snippets:
        --     --    https://github.com/rafamadriz/friendly-snippets
        --     -- {
        --     --   'rafamadriz/friendly-snippets',
        --     --   config = function()
        --     --     require('luasnip.loaders.from_vscode').lazy_load()
        --     --   end,
        --     -- },
        --   },
        },
        'saadparwaiz1/cmp_luasnip',

        -- Adds other completion capabilities.
        --  nvim-cmp does not ship with all sources by default. They are split
        --  into multiple repos for maintenance purposes.
        'hrsh7th/cmp-nvim-lsp',
        -- 'hrsh7th/cmp-path',
      },
      config = function()
        -- See `:help cmp`
        local cmp = require 'cmp'

        -- Setup luanip.
        local luasnip = require 'luasnip'
        luasnip.config.setup {}

        require("luasnip.loaders.from_snipmate").lazy_load()

        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          -- completion = { completeopt = 'menu,menuone,noinsert' },

          -- For an understanding of why these mappings were
          -- chosen, you will need to read `:help ins-completion`
          --
          -- No, but seriously. Please read `:help ins-completion`, it is really good!
          mapping = cmp.mapping.preset.insert {
            -- Select the [n]ext item
            ['<C-n>'] = cmp.mapping.select_next_item(),
            -- Select the [p]revious item
            ['<C-p>'] = cmp.mapping.select_prev_item(),

            -- Scroll the documentation window [b]ack / [f]orward
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),

            -- Accept ([y]es) the completion.
            --  This will auto-import if your LSP supports it.
            --  This will expand snippets if the LSP sent a snippet.
            ['<C-y>'] = cmp.mapping.confirm { select = true },

            -- If you prefer more traditional completion keymaps,
            -- you can uncomment the following lines
            --['<CR>'] = cmp.mapping.confirm { select = true },
            --['<Tab>'] = cmp.mapping.select_next_item(),
            --['<S-Tab>'] = cmp.mapping.select_prev_item(),

            -- Manually trigger a completion from nvim-cmp.
            --  Generally you don't need this, because nvim-cmp will display
            --  completions whenever it has completion options available.
            ['<C-Space>'] = cmp.mapping.complete {},

            -- Think of <c-l> as moving to the right of your snippet expansion.
            --  So if you have a snippet that's like:
            --  function $name($args)
            --    $body
            --  end
            --
            -- <c-l> will move you to the right of each of the expansion locations.
            -- <c-h> is similar, except moving you backwards.
            -- ['<C-l>'] = cmp.mapping(function()
            --   if luasnip.expand_or_locally_jumpable() then
            --     luasnip.expand_or_jump()
            --   end
            -- end, { 'i', 's' }),
            -- ['<C-h>'] = cmp.mapping(function()
            --   if luasnip.locally_jumpable(-1) then
            --     luasnip.jump(-1)
            --   end
            -- end, { 'i', 's' }),

            -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
          },
          sources = {
            -- {
            --   name = 'lazydev',
            --   -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            --   group_index = 0,
            -- },
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
          },
        }
      end,
    },
  },
})
