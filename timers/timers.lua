local os = require("os")
local math = require("math")
local set = require("set")
local list = require("list")
local table = require("table")
local string = require("string")
local player = require("player")
local packet = require("packet")
local res = require("resources")
local entities = require("entities")
local equipment = require("equipment")

local ui = require("core.ui")
local command = require('core.command')
local windower = require('core.windower')

local timer_lists = {
    custom = list(),
    recast = list(),
    status_effect = list()
}

local x_init = 1000
local y_init = 500

local status_timers_window = {}
status_timers_window.state = {
    title = 'Status',
    style = 'chromeless',
    x = 200,
    y = 55,
    width = 180,
    height = 90,
    color = ui.color.rgb(0,0,0,40),
    resizable = false,
    moveable = true,
    closable = true,
}
local recast_timers_window = {}
recast_timers_window.state = {
    title = 'Recast',
    style = 'chromeless',
    x = 200,
    y = 155,
    width = 180,
    height = 90,
    color = ui.color.rgb(0,0,0,40),
    resizable = false,
    moveable = true,
    closable = true,
}
local custom_timers_window = {}
custom_timers_window.state = {
    title = 'Custom',
    style = 'chromeless',
    x = 200,
    y = 255,
    width = 180,
    height = 90,
    color = ui.color.rgb(0,0,0,40),
    resizable = false,
    moveable = true,
    closable = true,
}

local time_format = function(s)
    if s > 3600 then
        return string.format('%i:%02i:%02i', math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
    elseif s > 60 then
        return string.format('  %i:%02i', math.floor(s / 60), s % 60)
    elseif s > 10 then
        return string.format('   0:%02i', s)
    elseif s > 0 then
        return string.format('   %.1fs', s)
    end

    return '-'
end

local timers = command.new('timers')

local delete_custom_timer = function(name)
    local existing = timer_lists.custom:where(function(a) return a.name == name end):to_table()

    for _, v in pairs(existing) do
       timer_lists.custom:remove_element(v)
    end
end

timers:register('d', delete_custom_timer, '<name:string(%a+)>')
timers:register('create', delete_custom_timer, '<name:string(%a+)>')

local create_custom_timer = function(name, duration, direction, icon)
    local end_time = os.clock() + duration
    
    delete_custom_timer(name)

    timer_lists.custom:add({name = name, duration = duration, end_time = end_time, direction = direction, icon = icon})
    table.sort(timer_lists.custom, function(a, b) return a.end_time < b.end_time end)
end

timers:register('c', create_custom_timer, '<name:string(%a+)> <duration:number> [direction:one_of(up,down)=up] [icon:string(%a+)=default.png]')
timers:register('create', create_custom_timer, '<name:string(%a+)> <duration:number> [direction:one_of(up,down)=up] [icon:string(%a+)=default.png]')

local function draw_timer(timer, y)
    local image_color = {}
    local now = os.clock()

    local display_name = timer.name
    if timer.targets then
        local target_text = ''
        
        if #timer.targets == 1 then
            if not timer.targets:contains(player.id) then
                target_text = " \\[" .. entities:by_id(timer.targets:first()).name .. "\\]"
            end
        else
            target_text = " \\[AoE\\]"
        end
        display_name = display_name .. target_text
    end
    ui.location(16, 7 + y)
    ui.size(164, 10)

    local remaining_time = timer.end_time - now
        local progress = (timer.duration - remaining_time)/timer.duration

        if timer.direction == 'down' then
            progress = 1 - progress
        end

        local color
        if progress < .5 then
            color = ui.color.red
        elseif progress < .75 then
            color = ui.color.yellow
        else
            color = ui.color.limegreen
        end
        
    if remaining_time > 1 then
        ui.progress(progress, {color = color})

        ui.location(17, -2 + y)
        ui.text(string.format('[%s]{stroke:"1px"}', display_name))

    elseif (math.floor(remaining_time * 10) % 2) == 1 then
        ui.progress(progress, {color = color})
        image_color.color = ui.color.yellow
        ui.location(17, -2 + y)
        ui.text(string.format('[%s]{stroke:"1px" color:%s}', timer.name, ui.color.tohex(ui.color.yellow)))

    else
        ui.progress(progress, {color = color})

        ui.location(17, -2 + y)
        ui.text(string.format('[%s]{stroke:"1px"}', display_name))
    end

    ui.location(140, -2 + y)
    ui.text(string.format('[%s]{stroke:"1px"}', time_format(remaining_time)))

    ui.location(0, 0 + y)
    ui.size(16, 16)

    ui.image(windower.package_path .. [[\icons\]] .. timer.icon, image_color)
end

local process_timers_array= function(timers)
    local y = 0
    local now = os.clock()
    local timers_to_remove = {}
    for _, timer in ipairs(timers) do
        if timer.end_time >= now then
            draw_timer(timer, y)

            y = y + 18
            if y > custom_timers_window.state.height then
                break
            end
        else
            table.insert(timers_to_remove, timer)
        end
    end

    for _, timer in ipairs(timers_to_remove) do
        timers:remove_element(timer)
    end
end

ui.display(function()
    custom_timers_window.state, custom_timers_window.closed = ui.window('custom_timers_window', custom_timers_window.state, function()
            process_timers_array(timer_lists.custom)
    end)

    status_timers_window.state, status_timers_window.closed = ui.window('status_timers_window', status_timers_window.state, function()
            process_timers_array(timer_lists.status_effect)
    end)

    recast_timers_window.state, recast_timers_window.closed = ui.window('recast_timers_window', recast_timers_window.state, function()
            process_timers_array(timer_lists.recast)
    end)
end)

local category = {
    magic           = 'spells',
    job_ability     = 'job_abilities',
}

local incoming_categories = {
    [4] = category.magic,
    [6] = category.job_ability,
    [14] = category.job_ability,
    [15] = category.job_ability,
}

local create_status_timer = function(act, act_resource, icon)

    local targets = set()
    for k, v in ipairs(act.targets) do
        targets:add(v.id)
    end

    local existing = timer_lists.status_effect:where(function(a) return a.name == act_resource.name end):to_table()

    for _, v in pairs(existing) do
        v.targets:difference(targets)
        if #v.targets == 0 then
            timer_lists.status_effect:remove_element(v)
        end
    end

    --local duration = process_status_effect(action_category, act_resource)

    timer_lists.status_effect:add({
        name = act_resource.name,
        duration = act_resource.duration or 0,
        end_time = os.clock() + (act_resource.duration or 0), 
        direction = "down", 
        icon = icon, 
        targets = targets
    })
    table.sort(timer_lists.status_effect, function(a, b) return a.end_time < b.end_time end)
end

local create_recast_timer = function(act, act_resource, icon)

    timer_lists.recast:add({
        name = act_resource.name,
        duration = act.recast,
        end_time = os.clock() + act.recast,
        direction = "up",
        icon = icon
    })
    table.sort(timer_lists.recast, function(a, b) return a.end_time < b.end_time end) 
end

local process_action = function(act)

    local action_category = incoming_categories[act.category]
    if not action_category or act.actor ~= player.id then
        return
    end

    local act_resource = res[action_category][act.param]
    local icon = string.format("%s/%05d.png", action_category, act.param)

    create_recast_timer(act, act_resource, icon)
    create_status_timer(act, act_resource, icon)
end

packet.incoming[0x028]:register(process_action)

