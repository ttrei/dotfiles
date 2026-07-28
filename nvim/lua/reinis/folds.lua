local M = {}

-- Fold a Git patch by file and then by hunk. Tree-sitter's diff grammar can
-- terminate a hunk at an empty context line, so use the patch markers instead.
function M.diff()
  local line = vim.fn.getline(vim.v.lnum)

  if vim.startswith(line, "diff --git ") then
    return ">1"
  end

  if vim.startswith(line, "@@") then
    return ">2"
  end

  return "="
end

return M
