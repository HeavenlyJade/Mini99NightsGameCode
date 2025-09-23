local script = script
local game = game
local MainStorage  = game:GetService('MainStorage')
local ClientCustomUI = require(MainStorage.code.common.customUi.ClientCustomUI) ---@type ClientCustomUI

-- 初始化充值路径
local function MatchPaths(ui)
    return {
        -- 关闭按钮
        CreateTeam_1 = "创建队伍背景/创捷列表/创建_1",
        CreateTeam_2 = "创建队伍背景/创捷列表/创建_2",
        CreateTeam_3 = "创建队伍背景/创捷列表/创建_3",
        CreateTeam_4 = "创建队伍背景/创捷列表/创建_4",
        CreateTeam_5 = "创建队伍背景/创捷列表/创建_5",
        LeaveTeamBtn = "离开按钮",

    }
end

return ClientCustomUI.Load(script.Parent, MatchPaths)