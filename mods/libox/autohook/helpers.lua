if core ~= nil then error('DO NOT RUN THIS FROM LUANTI') end

function get_sha256(filepaths)
    local all_files = ''
    if type(filepaths) == 'string' then
    elseif type(filepaths) == 'table' then
        for i=1, #filepaths do
            local filepath = filepaths[i]
            if not os.isfile(filepath) then
                raise('[get_sha256] File not found: ' ..filepath)
            end
        end
        all_files = "'" ..table.concat(filepaths, "' '") .."'"
    else
        raise('[get_sha256] bad argument #1 (string or table expected, got ' ..type(filepaths) ..')')
    end

    -- find_program caches its results, so it's fine to repeatedly call this
    import('lib.detect.find_program')
    local cmd
    if os.is_host('windows') or os.shell() == 'pwsh' then
        -- also for pwsh linux user... crazy!!
        cmd = (find_program('pwsh') or find_program('powershell'))
            ..' hash.ps1 ' ..all_files
    elseif find_program('sha256sum') then
        cmd = 'cat ' ..all_files ..' | ' find_program('sha256sum') " | awk '{ print $1 }'"
    elseif find_program('shasum') then
        cmd = 'cat ' ..all_files ..' | ' find_program('shasum') " -a 256 | awk '{ print $1 }'"
    end

    -- this is so so so cursed, and without select() it's not possible to bring pcall back...
    local result
    try { function()
        result = os.iorun(cmd)
        end, catch { function(errors)
            print("Failed to compute SHA256: " .. errors)
        end }
    }
    return result:trim()
end