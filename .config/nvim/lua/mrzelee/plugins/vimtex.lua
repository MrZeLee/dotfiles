return {
    --{'lervag/vimtex', lazy = false},
    {
        'lervag/vimtex',
        tag = 'v2.15',
        lazy = false,
        config = function()
            --Note that most plugin managers will do this automatically.
            --this is necessary for vimtex to load properly. the "indent" is optional.
            vim.cmd "filetype plugin indent on"

            --this enables vim's and neovim's syntax-related features. without this, some
            --vimtex features will not work (see ":help vimtex-requirements" for more
            --info).
            vim.cmd "syntax enable"

            --Viewer options: One may configure the viewer either by specifying a built-in
            --viewer method:
            vim.g.vimtex_view_method = 'skim'
            vim.g.vimtex_view_skim_sync = 1
            vim.g.vimtex_view_skim_activate = 0
            -- vim.g.vimtex_view_method = 'zathura'
            vim.g.tex_flavor = 'latex'

            --Or with a generic interface:
            --vim.g.vimtex_view_general_viewer = 'okular'
            --vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'

            -- VimTeX uses latexmk as the default compiler backend. If you use it, which is
            -- strongly recommended, you probably don't need to configure anything. If you
            -- want another compiler backend, you can change it as follows. The list of
            -- supported backends and further explanation is provided in the documentation,
            -- see ":help vimtex-compiler".
            vim.g.vimtex_compiler_method = 'latexmk'

            vim.g.vimtex_compiler_latexmk = {
                aux_dir = 'aux',
                ['options'] = ({
                    '-auxdir=aux',
                    '-bibtex',
                    '-verbose',
                    '-file-line-error',
                    '-synctex=1',
                    '-interaction=nonstopmode',
                }),
            }

            --Most VimTeX mappings rely on localleader and this can be changed with the
            --following line. The default is usually fine and is the symbol "\".
            vim.g.maplocalleader = ","

            vim.g.vimtex_quickfix_open_on_warning = 0

            -- Define the function and autocmd in Vimscript
            vim.cmd([[
            function! s:TexFocusVim() abort
              " Replace `TERMINAL` with the name of your terminal application
              " Example: execute "!open -a iTerm"
              " Example: execute "!open -a Alacritty"
              silent execute "!open -a iTerm"
              redraw!
            endfunction

            augroup vimtex_event_focus
              autocmd!
              autocmd User VimtexEventViewReverse call s:TexFocusVim()
            augroup END
            ]])
        end,
    },
}
