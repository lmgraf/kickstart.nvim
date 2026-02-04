local M = {}

function M.setup(parser_table)
  local pattern = {}
  local parser_map = {}

  for k, v in pairs(parser_table) do
    if type(k) == 'number' then
      local parser = v
      parser_map[parser] = parser
      table.insert(pattern, parser)
    elseif type(k) == 'string' then
      local parser = k
      parser_map[parser] = parser
      table.insert(pattern, parser)
      for _, ft in ipairs(v) do
        parser_map[ft] = parser
        table.insert(pattern, ft)
      end
    end
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = pattern,
    callback = function()
      local ft = vim.bo.filetype
      local parser_name = parser_map[ft] or ft
      local ok, parser = pcall(vim.treesitter.get_parser, 0, parser_name)
      if ok and parser then
        vim.treesitter.start()
      else
        vim.schedule(function()
          vim.notify('Treesitter parser not installed for ' .. ft .. '. Try :TSInstall ' .. parser_name, vim.log.levels.WARN)
        end)
      end
    end,
  })
end

return M
