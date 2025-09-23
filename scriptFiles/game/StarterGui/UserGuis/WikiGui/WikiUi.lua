local script = script
local game = game
local MainStorage  = game:GetService('MainStorage')
local ClientCustomUI = require(MainStorage.code.common.customUi.ClientCustomUI) ---@type ClientCustomUI

-- 初始化图鉴路径
local function InitWikiPaths(ui)
    return {
        -- 关闭按钮
        CloseButton = "关闭按钮",
    }
end

return ClientCustomUI.Load(script.Parent, InitWikiPaths)