local M = {}

-- Default configuration
M.config = {
  auto_open = true, -- Automatically open the quickfix window if matches are found
}

-- Setup function for lazy.nvim
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- The main search logic
function M.search(keyword)
  if not keyword or keyword == "" then
    vim.notify("QfSearch: Please provide a keyword", vim.log.levels.WARN)
    return
  end

  local qflist = vim.fn.getqflist()
  if #qflist == 0 then
    vim.notify("QfSearch: Quickfix list is empty!", vim.log.levels.INFO)
    return
  end

  vim.notify("Scanning " .. #qflist .. " files for '" .. keyword .. "'...", vim.log.levels.INFO)

  -- Run asynchronously so the UI doesn't completely freeze
  vim.schedule(function()
    local filtered = {}

    for _, item in ipairs(qflist) do
      local bufnr = item.bufnr
      if bufnr and bufnr ~= 0 then
        -- Force load the buffer (crucial for jdt:// files)
        vim.fn.bufload(bufnr)

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        -- Search line by line
        for _, line in ipairs(lines) do
          if line:find(keyword, 1, true) then
            table.insert(filtered, item)
            break
          end
        end
      end
    end

    -- Apply the new filtered list
    vim.fn.setqflist(filtered)
    vim.notify("QfSearch: Kept " .. #filtered .. " files.", vim.log.levels.INFO)

    -- Open the quickfix window if configured and we have results
    if M.config.auto_open and #filtered > 0 then
      vim.cmd("copen")
    end
  end)
end

return M
