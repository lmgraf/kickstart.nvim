local M = {}

-- ---------------------------------------------------------------------------
-- Private
-- ---------------------------------------------------------------------------

---@param parser_table table
---@return string[] pattern
---@return table<string, string> parser_map
local function parse_parser_table(parser_table)
  local pattern = {}
  local parser_map = {}

  for k, v in pairs(parser_table) do
    -- { "lua", "python" }
    if type(k) == 'number' then
      local parser = v
      parser_map[parser] = parser
      table.insert(pattern, parser)

    -- { json = { "jsonc" } }
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

  return pattern, parser_map
end

-- ---------------------------------------------------------------------------
-- Public
-- ---------------------------------------------------------------------------

---@param parser_table table
function M.ensure_installed(parser_table)
  local _, parser_map = parse_parser_table(parser_table)

  local to_install = {}
  local seen = {}
  local installed = require('nvim-treesitter').get_installed 'parsers'

  -- deduplicate and check installed
  for _, parser in pairs(parser_map) do
    if not seen[parser] then
      seen[parser] = true

      local already_installed = false
      for _, p in ipairs(installed) do
        if p == parser then
          already_installed = true
          break
        end
      end

      if not already_installed then table.insert(to_install, parser) end
    end
  end

  if #to_install > 0 then require('nvim-treesitter').install(to_install) end
end

---@param parser_table table
function M.autostart(parser_table)
  local pattern, parser_map = parse_parser_table(parser_table)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = pattern,
    callback = function()
      local ft = vim.bo.filetype
      local parser_name = parser_map[ft] or ft

      local ok = pcall(vim.treesitter.get_parser, 0, parser_name)
      if ok then
        vim.treesitter.start()
      else
        vim.schedule(function() vim.notify(('Treesitter parser not installed for %s (parser: %s)'):format(ft, parser_name), vim.log.levels.WARN) end)
      end
    end,
  })
end

---@param parser_table table
function M.setup(parser_table)
  M.ensure_installed(parser_table)
  M.autostart(parser_table)
end

return M
