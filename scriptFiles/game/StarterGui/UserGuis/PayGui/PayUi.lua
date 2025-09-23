local script = script
local game = game
local MainStorage  = game:GetService('MainStorage')
local ClientCustomUI = require(MainStorage.code.common.customUi.ClientCustomUI) ---@type ClientCustomUI

-- 初始化充值路径
local function InitPayPaths(ui)
    return {
        -- 关闭按钮
        CloseButton = "购买钻石底图/关闭按钮",

        Pay_99 = "购买钻石底图/充值99",
        Pay_400 = "购买钻石底图/充值400",
        Pay_900 = "购买钻石底图/充值900",
        Pay_2500 = "购买钻石底图/充值2500",
        Pay_Mini_Money = "购买钻石底图/充值迷你币",
    }
end

return ClientCustomUI.Load(script.Parent, InitPayPaths)