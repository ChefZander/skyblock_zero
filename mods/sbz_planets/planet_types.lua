-- yipee

local c = core.get_content_id

sbz_api.planets.register_type {
    name = "Dwarf Planet",
    radius = { min = 50, max = 100 },
    node = c("mapgen_stone"),
    flags = {
        mountains = true,
        caves = true,
        half_sphere = false,
    },
}
