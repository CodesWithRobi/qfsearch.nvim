if vim.g.loaded_qfsearch then
  return
end
vim.g.loaded_qfsearch = true

vim.api.nvim_create_user_command("QfSearch", function(opts)
  require("qfsearch").search(opts.args)
end, {
  nargs = 1,
  desc = "Filter quickfix list by searching full file contents (supports jdt://)"
})
