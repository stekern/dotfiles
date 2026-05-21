return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup {}

    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    local parsers = {
      'bash', 'c', 'css', 'diff', 'go', 'hcl', 'html',
      'javascript', 'json', 'lua', 'luadoc', 'markdown',
      'markdown_inline', 'python', 'query', 'terraform',
      'typescript', 'vim', 'vimdoc', 'yaml',
    }
    local installed = require('nvim-treesitter.config').get_installed()
    local to_install = vim.iter(parsers)
      :filter(function(p)
        return not vim.tbl_contains(installed, p)
      end)
      :totable()
    if #to_install > 0 then
      require('nvim-treesitter').install(to_install)
    end
  end,
}
