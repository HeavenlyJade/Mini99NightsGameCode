local MainStorage = game:GetService("MainStorage")
---@type ClassMgr
local ClassMgr = require(MainStorage.code.common.ClassMgr)
---@type ViewBase
local ViewBase = require(MainStorage.code.client.Ui.ViewBase)
---@type ViewButton
local ViewButton = require(MainStorage.code.client.Ui.ViewButton)
---@type gg
local gg = require(MainStorage.code.common.MGlobal)
---@type ClientEventManager
local ClientEventManager = require(MainStorage.code.client.clientEvent.ClientEventManager)

---@class QueueingHud:ViewBase
local QueueingHud = ClassMgr.Class("QueueingHud", ViewBase)

local uiConfig = {
    uiName = "QueueingHud",
    layer = 0,
    hideOnInit = true,
}

function QueueingHud:OnInit(node, config)
    local exitButton = self:Get("离开按钮", ViewButton)
    exitButton.img.Visible = true
    -- 监听匹配开始事件
    ClientEventManager.Subscribe("GameStart", function()
        -- 匹配开始时关闭UI
        self:Close()
    end)

    -- 监听匹配取消事件
    ClientEventManager.Subscribe("MatchCancel", function()
        -- 匹配取消时关闭UI
        self:Close()
    end)
    -- 更新匹配进度
    ClientEventManager.Subscribe("MatchJoin", function(data)
        self:Open()
    end)

    exitButton.clickCb = function (ui, button)
        -- 发送退出匹配请求到服务器
        gg.network_channel:FireServer({
            cmd = "LeaveQueue"
        })
        -- 关闭UI
        self:Close()
    end
    self:Close()
end

return QueueingHud.New(script.Parent, uiConfig)