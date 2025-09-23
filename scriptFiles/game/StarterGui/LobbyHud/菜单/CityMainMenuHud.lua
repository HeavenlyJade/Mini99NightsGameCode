------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-09
-- @模块名称:      CityMainMenuHud
-- @描述:         城镇菜单主界面
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
---@type common_const
local common_const = require(MainStorage.code.common.Const)

------------------------------------------------------------------------------------
---@class CityMainMenuHud:ViewBase
local CityMainMenuHud = ClassMgr.Class("CityMainMenuHud", ViewBase)

local uiConfig = {
    uiName = "CityMainMenuHud",
    layer = -1,
    -- 初始隐藏
    hideOnInit = false,
}


-- 初始化 CityMainMenuHud
function CityMainMenuHud:OnInit(node, config)
    -- 职业
    self.RoleButton = self:Get("职业界面", ViewButton)
    -- 成就
    self.AchievementButton = self:Get("成就界面", ViewButton)
    -- 任务
    self.QuestButton = self:Get("任务界面", ViewButton)
    self.RoleButton.img.Visible = true
    self.AchievementButton.img.Visible = true
    self.QuestButton.img.Visible = true
    -- 注册按钮事件
    self:RegisterEventFunction()
    ClientEventManager.Subscribe("PlayerSwitchScene", function (evt)
        if evt.sceneType == common_const.SCENE_TYPE[1] then
            gg.client_scene_name = evt.name
            gg.client_scene_Type = evt.sceneType
            self:Open()
        else
            self:Close()
        end
    end)
    -- 关闭城镇界面
    ClientEventManager.Subscribe("CloseCityHud", function(evt)
        self:Close()
    end)
end

---为按钮注册点击事件
function CityMainMenuHud:RegisterEventFunction()
    -- "任务交互框"按钮事件
    if self.RoleButton then
        self.RoleButton.clickCb = function(ui, button)
            gg.log("'任务'按钮被点击",button.node.Name)
            ClientEventManager.SendToServer("ClickMenu", {
                PageName = button.node.Name
            })
        end
    end
    if self.QuestButton then
        self.QuestButton.clickCb = function(ui, button)
            gg.log("'任务'按钮被点击",button.node.Name)
            ClientEventManager.SendToServer("ClickMenu", {
                PageName = button.node.Name
            })
        end
    end
    -- "成就"按钮事件
    if self.AchievementButton then
        self.AchievementButton.clickCb = function(ui, button)
            gg.log("'成就'按钮被点击",button.node.Name)
            ClientEventManager.SendToServer("ClickMenu", {
                PageName = button.node.Name
            })
        end
    end
end


return CityMainMenuHud.New(script.Parent, uiConfig)