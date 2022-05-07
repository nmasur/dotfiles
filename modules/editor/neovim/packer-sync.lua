-- =======================================================================

-- Install on initial bootstrap
if packer_bootstrap then
    require("packer").sync()
end
