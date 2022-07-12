-- Bootstrap the Packer plugin manager
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
end

require("packer").startup(function(use)
    -- Maintain plugin manager
    use("wbthomason/packer.nvim")

    -- Include other files initialized by packer
    require("packer.speed").packer(use)
    require("packer.misc").packer(use)
    require("packer.colors").packer(use)
    require("packer.visuals").packer(use)
    require("packer.lsp").packer(use)
    require("packer.completion").packer(use)
    require("packer.syntax").packer(use)
    require("packer.telescope").packer(use)

    -- Auto-install after bootstrapping
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
