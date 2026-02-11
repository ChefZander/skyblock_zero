local mp = core.get_modpath('machine_ui_api')

machine_ui_api = {}
function machine_ui_api.escape(x)
    return x:gsub('.', {
        ['\\'] = '\\\\',
        ['^'] = '\\^',
        [':'] = '\\:',
    })
end

dofile(mp .. '/font_rendering.lua')
dofile(mp .. '/machine_hover_render.lua')
