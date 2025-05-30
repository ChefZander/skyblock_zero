if core ~= nil then error('DO NOT RUN THIS FROM LUANTI') end

function get_sha256(filepath)
    if not os.isfile(filepath) then
        raise('File not found: ' .. filepath)
    end

    -- find_program caches its results, so it's fine to repeatedly call this
    import('lib.detect.find_program')
    local cmd
    if os.is_host('windows') or os.shell() == 'pwsh' then
        -- also for pwsh linux user... crazy!!
        cmd = (find_program('pwsh') or find_program('powershell'))
            ..' -Command "(Get-FileHash -Algorithm SHA256 \'' .. filepath .. '\').Hash"'
    elseif find_program('sha256sum') then
        cmd = find_program('sha256sum') ..' \'' .. filepath .. '\' | awk \'{ print $1 }\''
    elseif find_program('shasum') then
        cmd = find_program('shasum') ..' -a 256 \'' .. filepath .. '\' | awk \'{ print $1 }\''
    end

    -- this is so fucking cursed, and without select() it's not possible to bring pcall back...
    local result
    try { function()
        result = os.iorun(cmd)
        end, catch { function(errors)
            print("Failed to compute SHA256: " .. errors)
        end }
    }
    return result:trim()
end