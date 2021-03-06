call plug#begin('~/.vim/plugged')

Plug 'https://github.com/scrooloose/nerdtree.git'
Plug 'https://github.com/neovim/nvim-lspconfig.git'
Plug 'https://github.com/kabouzeid/nvim-lspinstall.git'
Plug 'https://github.com/HerringtonDarkholme/yats.vim.git'

call plug#end()

" jk exits from insert and visual mode
inoremap jk <Esc>
vnoremap jk <Esc>

" Indentation settings
set autoindent
set tabstop=4
set expandtab
set shiftwidth=4

filetype on

" JS JSX TS TSX support
augroup javascript
    autocmd!
    " autocmd BufNewFile, BufRead *.tsx set filetype=typescript
    autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear
    autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
    autocmd FileType javascript,javascriptreact,typescript,typescriptreact set autoindent
    autocmd FileType javascript,javascriptreact,typescript,typescriptreact set tabstop=2
    autocmd FileType javascript,javascriptreact,typescript,typescriptreact set expandtab
    autocmd FileType javascript,javascriptreact,typescript,typescriptreact set shiftwidth=2
augroup END

lua << EOF
local work_profile = os.getenv("WORK_PROFILE")
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

-- Use a loop to conveniently both setup defined servers 
-- and map buffer local keybindings when the language server attaches
local servers = {}

if work_profile == nil then
    print("This is not a work profile")
    servers = { "tsserver", "jdtls", "pyls" }
else
    require'lspinstall'.setup()
    servers = require'lspinstall'.installed_servers()
end

for _, lsp in ipairs(servers) do
  if lsp == "jdtls" then
    local util = require("lspconfig/util")
    local cmd = {
      util.path.join(tostring(vim.fn.getenv("JAVA_HOME")), "/bin/java"),
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-javaagent:" .. tostring(vim.fn.getenv("LOMBOK_JAR")),
      "-Xms1g",
      "-Xmx2G",
      "-jar",
      tostring(vim.fn.getenv("JAR")),
      "-configuration",
      tostring(vim.fn.getenv("JDTLS_CONFIG")),
      "-data",
      tostring(vim.fn.getenv("WORKSPACE")),
      "--add-modules=ALL-SYSTEM",
      "--add-opens java.base/java.util=ALL-UNNAMED",
      "--add-opens java.base/java.lang=ALL-UNNAMED",
    }

    nvim_lsp[lsp].setup {
      on_attach = on_attach,
      cmd = cmd,
    }
  else
    nvim_lsp[lsp].setup { on_attach = on_attach }
  end
end
EOF
