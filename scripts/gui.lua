local guiBuilder = require("guibuilder")
local l = require("logger")
local modGui = require("mod-gui")

local gui = {}

function gui.initializeAllConnectedPlayers(queueHasEntries)
    for _, player in pairs(game.connected_players) do
        gui.initialize(player, queueHasEntries)
    end
end

function gui.initialize(player, queueHasEntries)
    log(l.info("initializing gui for player " .. player.index))
    local buttonFlow = modGui.get_button_flow(player)
    
    -- destroying already existing buttons in case of changes
    local flowButton = buttonFlow[guiBuilder.flowButtonName]
    if flowButton then
        flowButton.destroy()
    end
    -- adding the button
    storage.flowButton[player.index] = buttonFlow.add{
        type = "sprite-button",
        name = guiBuilder.flowButtonName,
        sprite = queueHasEntries and "FAS-recording-icon" or "FAS-icon",
        visibility = true;
    }
    
    -- destroying already existing gui in case of changes
    local mainFrame = player.gui.screen[guiBuilder.mainFrameName]
    if mainFrame then
        mainFrame.destroy()
    end
end

local function guiIsValid(player)
    return storage.gui[player] and storage.gui[player].mainFrame.valid
end

function gui.highlightSelectAreaButton(player)
    -- happens if the shortcut was clicked before the ui was created
    if guiIsValid(player) then
        storage.gui[player].select_area_button.style = "fas_clicked_tool_button"
    end
end

function gui.unhighlightSelectAreaButton(player)
    -- happens if the shortcut was clicked before the ui was created
    if guiIsValid(player) then
        storage.gui[player].select_area_button.style = "tool_button"
    end
end

function gui.togglegui(index)
    log(l.info("toggling gui"))
    local player = game.get_player(index)
    local guiFrame = player.gui.screen[guiBuilder.mainFrameName]
    if not guiFrame then
        guiBuilder.createGuiFrame(player, gui)
        
    else
        if not guiFrame.visible and not storage.auto.amount then
            gui.refreshStatusCountdown()
        end
        guiFrame.visible = not guiFrame.visible
    end
    
    
    if not guiFrame or guiFrame.visible then
        log(l.info("gui is now visible"))
        if storage.snip[index].area.width then
            gui.refreshEstimates(index)
            gui.refreshStartHighResScreenshotButton(index)
        end
    else
        log(l.info("gui is now hidden"))
    end
end


function gui.refreshStartHighResScreenshotButton(index)
    -- {1, 16384}
    if guiIsValid(index) then
        storage.gui[index].start_area_screenshot_button.enabled =
            storage.snip[index].enableScreenshotButton
    end
end

function gui.refreshEstimates(index)
    if not guiIsValid(index) then return end

    if not storage.snip[index].resolution then
        -- happens if the zoom slider is moved before an area was selected so far
        storage.gui[index].resolution_value.caption = {"FAS-no-area-selected"}
        storage.gui[index].estimated_filesize_value.caption = "-"
        return
    end

    storage.gui[index].resolution_value.caption = storage.snip[index].resolution
    storage.gui[index].estimated_filesize_value.caption = storage.snip[index].filesize
end

function gui.resetAreaValues(index)
    -- is nil if the ui was not opened before using the delete shortcut
    if guiIsValid(index) then
        storage.gui[index].x_value.text = ""
        storage.gui[index].y_value.text = ""
        storage.gui[index].width_value.text = ""
        storage.gui[index].height_value.text = ""
    end
end

function gui.refreshAreaValues(index)
    -- happens if the shortcuts were pressed before the ui was opened
    if guiIsValid(index) then
        storage.gui[index].x_value.text = tostring(storage.snip[index].area.left)
        storage.gui[index].y_value.text = tostring(storage.snip[index].area.top)
        storage.gui[index].width_value.text = tostring(storage.snip[index].area.width)
        storage.gui[index].height_value.text = tostring(storage.snip[index].area.height)
    end
end

-- cursor stack stuff
function gui.clearPlayerCursorStack(index)
    game.get_player(index).cursor_stack.clear()
end

function gui.givePlayerSelectionTool(index)
    game.get_player(index).cursor_stack.set_stack{
            name = "FAS-selection-tool"
        }
end

function gui.toggle_auto_content_area(index)
    if storage.gui[index].auto_content.visible then
        storage.gui[index].auto_content_collapse.sprite = "utility/expand"
        storage.gui[index].auto_content_collapse.hovered_sprite = "utility/expand"
        storage.gui[index].auto_content_collapse.clicked_sprite = "utility/expand"
    else
        storage.gui[index].auto_content_collapse.sprite = "utility/collapse"
        storage.gui[index].auto_content_collapse.hovered_sprite = "utility/collapse"
        storage.gui[index].auto_content_collapse.clicked_sprite = "utility/collapse"
    end
    storage.gui[index].auto_content.visible = not storage.gui[index].auto_content.visible
end

function gui.toggle_area_content_area(index)
    if storage.gui[index].area_content.visible then
        storage.gui[index].area_content_collapse.sprite = "utility/expand"
        storage.gui[index].area_content_collapse.hovered_sprite = "utility/expand"
        storage.gui[index].area_content_collapse.clicked_sprite = "utility/expand"
    else
        storage.gui[index].area_content_collapse.sprite = "utility/collapse"
        storage.gui[index].area_content_collapse.hovered_sprite = "utility/collapse"
        storage.gui[index].area_content_collapse.clicked_sprite = "utility/collapse"
    end
    storage.gui[index].area_content.visible = not storage.gui[index].area_content.visible
end


function gui.getStatusValue()
    if storage.auto.amount then
        return storage.auto.amount .. " / " .. storage.auto.total
    else
        return "-"
    end
end

function gui.setStatusValue()
    storage.auto.progressValue = storage.auto.amount / storage.auto.total
    for index, player in pairs(storage.gui) do
        if l.doD then log(l.debug("player " .. index .. " found")) end
        if l.doD then log(l.debug("player.mainframe nil? " .. (player.mainFrame == nil and "true" or "false"))) end
        if player.mainFrame and player.mainFrame.valid and player.mainFrame.visible then
            if l.doD then log(l.debug("setting status value for player " .. index .. " with amount " .. storage.auto.amount .. " / " .. storage.auto.total)) end
            player.status_value.caption = storage.auto.amount .. " / " .. storage.auto.total
            if player.progress_bar.visible == false then
                player.progress_bar.visible = true
            end
            player.progress_bar.value = storage.auto.progressValue
        end
        -- set flowbutton pie progress value
    end
end

local function calculateCountdown()
    if storage.queue.nextScreenshotTimestamp ~= nil then
        local timediff = (storage.queue.nextScreenshotTimestamp - game.tick) / 60

        local diffSec = math.floor(timediff % 60)
        if timediff >= 60 then
            local diffMin = math.floor(timediff / 60) % 60
            return diffMin .. "min " .. diffSec .. "s"
        else
            return diffSec .. "s"
        end
    else
        return "-"
    end
end

function gui.refreshStatusCountdown()
    --reset status values if still present, necessary on the first time the cooldown is set
    if storage.auto.amount then
        storage.auto.amount = nil
        storage.auto.total = nil
        storage.auto.progressValue = nil
        for _, player in pairs(storage.gui) do
            if player.progress_bar and player.progress_bar.valid then
                player.progress_bar.visible = false
            end
            -- reset flowbutton pie progress value
        end
    end
    
    local countdown = calculateCountdown()
    for index, player in pairs(storage.gui) do
        if player.mainFrame and player.mainFrame.valid and player.mainFrame.visible then
            -- when the status is '-' this would always refresh without the if here
            if (player.status_value.caption ~= countdown) then
                if l.doD then log(l.debug("setting status value for player " .. index .. " with countdown " .. countdown)) end
                player.status_value.caption = countdown
            end
        end
    end
end


return gui