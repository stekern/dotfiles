-- Both copilot and supermaven are OFF by default each session.
-- Toggle them on-demand with <leader>tc and <leader>ts.
-- The `init` function registers the keymap before the plugin loads,
-- and `cmd` makes the plugin lazy-loadable via its commands.
return {
  {
    'github/copilot.vim',
    cmd = { 'Copilot' },
    init = function()
      vim.g.toggle_copilot_enabled = false

      local function toggle()
        if not vim.g.toggle_copilot_enabled then
          require('lazy').load { plugins = { 'copilot.vim' } }
          -- Schedule to next tick so copilot.vim finishes its internal setup first
          vim.schedule(function()
            if vim.fn.exists ':Copilot' == 2 then
              vim.cmd 'Copilot enable'
            end
            vim.g.toggle_copilot_enabled = true
            vim.notify 'Copilot: enabled'
          end)
        else
          if vim.fn.exists ':Copilot' == 2 then
            vim.cmd 'Copilot disable'
          end
          vim.g.toggle_copilot_enabled = false
          vim.notify 'Copilot: disabled'
        end
      end

      vim.keymap.set('n', '<leader>tc', toggle, { desc = '[T]oggle [C]opilot', silent = true })
    end,
  },
  {
    'supermaven-inc/supermaven-nvim',
    cmd = { 'SupermavenStart', 'SupermavenStop', 'SupermavenToggle', 'SupermavenStatus' },
    init = function()
      vim.g.supermaven_enabled = false

      local function toggle()
        local ok, api = pcall(require, 'supermaven-nvim.api')
        if not ok then
          require('lazy').load { plugins = { 'supermaven-nvim' } }
          ok, api = pcall(require, 'supermaven-nvim.api')
          if not ok then
            return
          end
        end

        if not vim.g.supermaven_enabled then
          vim.g.supermaven_enabled = true
          vim.schedule(function()
            if not api.is_running() then
              api.start()
            end
            vim.notify 'Supermaven: ENABLED'
          end)
        else
          vim.g.supermaven_enabled = false
          if api.is_running() then
            api.stop()
          end
          vim.notify 'Supermaven: disabled'
        end
      end

      vim.keymap.set('n', '<leader>ts', toggle, { desc = '[T]oggle [S]upermaven', silent = true })
    end,
    opts = {
      -- Prevent auto-start on load; only starts when toggled ON
      condition = function()
        return not vim.g.supermaven_enabled
      end,
      keymaps = {
        accept_suggestion = '<Tab>',
        clear_suggestion = '<C-l>',
        accept_word = '<C-j>',
      },
    },
  },
}
