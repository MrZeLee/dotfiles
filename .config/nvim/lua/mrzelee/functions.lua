--vim.g.netrw_browsex_viewer="-"
--
---- Function for file extension '.md'
--vim.api.nvim_exec2([[
--    function! NFH_md(f)
--        execute '!open -a typora ' . a:f
--    endfunction
--]], {output = false})
--
---- Function for file extension '.pdf'
--vim.api.nvim_exec2([[
--    function! NFH_pdf(f)
--        execute 'silent !zathura ' . a:f . ' &'
--    endfunction
--]], {output = false})

-- saves commands in file, for easier reading
function SaveOutputToFile(command, filename)
    filename = filename or "output.txt"
    local output = vim.inspect(command)
    local file = io.open(filename, "w")
    file:write(output)
    file:close()
end

function GetBufferList()
    local buffers = vim.api.nvim_list_bufs()
    local buffer_list = {}

    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_option(buf, 'buflisted') then
            local bufname = vim.api.nvim_buf_get_name(buf)
            local bufnr = vim.api.nvim_buf_get_number(buf)
            table.insert(buffer_list, {bufname, bufnr})
        end
    end

    return buffer_list
end
