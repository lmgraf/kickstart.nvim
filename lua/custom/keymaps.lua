local M = {}
--- Quit all hidden buffers
local function quit_hidden_buffers(opts)
  opts = opts or {}
  local force = opts.force or false
  local verbose = opts.verbose or false

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if #vim.fn.win_findbuf(buf) == 0 then
      local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = force })
      if not ok and verbose then print('Failed to delete buffer ' .. buf .. ': ' .. err) end
    end
  end
end

--- Toggle terminal
local function toggle_terminal()
  -- Look for an open terminal window
  local term_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      term_win = win
      break
    end
  end
  if term_win then
    -- Close terminal window if open
    vim.api.nvim_win_close(term_win, true)
  else
    -- Open terminal and enter insert mode
    vim.cmd 'split | terminal'
  end
end

--- Go to an lsp definition in a new tab
local function lsp_definitions_new_tab()
  local params = vim.lsp.util.make_position_params()

  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.WARN)
      return
    end

    local def = result[1]
    local uri = def.uri or def.targetUri
    local range = def.range or def.targetSelectionRange
    local target_path = vim.fn.fnamemodify(vim.uri_to_fname(uri), ':p') -- normalize

    -- Search all tabs and windows for an open window with that file
    for tabnr = 1, vim.fn.tabpagenr '$' do
      local winlist = vim.fn.tabpagewinnr(tabnr, '$')
      for winnr = 1, winlist do
        local winid = vim.fn.win_getid(winnr, tabnr)
        local bufnr = vim.fn.winbufnr(winid)
        local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':p')
        if bufname == target_path then
          vim.cmd(tabnr .. 'tabnext')
          vim.fn.win_gotoid(winid)
          vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
          return
        end
      end
    end

    -- If not found, open in new tab
    vim.cmd('tabnew ' .. target_path)
    vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
  end)
end

function M.general_keymaps()
  local function quit_hidden_cmd(cmd) quit_hidden_buffers { force = cmd.bang } end
  vim.api.nvim_create_user_command('QuitHidden', quit_hidden_cmd, { bang = true })

  vim.keymap.set('n', '<leader>tr', toggle_terminal, { desc = '[T]oggle [T]erminal' })
end

function M.lsp_keymaps(event)
  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'

  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
  -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      --- Helper function to define keymaps
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
      map('ngd', lsp_definitions_new_tab, '[N]ew tab [G]oto [D]efinition')
      map('tg', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
      map('gr', builtin.lsp_references, '[G]oto [R]eferences')
      map('gI', builtin.lsp_implementations, '[G]oto [I]mplementation')
      map('<leader>gsd', builtin.lsp_document_symbols, '[G]oto [S]ymbols in [D]ocument')
      map('<leader>gsw', builtin.lsp_dynamic_workspace_symbols, '[G]oto [S]ymbols in [W]orkspace')

      map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
end

function M.setup(opts) M.general_keymaps() end

return M
