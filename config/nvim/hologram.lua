local source = '/Users/christianbingman/Downloads/5018904-clippy-black-tar-heroin-memes-png-image-transparent-png-free-clippy-transparent-820_502.png'
local buf = vim.api.nvim_get_current_buf()
local image = require('hologram.image'):new(source, {})

-- Image should appear below this line, then disappear after 5 seconds

image:display(2, 10, buf, {})

vim.defer_fn(function()
    image:delete(0, {free = true})
end, 5000)
