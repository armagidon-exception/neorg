local M = {}

---Handle for registering treesitter parsers
---@param name string Name of the parser
---@param parser_info { install_info?: InstallInfo, maintainers?: string[], readme_note?: string, requires?: string[], tier?: integer } Parser info
function M.register_parser(name, parser_info)
    local has_parsers, parser_configs = pcall(require, "nvim-treesitter.parsers")
    assert(has_parsers, "Nvim-treesitter plugin without parsers module is unsupported!")

    if parser_configs.get_parser_configs then
        parser_configs = parser_configs.get_parser_configs()
        parser_configs[name] = parser_info
    else
        parser_info.tier = parser_info.tier or 1
        vim.api.nvim_create_autocmd("User", {
            pattern = "TSUpdate",
            callback = function()
                require("nvim-treesitter.parsers")[name] = parser_info
            end,
        })
    end
end

---Handle for installing treesitter parsers
---@param names string|string[] Names of parsers to install
---@param opts? {force?: boolean, generate?: boolean, max_jobs?: integer, summary?: boolean} Options to the installer
function M.parser_install(names, opts)
    local has_install, install = pcall(require, "nvim-treesitter.install")
    assert(has_install, "Nvim-treesitter plugin without install module is unsupported!")

    if type(names) == "string" then
        names = { names }
    end

    if install.commands then
        assert(type(install.TSInstallSync) == "table", "TSInstallSync command is not found!")
        assert(type(install.TSInstallSync["run!"]) == "function", "TSInstallSync cannot be invoked!")
        install.TSInstallSync["run!"](table.unpack(names))
    else
        install.install(names, opts)
    end
end

return M
