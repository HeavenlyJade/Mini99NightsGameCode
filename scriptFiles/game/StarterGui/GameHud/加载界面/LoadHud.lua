------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-13
-- @模块名称:      LoadHud
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
---@type ClientScheduler
local ClientScheduler = require(MainStorage.code.client.clientEvent.ClientScheduler)
------------------------------------------------------------------------------------
---@class LoadHud:ViewBase
local LoadHud = ClassMgr.Class("LoadHud", ViewBase)

local uiConfig = {
    uiName = "LoadHud",
    layer = -1,
    hideOnInit = true, -- 初始隐藏，当玩家靠近NPC时显示
}


-- 初始化
function LoadHud:OnInit(config)
    local ui_size = gg.get_ui_size()
    self:Get("背景").node.Size = Vector2.New(ui_size.x, ui_size.y)

    self.loadImg = self:Get("加载中").node

    self.loadText_1 = self:Get("撑过99天").node
    self.loadText_2 = self:Get("拯救在森林里失散的4名小孩").node

    self.updateTaskId = nil
    ClientEventManager.Subscribe("showLoadGameUi", function(evt)
        self:Open()
        self:ShowLoad()
    end)

    ClientEventManager.Subscribe("closeLoadGameUi", function(evt)
        if self.updateTaskId then
            ClientScheduler.cancel(self.updateTaskId)
            self.updateTaskId = nil
        end
        self:Close()
    end)
    self:Close()
end




-- 显示被命中图片
function LoadHud:ShowLoad()
    -- 显示UI
    self.loadImg.Visible = false
    self.loadText_1.Visible = false
    self.loadText_2.Visible = false
    if self.updateTaskId then
        ClientScheduler.cancel(self.updateTaskId)
        self.updateTaskId = nil
    end

    -- 一共6秒

    -- 注册更新任务
    local currentTime = 0
    local img1Printed = false
    local img2Printed = false
    self.updateTaskId = ClientScheduler.add(function()
        currentTime = currentTime + 0.06

        local img1, img2, img3 =  self.loadText_1, self.loadText_2,self.loadImg
        local maxAlpha = 255
        local r, g, b = 220, 0, 0  -- 假设使用白色，可根据需要修改

        -- 重置所有图片状态
        img1.Visible = false
        img2.Visible = false
        img3.Visible = false

        -- 9秒后：只显示第三张图片
        if currentTime >= 9 then
            img3.Visible = true
            return
        end

        -- 0-4秒：处理第一张图片
        if currentTime < 4 then
            img1.Visible = true
            local alpha
            -- 0-2秒：第一张图片淡入
            if currentTime <= 2 then
                alpha = maxAlpha * (currentTime / 2)
                -- 首次执行时打印（只执行一次）
                if not img1Printed then
                    ClientEventManager.Publish("PlaySound", {
                        soundAssetId = "sandboxId://music/战斗场景/进入生存加载提示音.ogg",
                    })

                    img1Printed = true
                end
                -- 2-4秒：第一张图片保持完全显示
            else
                alpha = maxAlpha
            end

            img1.TitleColor = ColorQuad.New(r, g, b, math.min(alpha, maxAlpha))
        end
        -- 4-9秒：处理第二张图片
        if currentTime >= 4 and currentTime < 9 then
            img1.Visible = true
            img2.Visible = true
            local alpha

            -- 4-6秒：第二张图片淡入
            if currentTime <= 6 then
                alpha = maxAlpha * ((currentTime - 4) / 2)
                -- 首次执行时打印（只执行一次）
                if not img2Printed then
                    ClientEventManager.Publish("PlaySound", {
                        soundAssetId = "sandboxId://music/战斗场景/进入生存加载提示音.ogg"
                    })
                    img2Printed = true
                end
                -- 6-9秒：第二张图片保持完全显示
            else
                alpha = maxAlpha
            end

            img2.TitleColor = ColorQuad.New(r, g, b, math.min(alpha, maxAlpha))

            -- 6-9秒同时保持第一张图片显示
            if currentTime >= 6 then
                img1.Visible = true
                img1.TitleColor = ColorQuad.New(r, g, b, maxAlpha)
            end
        end
    end, 0, 0.06) -- 每帧更新一次


end

function LoadHud:updateImageFades(currentTime)

end

return LoadHud.New(script.Parent, uiConfig)