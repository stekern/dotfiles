return {
  { -- Configures Lua LSP for Neovim config, runtime and plugins
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim.
      -- Mason must be loaded before its dependents so we set it up here.
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- winblend=0 prevents fidget bg from clashing with our transparent Normal bg (see ui.lua)
      { 'j-hui/fidget.nvim', opts = vim.env.TMUX and { notification = { window = { winblend = 0, normal_hl = 'Comment' } } } or {} },
      'hrsh7th/cmp-nvim-lsp', -- Extra LSP capabilities for nvim-cmp
    },
    config = function()
      -- Runs when an LSP attaches to a buffer (i.e., when you open a file
      -- that has an associated language server).
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Highlight references of the word under cursor when it rests there.
          -- See `:help CursorHold`
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          -- Disable ruff hover in favor of Pyright
          if client and client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          end

          -- Disable semantic tokens for terraform-ls: it overrides treesitter
          -- in ways that reduce clarity (e.g. resource names shown as constants
          -- instead of strings, `resource` keyword shown as type).
          if client and client.name == 'terraformls' then
            client.server_capabilities.semanticTokensProvider = nil
            vim.lsp.semantic_tokens.stop(event.buf, client.id)
          end
        end,
      })

      -- Broadcast additional capabilities from nvim-cmp to all LSP servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Add/remove LSPs here. They will be automatically installed via Mason.
      -- See `:help lspconfig-all` for a list of all pre-configured LSPs.
      local servers = {
        jsonls = {
          settings = {
            json = { validate = { enable = true } },
          },
        },
        bashls = {},
        yamlls = {
          settings = {
            yaml = {
              completion = true,
              hover = true,
              validate = true,
              schemaStore = { enable = false, url = '' },
              schemas = {
                ['https://json.schemastore.org/pulumi.json'] = 'Pulumi.{yml,yaml}',
                ['https://json.schemastore.org/renovate.json'] = 'renovate.{json,json5}',
              },
            },
          },
        },
        ruff = {},
        pyright = { -- Only used for type-checking; ruff handles linting + imports
          settings = {
            pyright = { disableOrganizeImports = true }, -- Ruff handles imports
            python = { analysis = { diagnosticMode = 'off' } },
          },
        },
        ts_ls = {
          settings = {
            implicitProjectConfiguration = { checkJs = true },
          },
        },
        terraformls = {},
        gopls = {},
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
                return
              end
            end
            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file('', true),
              },
            })
          end,
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      vim.lsp.config('*', { capabilities = capabilities })
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
      end

      require('mason-lspconfig').setup {
        -- Disable copilot when no active subscription to avoid annoying popup
        automatic_enable = { exclude = { 'copilot' } },
      }
    end,
  },
}
