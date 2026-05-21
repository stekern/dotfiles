-- Shows active AI completion providers in the statusline
local function completion_agent_icon()
  local icons = {}
  if vim.g.supermaven_enabled then
    local ok, api = pcall(require, 'supermaven-nvim.api')
    if ok and api.is_running() then
      table.insert(icons, '⚡️')
    end
  end
  if vim.g.toggle_copilot_enabled then
    table.insert(icons, '🤖')
  end
  return table.concat(icons, ' ')
end

return {
  { -- Colorscheme: tinted-vim (successor to base16-nvim).
    -- Uses tinted-vim over RRethy/base16-nvim because the latter maps @variable
    -- to base08 (red), while tinted-vim maps it to foreground (neutral).
    'tinted-theming/tinted-vim',
    priority = 1000,
    config = function()
      local in_tmux = vim.env.TMUX ~= nil

      -- Read theme name from tinted-shell's symlink (set by toggle-theme / base16_* aliases)
      local function get_base16_theme()
        local target = vim.fn.resolve(os.getenv 'HOME' .. '/.config/tinted-theming/base16_shell_theme')
        -- [^/]+ ensures we match only the filename, not parent dirs like base16-shell/
        local theme = target:match '/base16%-([^/]+)%.sh$'
        return theme or 'horizon-terminal-dark'
      end

      local current_theme = nil

      -- Style overrides applied after every colorscheme change
      local function apply_overrides()
        if in_tmux then
          -- Strip background from UI groups so tmux's inactive pane dimming
          -- (window-style bg=colour18) shows through. Without this, nvim's
          -- termguicolors RGB backgrounds paint over tmux's palette-based dimming.
          for _, group in ipairs {
            'Normal',
            'NormalNC',
            'SignColumn',
            'LineNr',
            'CursorLineNr',
            'Folded',
            'FoldColumn',
            'EndOfBuffer',
            'WinSeparator',
          } do
            local existing = vim.api.nvim_get_hl(0, { name = group })
            existing.bg = nil
            vim.api.nvim_set_hl(0, group, existing)
          end
        end
        -- Dim inactive windows by using a muted foreground and slightly darker background
        local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
        local base04 = vim.api.nvim_get_hl(0, { name = 'tinted_gui04' })
        local base01 = vim.api.nvim_get_hl(0, { name = 'tinted_gui01' })
        vim.api.nvim_set_hl(0, 'NormalNC', { fg = base04.fg, bg = base01.fg })
        -- Use foreground (base05) for members/properties instead of base04 (grey). Looks better for Terraform.
        vim.api.nvim_set_hl(0, '@variable.member', { link = 'Identifier' })
        for _, hl_name in ipairs { 'Comment', 'htmlArg' } do
          local hl = vim.api.nvim_get_hl(0, { name = hl_name })
          hl.italic = true
          vim.api.nvim_set_hl(0, hl_name, hl)
        end
        -- Underline instead of the default green background for LSP references
        vim.api.nvim_set_hl(0, 'LspReferenceText', { underline = true })
        vim.api.nvim_set_hl(0, 'LspReferenceRead', { underline = true })
        vim.api.nvim_set_hl(0, 'LspReferenceWrite', { underline = true })
      end

      local function apply_theme()
        local theme = get_base16_theme()
        if theme ~= current_theme then
          current_theme = theme
          pcall(vim.cmd.colorscheme, 'base16-' .. theme)
        end
        -- Runs after the current event loop tick so the colorscheme is fully
        -- applied before lualine reads it. lualine.setup can reset highlight
        -- groups, so we re-apply overrides after it.
        vim.schedule(function()
          local ok, lualine = pcall(require, 'lualine')
          if ok then
            lualine.setup { options = { theme = 'auto' } }
          end
          apply_overrides()
        end)
      end

      vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_overrides })

      apply_theme()

      -- Re-check theme when nvim regains focus (e.g., after toggling in tmux)
      -- Requires `set -g focus-events on` in tmux.conf
      vim.api.nvim_create_autocmd('FocusGained', {
        callback = apply_theme,
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        sections = {
          lualine_x = { completion_agent_icon, 'encoding', 'fileformat', 'filetype' },
        },
        options = {
          icons_enabled = false,
          theme = 'auto',
        },
      }
    end,
  },
  { -- Shows pending keybinds in a popup
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      -- Document existing key chains for which-key popup
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
  { -- Highlight TODO, NOTE, etc. in comments
    -- after='' disables coloring the text after the keyword (poor contrast on light themes)
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false, highlight = { after = '' } },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      zen = { enabled = true, win = { width = 100 } },
    },
    keys = {
      {
        '<leader>tz',
        function()
          Snacks.zen()
        end,
        desc = '[T]oggle [Z]en Mode',
      },
    },
  },
}
