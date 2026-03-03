

do -- Shop recipe scope
    local Shop = 'smartshop:shop'
    local MS = 'sbz_decor:matter_sign'
    local St = 'sbz_resources:storinator'
    local Ph = 'sbz_decor:photonlamp'
    core.register_craft({
        output = Shop,
        recipe = {
            { MS, St, MS },
            { MS, St, MS },
            { MS, Ph, MS },
        }
    })
end


do -- Storage recipe scope
    local Storage = 'smartshop:storage'
    local RM = 'sbz_resources:reinforced_matter'
    local WC = 'sbz_resources:warp_crystal'
    local Sh = 'smartshop:shop'
    local SN = 'sbz_resources:storinator_neutronium'
    local BT = 'pipeworks:tube_1' -- ("Basic Tube" in-game)
    core.register_craft({
        output = Storage,
        recipe = {
            { RM, WC, RM },
            { Sh, SN, Sh },
            { RM, BT, RM },
        }
    })
end

