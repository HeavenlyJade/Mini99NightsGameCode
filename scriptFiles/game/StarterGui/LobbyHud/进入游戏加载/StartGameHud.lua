------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-13
-- @模块名称:      StartGameHud
-- @描述:         首次进入界面
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
---@type ViewButton
local ViewButton = require(MainStorage.code.client.Ui.ViewButton)
---@type gg
local gg = require(MainStorage.code.common.MGlobal)
---@type ClientEventManager
local ClientEventManager = require(MainStorage.code.client.clientEvent.ClientEventManager)
------------------------------------------------------------------------------------
---@class StartGameHud:ViewBase
local StartGameHud = ClassMgr.Class("StartGameHud", ViewBase)

local uiConfig = {
    uiName = "StartGameHud",
    layer = -1,
    hideOnInit = false,
}


-- 初始化
function StartGameHud:OnInit(config)
    local ui_size = gg.get_ui_size()
    self:Get("背景").node.Size = Vector2.New(ui_size.x, ui_size.y)

    self:Get("开始界面/离开按钮", ViewButton).clickCb = function(ui, button)
        self:Close()
    end
    self:Open()
end
return StartGameHud.New(script.Parent, uiConfig)