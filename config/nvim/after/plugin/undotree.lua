vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

if vim.fn.has("persistent_undo") == 1 then
  local target_path = os.getenv("HOME") .. '/.undodir'

  local ok, err, code = os.rename(target_path, target_path)
  if not ok then
    if code == 13 then
      print("Permission denied")
    else
      os.execute("mkdir " .. target_path)
    end
  end

  vim.o.undodir=target_path
  vim.opt.undofile = true
end
