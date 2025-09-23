------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-08
-- @模块名称:      InteractHud
-- @描述:         交互界面
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
---@class InteractHud:ViewBase
local InteractHud = ClassMgr.Class("InteractHud", ViewBase)

local uiConfig = {
    uiName = "InteractHud",
    layer = -1,
    hideOnInit = false,
}

-- 交互速度
InteractHud.interactSpeed = 6

-- 初始化 InteractHud
function InteractHud:OnInit(node, config)
    -- 交互任务
    self.interactTask = nil
    -- 交互npcID
    self.npcId = nil
    -- 交互场景
    self.npcSceneType = nil
    -- 交互框
    self.InteractButton = self:Get("交互框", ViewButton)
    -- 进度框
    self.InteractBase = self:Get("交互框/交互底框", ViewButton)
    -- 显示内容
    self.InteractText = self:Get("交互框/内容", ViewButton)

    self.InteractButton.img.Visible = true
    -- 开始点击事件
    self.InteractButton.touchBeginCb = function(ui, button)
        -- 注册交互任务
        self:OnInteractClick(ui, button)
    end
    -- 结束点击事件
    self.InteractButton.touchEndCb = function(ui, button)
        -- 关闭交互任务
        if self.interactTask then
            ClientScheduler.cancel(self.interactTask)
            self.interactTask = nil
        end
        -- 初始化进度框
        self.InteractBase.node.Size = Vector2.New(0, self.InteractBase.node.Size.y)
    end

    -- 监听按键事件
    ClientEventManager.Subscribe("PressKey", function(data)
        if not data.isDown then
            -- 按键抬起时，检查是否是之前按下的数字键
            if data.key == Enum.KeyCode.E.Value then
                -- 关闭交互任务
                if self.interactTask then
                    ClientScheduler.cancel(self.interactTask)
                    self.interactTask = nil
                end
                -- 初始化进度框
                self.InteractBase.node.Size = Vector2.New(0, self.InteractBase.node.Size.y)
            end
        else
            if data.key == Enum.KeyCode.E.Value then
                -- 注册交互任务
                if self.node.Visible then
                    self:OnInteractClick()
                end
            end
        end
    end)

    -- 初始化显示内容
    self:HideInteract()
    -- 监听NPC交互更新事件
    ClientEventManager.Subscribe("NPCInteractionUpdate", function(evt)
        if evt and evt.interactOptions and #evt.interactOptions > 0 then
            -- 显示交互界面
            self:ShowInteract(evt.interactOptions)
        else
            -- 隐藏交互界面
            self:HideInteract()
        end
    end)

end

---@param viewButton ViewButton
function InteractHud:OnInteractClick(ui, viewButton)
    if self.interactTask then
        ClientScheduler.cancel(self.interactTask)
        self.interactTask = nil
    end
    if self.npcSceneType == "主场景" then

    end
    if self.npcSceneType == "主场景" then
        gg.network_channel:FireServer({
            cmd = "InteractWithNpc",
            npcId = self.npcId
        })
    else
        self.interactTask = ClientScheduler.add(function()
            -- 交互进度x,y
            local x = self.InteractBase.node.Size.x
            local y = self.InteractBase.node.Size.y
            -- 自增交互进度x
            x = x + InteractHud.interactSpeed
            if x >= 175 then
                -- 判断npcID
                if self.npcId then
                    -- 发送交互请求到服务器
                    gg.network_channel:FireServer({
                        cmd = "InteractWithNpc",
                        npcId = self.npcId
                    })
                end
                -- 初始化进度框
                self.InteractBase.node.Size = Vector2.New(0, y)
                -- 结束任务
                ClientScheduler.cancel(self.interactTask)
                self.interactTask = nil
            else
                self.InteractBase.node.Size = Vector2.New(x, y)
            end
        end, 0, 0.1)
    end
end

---显示交互界面
---@param interactOptions NPCInteractionOption[] 交互选项列表
function InteractHud:ShowInteract(interactOptions)
    -- 初始化任务进度
    if self.interactTask then
        ClientScheduler.cancel(self.interactTask)
        self.interactTask = nil
    end
    -- 获取npc信息
    local option = interactOptions[1]
    -- 设置交互npc
    self.npcId = option.npcId
    self.npcSceneType = option.npcSceneType
    if option.npcSceneType == "主场景" then
        if option.npcName == "匹配区域左" or option.npcName == "匹配区域中" or option.npcName == "匹配区域右" then
            if option.startNum == 0 then
                -- 弹窗
                ClientEventManager.SendToServer("ClickMenu", {
                    PageName = "匹配界面"
                })
            else
                -- 加入
                ClientEventManager.SendToServer("PlayerJoinGame", {
                    spawnPos = option.spawnPos,
                    scene = "MainCity",
                })
            end
        elseif option.npcName == "宝箱" then
            self.npcSceneType = "测试场景"
            -- 交互速度
            InteractHud.interactSpeed = option.interactSpeed or InteractHud.interactSpeed
            -- 设置交互内容
            self.InteractText.node.Title = string.format("%s:打开", option.npcName)
            -- 初始化交互进度
            self.InteractBase.node.Size = Vector2.New(0, self.InteractBase.node.Size.y)
            -- 显示交互界面
            self.node.Visible = true
        else
            -- 设置交互内容
            self.InteractText.node.Title = string.format("%s:交谈", option.npcName)
            -- 初始化交互进度
            self.InteractBase.node.Size = Vector2.New(0, self.InteractBase.node.Size.y)
            -- 显示交互界面
            self.node.Visible = true
        end
    else
        -- 交互速度
        InteractHud.interactSpeed = option.interactSpeed or InteractHud.interactSpeed
        -- 设置交互内容
        self.InteractText.node.Title = string.format("%s:交谈", option.npcName)
        -- 初始化交互进度
        self.InteractBase.node.Size = Vector2.New(0, self.InteractBase.node.Size.y)
        -- 显示交互界面
        self.node.Visible = true
    end
end

---隐藏交互界面
function InteractHud:HideInteract()

    self.node.Visible = false
    self.npcId = nil
    self.InteractBase.node.Size = Vector2.New(0, self.InteractBase.node.Size.y)
end

return InteractHud.New(script.Parent, uiConfig)