local M = {}

--- Sorts the lsp completions
function M.blinkFuzzySort()
  if vim.bo.filetype == 'gitcommit' then
    return {
      -- 1️⃣ snippets always first
      function(a, b)
        local SNIP = vim.lsp.protocol.CompletionItemKind.Snippet
        if a.kind == SNIP and b.kind ~= SNIP then return true end
        if a.kind ~= SNIP and b.kind == SNIP then return false end
        -- tie → next sorter
      end,

      -- 2️⃣ normal fuzzy behavior
      'score',
      'sort_text',
      'label',
    }
  end

  -- default for everything else
  return { 'score', 'sort_text', 'label' }
end

return M
