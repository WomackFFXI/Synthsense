_addon.name = 'SynthSense'
_addon.author = 'Womack'
_addon.version = '2.6'
_addon.commands = {'synthsense', 'ss'}

local packets = require('packets')
local texts = require('texts')
local config = require('config')

-- Default Settings & Persistent Data
local defaults = {
    pos = {x = 100, y = 100},
    stats = {
        breaks = 0,
        nq = 0,
        hq1 = 0,
        hq2 = 0,
        hq3 = 0,
        total = 0
    }
}

-- Load saved statistics and UI coordinates on startup
local settings = config.load(defaults)

-- Draggable Text Display Setup
local tracker_box = texts.new({
    pos = {x = settings.pos.x, y = settings.pos.y},
    text = {
        font = 'Consolas',
        size = 11,
        alpha = 255,
        stroke = {width = 2, alpha = 200, red = 0, green = 0, blue = 0}
    },
    bg = {alpha = 160, red = 15, green = 15, blue = 20},
    padding = 8,
    flags = {draggable = true}
})

-- Update On-Screen Display
local function update_display()
    local s = settings.stats
    local total = s.total > 0 and s.total or 1 -- Avoid division by zero

    local break_pct = (s.breaks / total) * 100
    local nq_pct = (s.nq / total) * 100
    local hq1_pct = (s.hq1 / total) * 100
    local hq2_pct = (s.hq2 / total) * 100
    local hq3_pct = (s.hq3 / total) * 100
    local total_hq = s.hq1 + s.hq2 + s.hq3
    local total_hq_pct = (total_hq / total) * 100

    local content = string.format(
        "\\cs(255,215,0)  === SYNTH SENSE ===\\cr\n" ..
        "\\cs(255,100,100)Breaks: %4d (%5.1f%%)\\cr\n" ..
        "\\cs(220,220,220)NQ:%4d (%5.1f%%)\\cr\n" ..
        "\\cs(100,255,100)HQ1:%4d (%5.1f%%)\\cr\n" ..
        "\\cs(100,220,255)HQ2:%4d (%5.1f%%)\\cr\n" ..
        "\\cs(255,130,255)HQ3:%4d (%5.1f%%)\\cr\n" ..
        "-----------------------\n" ..
        "\\cs(255,255,255)Total Synths: %d\\cr\n" ..
        "\\cs(255,215,0)Total HQ Rate: %.1f%%\\cr",
        s.breaks, break_pct,
        s.nq, nq_pct,
        s.hq1, hq1_pct,
        s.hq2, hq2_pct,
        s.hq3, hq3_pct,
        s.total,
        total_hq_pct
    )

    tracker_box:text(content)
    tracker_box:show()
end

-- Save settings to data/settings.xml
local function save_stats()
    if tracker_box then
        local pos_x, pos_y = tracker_box:pos()
        if pos_x and pos_y then
            settings.pos.x = pos_x
            settings.pos.y = pos_y
        end
    end
    settings:save()
end

-- Helper to record synth results and persist
local function record_synth(result_type, amount)
    local qty = amount or 1
    local s = settings.stats

    if result_type == 'break' or result_type == 'breaks' then
        s.breaks = math.max(0, s.breaks + qty)
    elseif result_type == 'nq' then
        s.nq = math.max(0, s.nq + qty)
    elseif result_type == 'hq1' then
        s.hq1 = math.max(0, s.hq1 + qty)
    elseif result_type == 'hq2' then
        s.hq2 = math.max(0, s.hq2 + qty)
    elseif result_type == 'hq3' then
        s.hq3 = math.max(0, s.hq3 + qty)
    else
        return false
    end

    s.total = s.breaks + s.nq + s.hq1 + s.hq2 + s.hq3
    save_stats()
    update_display()
    return true
end

-- Reset function
local function reset_stats()
    settings.stats.breaks = 0
    settings.stats.nq = 0
    settings.stats.hq1 = 0
    settings.stats.hq2 = 0
    settings.stats.hq3 = 0
    settings.stats.total = 0
    save_stats()
    update_display()
    windower.add_to_chat(207, '[SynthSense] Counters reset to zero.')
end

-- Track Packet 0x06F (Synthesize Completion)
windower.register_event('incoming chunk', function(id, data)
    if id == 0x06F then
        local raw_result = data:byte(5)

        if raw_result == 1 then
            record_synth('break')
        else
            local p = packets.parse('incoming', data)
            if p then
                local player = windower.ffxi.get_player()
                local player_id = p['Player'] or p['Player ID']
                if player_id and player and player_id ~= player.id then return end

                local quality = p['Quality'] or p['Result']
                if quality == 0 or quality == 'NQ' then
                    record_synth('nq')
                elseif quality == 1 or quality == 'HQ1' then
                    record_synth('hq1')
                elseif quality == 2 or quality == 'HQ2' then
                    record_synth('hq2')
                elseif quality == 3 or quality == 'HQ3' then
                    record_synth('hq3')
                else
                    record_synth('nq')
                end
            else
                record_synth('nq')
            end
        end
    end
end)

-- Command Handler
windower.register_event('addon command', function(command, ...)
    local args = {...}
    local cmd = command and command:lower() or 'help'

    if cmd == 'add' or cmd == 'a' then
        local category = args[1] and args[1]:lower()
        local amount = tonumber(args[2]) or 1

        if category and record_synth(category, amount) then
            windower.add_to_chat(207, string.format('[SynthSense] Added %d to %s.', amount, category:upper()))
        else
            windower.add_to_chat(207, '[SynthSense] Usage: //ss add <nq|hq1|hq2|hq3|break> [amount]')
        end
    elseif cmd == 'reset' or cmd == 'r' then
        reset_stats()
    elseif cmd == 'show' then
        tracker_box:show()
    elseif cmd == 'hide' then
        tracker_box:hide()
    elseif cmd == 'toggle' then
        if tracker_box:visible() then
            tracker_box:hide()
        else
            tracker_box:show()
        end
    elseif cmd == 'save' then
        save_stats()
        windower.add_to_chat(207, '[SynthSense] Manual save completed.')
    else
        windower.add_to_chat(207, '[SynthSense] Commands:')
        windower.add_to_chat(207, ' //ss add <category> [amount] - Add/subtract stats (e.g. //ss add nq 10 or //ss add break -1)')
        windower.add_to_chat(207, ' //ss reset - Resets all stats to zero')
        windower.add_to_chat(207, ' //ss save - Manually saves current stats/position')
        windower.add_to_chat(207, ' //ss show | hide | toggle - UI controls')
    end
end)

-- Initialize and display loaded stats on startup
windower.register_event('load', function()
    update_display()
end)

-- Save stats and window position on unload, zone change, or exit
windower.register_event('unload', function()
    save_stats()
end)

windower.register_event('logout', function()
    save_stats()
end)