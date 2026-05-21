return { -- Autoformat on save
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  config = function()
    require('conform').setup {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Disable LSP fallback for languages without a well-standardized style
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback',
        }
      end,
      formatters_by_ft = {
        sh = { 'shfmt' },
        lua = { 'stylua' },
        javascript = { 'biome' },
        typescript = { 'biome' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        terraform = { 'terraform_fmt' },
        yaml = { 'prettierd' },
        json = { 'biome' },
        json5 = { 'biome' },
        html = { 'biome' },
        css = { 'biome' },
      },
    }

    -- :FormatDisable disables globally, :FormatDisable! disables for current buffer only
    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = 'Disable autoformat-on-save', bang = true })

    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = 'Re-enable autoformat-on-save' })

    vim.keymap.set('n', '<leader>tf', function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      vim.notify('Formatting: ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'))
    end, { desc = '[T]oggle [F]ormatting', silent = true })
  end,
}
