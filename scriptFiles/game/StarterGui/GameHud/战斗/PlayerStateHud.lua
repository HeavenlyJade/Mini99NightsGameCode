------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-13
-- @模块名称:      PlayerStateHud
-- @描述:         加载界面
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
---@type ClientEventManager
local ClientEventManager = require(MainStorage.code.client.clientEvent.ClientEventManager)
---@type common_const
local common_const = require(MainStorage.code.common.Const)
---@type ClientScheduler
local ClientScheduler = require(MainStorage.code.client.clientEvent.ClientScheduler)
------------------------------------------------------------------------------------
---@class PlayerStateHud:ViewBase
local PlayerStateHud = ClassMgr.Class("PlayerStateHud", ViewBase)

local uiConfig = {
    uiName = "PlayerStateHud",
    layer = -1,
    hideOnInit = true, -- 初始隐藏，当玩家靠近NPC时显示
}


-- 初始化
function PlayerStateHud:OnInit(config)
    self.textPool = {}
    self.health = self:Get("玩家状态/血条底图/血条").node
    self.healthText = self:Get("玩家状态/血条底图/值").node
    self.hunger = self:Get("玩家状态/饥饿底图/饥饿").node
    self.hungerText = self:Get("玩家状态/饥饿底图/值").node
    self.energy = self:Get("玩家状态/能量底图/能量").node
    self.energyText = self:Get("玩家状态/能量底图/值").node
    self.JobText = self:Get("玩家状态/职业").node
    self.hurtImg = self:Get("被命中").node

    self.injuredImg = self:Get("受伤").node
    self.injured_1 = self:Get("受伤/左上").node
    self.injured_2 = self:Get("受伤/右上").node
    self.injured_3 = self:Get("受伤/左下").node
    self.injured_4 = self:Get("受伤/右下").node

    self.playerCrosshatch = self:Get("准星").node
    self.playerHit = self:Get("命中").node

    local ui_size = gg.get_ui_size()
    self.injuredImg.Size = Vector2.New(ui_size.x, ui_size.y)
    self.injuredImg.Visible = false
    self.hurtImg.Visible = false

    self.playerCrosshatch.Visible = false
    self.playerHit.Visible = false

    self.updateImgTaskId = nil
    self.updateHurtTaskId = nil
    self.updateHitTaskId = nil

    self.showCrosshatch = false
    -- 通知客户端显示准星
    ClientEventManager.Subscribe("showCrosshatch", function(evt)
        if evt.show then
            self.showCrosshatch = true
            self.playerCrosshatch.Visible = true
        else
            self.showCrosshatch = false
            self.playerCrosshatch.Visible = false
        end
    end)


    -- 通知客户端玩家开始生存游戏
    ClientEventManager.Subscribe("GameStart", function(evt)
        self:Open()
    end)

    -- 命中目标
    ClientEventManager.Subscribe("playerHitMonster", function(evt)
        self:ShowHitMonster(evt)
    end)

    -- 更新玩家状态
    ClientEventManager.Subscribe("UpDataPlayerState", function(evt)
        self:UpDataState(evt)
    end)
    -- 受伤
    ClientEventManager.Subscribe("PlayerShowHurtImg", function(evt)
        self:ShowHurtImg(evt)
    end)
    -- 被boss命中
    ClientEventManager.Subscribe("PlayerShowHurtBossImg", function(evt)
        self:ShowHurtBossImg(evt)
    end)

    -- 玩家切换场景 打开界面
    ClientEventManager.Subscribe("PlayerSwitchScene", function(evt)
        if evt.sceneType == common_const.SCENE_TYPE[2] then
            gg.client_scene_name = evt.name
            gg.client_scene_Type = evt.sceneType
            self:Open()
        else
            self:Close()
        end
    end)

    self:Close()
end

-- 更新状态
function PlayerStateHud:UpDataState(evt)
    if evt.health and evt.maxHealth then
        self.healthText.Title = string.format("%s/%s",evt.health , evt.maxHealth)
        self.health.FillAmount = evt.health / evt.maxHealth
    end
    if evt.hunger and evt.maxHunger then
        self.hungerText.Title = string.format("%s/%s",evt.hunger , evt.maxHunger)
        self.hunger.FillAmount = evt.hunger / evt.maxHunger
    end
    if evt.energy and evt.maxEnergy then
        self.energyText.Title = string.format("%s/%s",evt.energy , evt.maxEnergy)
        self.energy.FillAmount = evt.energy / evt.maxEnergy
    end
    if evt.job then
        local job = evt.job
        if job == "" then
             job = "无"
        end
        self.JobText.Title = string.format("职业:%s",job)
    end
end

-- 显示被命中图片
function PlayerStateHud:ShowHurtImg()
    -- 显示UI
    self.injuredImg.Visible = true

    if self.updateHurtTaskId then
        ClientScheduler.cancel(self.updateHurtTaskId)
        self.updateHurtTaskId = nil
    end
    -- 注册更新任务
    local fadeTimer = 0.5
    local add = true
    self.updateHurtTaskId = ClientScheduler.add(function()
        if add then
            fadeTimer = fadeTimer + 0.03
        else
            fadeTimer = fadeTimer - 0.03
        end
        if fadeTimer >= 1 then
            fadeTimer = 1
            add = false
        end
        if fadeTimer <= 0 then
            ClientScheduler.cancel(self.updateHurtTaskId)
            self.updateHurtTaskId = nil
            self.injured_1.Alpha = 0
            self.injured_2.Alpha = 0
            self.injured_3.Alpha = 0
            self.injured_4.Alpha = 0
            self.injuredImg.Visible = false
        end
        self.injured_1.Alpha = fadeTimer
        self.injured_2.Alpha = fadeTimer
        self.injured_3.Alpha = fadeTimer
        self.injured_4.Alpha = fadeTimer
    end, 0, 0.06) -- 每帧更新一次
end

-- 显示被命中图片
function PlayerStateHud:ShowHurtBossImg()
    -- 显示UI
    self.hurtImg.Visible = true
    if self.updateImgTaskId then
        ClientScheduler.cancel(self.updateImgTaskId)
        self.updateImgTaskId = nil
    end
    -- 注册更新任务
    local fadeTimer = 1
    self.updateImgTaskId = ClientScheduler.add(function()
        fadeTimer = fadeTimer - 0.02
        if fadeTimer <= 0 then
            ClientScheduler.cancel(self.updateImgTaskId)
            self.updateImgTaskId = nil
            self.hurtImg.Alpha = 0
            self.hurtImg.Visible = false
        end
        self.hurtImg.Alpha = fadeTimer
    end, 0, 0.06) -- 每帧更新一次
end

-- 命中目标
function PlayerStateHud:ShowHitMonster()
    if not self.showCrosshatch then
        return
    end
    -- 显示命中
    self.playerHit.Visible = true
    -- 隐藏准星
    self.playerCrosshatch.Visible = false
    if self.updateHitTaskId then
        ClientScheduler.cancel(self.updateHitTaskId)
        self.updateHitTaskId = nil
    end
    -- 注册更新任务
    local fadeTimer = 1
    self.updateHitTaskId = ClientScheduler.add(function()
        fadeTimer = fadeTimer - 0.06
        if fadeTimer <= 0 then
            ClientScheduler.cancel(self.updateHitTaskId)
            self.updateHitTaskId = nil

            self.playerHit.Alpha = 0
            -- 隐藏命中
            self.playerHit.Visible = false
            -- 显示准星
            self.playerCrosshatch.Visible = true
        end
        self.playerHit.Alpha = fadeTimer
    end, 0, 0.06) -- 每帧更新一次
end

return PlayerStateHud.New(script.Parent, uiConfig)