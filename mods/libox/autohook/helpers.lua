if core ~= nil then error('DO NOT RUN THIS FROM LUANTI') end

function get_sha256(filepaths)
    if type(filepaths) == 'string' then
        if not os.isfile(filepaths) then
            raise('[get_sha256] File not found: ' ..filepaths)
        end
        filepaths = {filepaths}
    elseif type(filepaths) == 'table' then
        for i=1, #filepaths do
            local filepath = filepaths[i]
            if not os.isfile(filepath) then
                raise('[get_sha256] File not found: ' ..filepath)
            end
        end
    else
        raise('[get_sha256] bad argument #1 (string or table expected, got ' ..type(filepaths) ..')')
    end

    -- find_program caches its results, so it's fine to repeatedly call this
    import('lib.detect.find_program')
    local cmd
    local args = {}
    if os.is_host('windows') or os.shell() == 'pwsh' then
        -- also for pwsh linux user... crazy!!
        cmd = find_program('pwsh') or find_program('powershell')
        table.join2(args, {'hash.ps1'}, filepaths)
    else
        cmd = find_program('sh')
        table.join2(args, {'hash.sh'}, filepaths)
    end

    -- this is so so so cursed, and without select() it's not possible to bring pcall back...
    local result
    try { function()
        result = os.iorunv(cmd, args)
        end, catch { function(errors)
            print("Failed to compute SHA256: " .. errors)
        end }
    }
    return result:trim()
end