-- SPDX-License-Identifier: GPL-2.0-only
-- Copyright (C) 2026 OmniNull — https://github.com/OmniNull/OmniWM

-- Built-in clock (shell/default/widgets/clock) with the date as yyyy-mm-dd (Tue) in
-- the normal text color and a 24-hour time, whatever the system locale says. Lives in
-- the top-level widgets/ folder, which OmniWM uses before default/; ../lib still
-- resolves to default/lib.

local look = require("../lib/look")
local calendar = require("../lib/calendar")

local function parts(ctx)
    local _ = ctx.data.clock -- read it so the bar redraws when the minute changes
    local hour, minute = os.date("%H"), os.date("%M")
    return { time = hour .. ":" .. minute, date = os.date("%Y-%m-%d (%a)"), hour = hour, minute = minute,
        showDate = ctx.select("settings", "date") ~= false, showIcon = ctx.select("settings", "icon") == true }
end

function render(ctx)
    local m = parts(ctx)
    local click = look.clockClick
    local behaviour = { onClick = click or ui.popout, onRightClick = if click then ui.popout else nil }
    local button = look.clockBar and look.clockBar(ctx, m)
    if not button then
        local scale = look.scale(ctx)
        local props = table.clone(behaviour)
        if ctx.data.bar.style.vertical then
            props.gap = 0
            props.pad = 2 * scale
            if m.showIcon then
                props[#props + 1] = look.glyph{ name = "calendar", size = 12 * scale }
            end
            props[#props + 1] = look.text{ text = m.hour, size = 11 * scale, weight = "medium" }
            props[#props + 1] = look.text{ text = m.minute, size = 11 * scale }
            if m.meridiem then
                props[#props + 1] = look.text{ text = m.meridiem, size = 9 * scale, color = "secondaryForeground" }
            end
        else
            props.gap = 8 * scale
            if m.showIcon then
                props[#props + 1] = look.glyph{ name = "calendar", size = look.px(ctx, "symbol") }
            end
            if m.showDate then
                props[#props + 1] = look.text{ text = m.date, size = 13 * scale }
            end
            props[#props + 1] = look.text{ text = m.time, size = 13 * scale, weight = "medium", reserve = "00:00" }
        end
        button = look.bar(ctx, props)
    end
    for key, value in behaviour do
        button[key] = value
    end
    return button
end

function popout(ctx)
    return calendar.popout(ctx)
end
