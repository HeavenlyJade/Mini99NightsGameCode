local script = script
local game = game
local MainStorage  = game:GetService('MainStorage')
local ClientCustomUI = require(MainStorage.code.common.customUi.ClientCustomUI) ---@type ClientCustomUI

-- 初始化成就路径
local function InitAchievementPaths(ui)
    return {
        -- 关闭按钮
        CloseButton = "成就底图/关闭按钮",

        -- 展示图标
        ShowIcon = "成就底图/展示图标",
        ShowIconTitle = "成就底图/展示图标/称号",
        ShowIconDesc = "成就底图/展示图标/描述",

        ShowBtn = "成就底图/展示图标/展示按钮",
        NotShowBtn = "成就底图/展示图标/卸下按钮",

        ShowIconStartLayer_1 = "成就底图/展示图标/星星/星星底图_1",
        ShowIconStart_1 = "成就底图/展示图标/星星/星星底图_1/星星",
        ShowIconStartLayer_2 = "成就底图/展示图标/星星/星星底图_2",
        ShowIconStart_2 = "成就底图/展示图标/星星/星星底图_2/星星",
        ShowIconStartLayer_3 = "成就底图/展示图标/星星/星星底图_3",
        ShowIconStart_3 = "成就底图/展示图标/星星/星星底图_3/星星",
        ShowIconStartLayer_4 = "成就底图/展示图标/星星/星星底图_4",
        ShowIconStart_4 = "成就底图/展示图标/星星/星星底图_4/星星",
        ShowIconStartLayer_5 = "成就底图/展示图标/星星/星星底图_5",
        ShowIconStart_5 = "成就底图/展示图标/星星/星星底图_5/星星",

        IconList = "成就底图/图标列表",

        SelectIcon = "选中底图",
        IconBtn = "图标",

        GemImg = "图标/钻石",
        GemNum = "图标/钻石/数量",


        IconStartLayer_1 = "星星/星星底图_1",
        IconStart_1 = "星星/星星底图_1/星星",
        IconStartLayer_2 = "星星/星星底图_2",
        IconStart_2 = "星星/星星底图_2/星星",
        IconStartLayer_3 = "星星/星星底图_3",
        IconStart_3 = "星星/星星底图_3/星星",
        IconStartLayer_4 = "星星/星星底图_4",
        IconStart_4 = "星星/星星底图_4/星星",
        IconStartLayer_5 = "星星/星星底图_5",
        IconStart_5 = "星星/星星底图_5/星星",

    }
end

return ClientCustomUI.Load(script.Parent, InitAchievementPaths)