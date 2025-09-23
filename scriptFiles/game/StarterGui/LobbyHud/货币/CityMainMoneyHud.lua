------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-09
-- @模块名称:      CityMainMoneyHud
-- @描述:         城镇货币主界面
-- @版本:         v1.0
------------------------------------------------------------------------------------
-- 引入管理对象
local game = game
local script = script
local Vector2 = Vector2
local MainStorage = game:GetService("MainStorage")
---@type ViewBase
local ViewBase = require(MainStorage.code.client.Ui.ViewBase)
---@type ClassMgr
local ClassMgr = require(MainStorage.code.common.ClassMgr)
---@type gg
local gg = require(MainStorage.code.common.MGlobal)
---@type ViewList
local ViewList = require(MainStorage.code.client.Ui.ViewList)
---@type ViewButton
local ViewButton = require(MainStorage.code.client.Ui.ViewButton)
---@type ClientEventManager
local ClientEventManager = require(MainStorage.code.client.clientEvent.ClientEventManager)
---@type ClientScheduler
local ClientScheduler = require(MainStorage.code.client.clientEvent.ClientScheduler)
------------------------------------------------------------------------------------
---@class CityMainMoneyHud:ViewBase
local CityMainMoneyHud = ClassMgr.Class("CityMainMoneyHud", ViewBase)

local uiConfig = {
    uiName = "CityMainMoneyHud",
    layer = -1,
    hideOnInit = false, -- 初始隐藏，当玩家靠近NPC时显示
}


-- 初始化 CityMainMoneyHud
function CityMainMoneyHud:OnInit(node, config)
    -- 钻石
    self.GemBtn = self:Get("货币列表/货币钻石", ViewButton)
    -- 钻石
    self.GemNum = self:Get("货币列表/货币钻石/数量")
    -- 显示货币列表
    self:Get("货币列表").node.Visible = true
    self.CurEquip = ""
    -- 注册按钮事件
    self:RegisterEventFunction()
end

---为按钮注册点击事件
function CityMainMoneyHud:RegisterEventFunction()

    -- "任务交互框"按钮事件
    if self.GemBtn then
        self.GemBtn.clickCb = function(ui, button)
            gg.log("'任务'按钮被点击",button.node.Name)
            ClientEventManager.SendToServer("ClickMenu", {
                PageName = button.node.Name
            })
        end
    end
    -- 同步玩家货币
    ClientEventManager.Subscribe("SynchronizePlayerCurrencies", function(evt)
        if evt.GemNum then
            self.GemNum.node.Title = gg.FormatLargeNumber(evt.GemNum)
        end
    end)
end

return CityMainMoneyHud.New(script.Parent, uiConfig)