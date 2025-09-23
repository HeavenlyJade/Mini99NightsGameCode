local script = script
local game = game
local MainStorage  = game:GetService('MainStorage')
local ClientCustomUI = require(MainStorage.code.common.customUi.ClientCustomUI) ---@type ClientCustomUI

-- 初始化任务路径
local function InitQuestPaths(ui)
    return {
        -- 关闭按钮
        CloseButton = "任务栏底图/关闭按钮",
        -- 任务列表
        -- 收集任务栏
        Quest1List = "任务栏底图/收集任务栏/任务列表",
        Quest1Icon = "任务栏底图/收集任务栏/任务图标",
        Quest1IconMask = "任务栏底图/收集任务栏/任务图标/任务图标蒙版",
        Quest1IconGemBtn = "任务栏底图/收集任务栏/任务图标/钻石",
        Quest1IconGemNum = "任务栏底图/收集任务栏/任务图标/钻石/数量",
        Quest1Over = "任务栏底图/收集任务栏/任务图标/完成图标",


        -- 战斗任务栏
        Quest2List = "任务栏底图/战斗任务栏/任务列表",
        Quest2Icon = "任务栏底图/战斗任务栏/任务图标",
        Quest2IconMask = "任务栏底图/战斗任务栏/任务图标/任务图标蒙版",
        Quest2IconGemBtn = "任务栏底图/战斗任务栏/任务图标/钻石",
        Quest2IconGemNum = "任务栏底图/战斗任务栏/任务图标/钻石/数量",
        Quest2Over = "任务栏底图/战斗任务栏/任务图标/完成图标",
        -- 生存任务栏
        Quest3List = "任务栏底图/生存任务栏/任务列表",
        Quest3Icon = "任务栏底图/生存任务栏/任务图标",
        Quest3IconMask = "任务栏底图/生存任务栏/任务图标/任务图标蒙版",
        Quest3IconGemBtn = "任务栏底图/生存任务栏/任务图标/钻石",
        Quest3IconGemNum = "任务栏底图/生存任务栏/任务图标/钻石/数量",
        Quest3Over = "任务栏底图/生存任务栏/任务图标/完成图标",
        -- 时长任务栏
        Quest4List = "任务栏底图/时长任务栏/任务列表",
        Quest4Icon = "任务栏底图/时长任务栏/任务图标",
        Quest4IconMask = "任务栏底图/时长任务栏/任务图标/任务图标蒙版",
        Quest4IconGemBtn = "任务栏底图/时长任务栏/任务图标/钻石",
        Quest4IconGemNum = "任务栏底图/时长任务栏/任务图标/钻石/数量",
        Quest4Over = "任务栏底图/时长任务栏/任务图标/完成图标",


        QuestDesc = "描述",
        QuestProgress = "进度",
    }
end

return ClientCustomUI.Load(script.Parent, InitQuestPaths)