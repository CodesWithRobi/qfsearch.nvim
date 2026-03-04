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

  vim.schedule(function()
    local filtered = {}

    for _, item in ipairs(qflist) do
      local bufnr = item.bufnr
      if bufnr and bufnr ~= 0 then
        -- Force load the buffer
        vim.fn.bufload(bufnr)

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        -- Search line by line (ipairs gives us the line number as 'lnum')
        for lnum, line in ipairs(lines) do
          -- string.find returns the starting column index if a match is found
          local col_start = line:find(keyword, 1, true)

          if col_start then
            -- Create a copy of the item so we don't mutate the old list directly
            local matched_item = vim.deepcopy(item)

            -- Update the coordinates to jump to the exact location
            matched_item.lnum = lnum
            matched_item.col = col_start

            -- Update the preview text shown in the quickfix window (trimming whitespace)
            matched_item.text = line:match("^%s*(.-)%s*$") or line

            table.insert(filtered, matched_item)
            break -- Move to the next file after finding the first match
          end
        end
      end
    end

    -- Apply the new filtered list
    vim.fn.setqflist(filtered)
    vim.notify("QfSearch: Kept " .. #filtered .. " files.", vim.log.levels.INFO)

    if M.config.auto_open and #filtered > 0 then
      vim.cmd("copen")
    end
  end)
end

return M
