local M = {}

function M.beforeLazy()
  require('custom.keymaps').setup()
end

return M
