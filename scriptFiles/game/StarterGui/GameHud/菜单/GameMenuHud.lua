------------------------------------------------------------------------------------
-- -*- coding: utf-8 -*-
--
-- @作者:         zhenghao
-- @创建日期:      2025-09-13
-- @模块名称:      GameMenuHud
-- @描述:         游戏交互界面
-- @版本:         v1.0
------------------------------------------------------------------------------------
-- 引入管理对象
local game = game
local script = script
local Vector2 = Vector2
local MainStorage = game:GetService("MainStorage")
local WorldService = game:GetService('WorldService')
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
---@class GameMenuHud:ViewBase
local GameMenuHud = ClassMgr.Class("GameMenuHud", ViewBase)

local uiConfig = {
    uiName = "GameMenuHud",
    layer = -1,
    hideOnInit = true, -- 初始隐藏，当玩家靠近NPC时显示
}
-- 战斗逻辑界面

-- 初始化 战斗逻辑
function GameMenuHud:OnInit(config)
    -- 玩家选择按键
    self.lastIdx = 0
    -- 存活天数
    self.curDay = self:Get("天数").node
    -- 物品列表
    for i = 1, 8 do
        -- 物品路径
        local btnStr = "物品列表/物品按钮_" .. i
        -- 物品名称
        self["bagItemName" .. i] = self:Get(btnStr .. "/物品名称").node
        -- 物品数量
        self["bagItemNum" .. i] = self:Get(btnStr .. "/数量").node
        -- 点击按钮
        self["bagItemImg" .. i] = self:Get(btnStr, ViewButton)
        -- 默认点击按钮图片为未选择
        self["bagItemImg" .. i].img.Icon = common_const.SELECT_BOX["未选中"]
        -- 点击物品按钮事件
        self["bagItemImg" .. i].clickCb = function(ui, button)
            self:upDataBtnAndSwitchEquip(i)
        end
    end
    -- 注册界面事件
    self:RegisterGuiEvent()
    -- 注册键盘
    self:RegisterBtnEventFunction()

    -- 刷新背包Ui
    self:refreshBagUi()
    -- 默认关闭ui
    self:Close()
end

-- 注册界面事件
function GameMenuHud:RegisterGuiEvent()
    -- 玩家 离开按钮
    self:Get("离开按钮", ViewButton).clickCb = function(ui, button)
        -- 更新玩家位置
        ClientEventManager.SendToServer("PlayerTpMatch", {
            spawnPos = Vector3.New(0, 200, 0),
            scene = "MainCity",
        })
    end

    -- 服务端通知客户端更新当前天数
    ClientEventManager.Subscribe("UpDataGameDay", function(evt)
        self.curDay.Title = string.format("第%s天", evt.day)
    end)
    -- 玩家更新背包Ui
    ClientEventManager.Subscribe("PlayerUpFightUi", function(evt)
        local bagInfo = evt.bagInfo
        -- 更新背包
        self:refreshBagUi(bagInfo)
    end)
    -- 选择世界掉落物品显示名称
    ClientEventManager.Subscribe("ShowWorldItemData", function(evt)
        self:SelectWorldItem(evt.inputObj)
        GameMenuHud:tryAoeRayGround(evt.inputObj.Position.x, evt.inputObj.Position.y)
    end)

    -- 点击世界物品
    ClientEventManager.Subscribe("MouseButton", function(evt)
        if evt.left and evt.isDown and evt.inputObj then
            self:ClickWorldItem(evt.inputObj)
            self:AoeRayRelease()
        end
    end)

    -- 玩家切换场景
    ClientEventManager.Subscribe("PlayerSwitchScene", function(evt)
        if evt.sceneType == common_const.SCENE_TYPE[2] then
            gg.client_scene_name = evt.name
            gg.client_scene_Type = evt.sceneType
            self:Open()
        else
            self:Close()
        end
    end)
    -- 通知客户端玩家开始生存游戏
    ClientEventManager.Subscribe("GameStart", function(evt)
        gg.log("通知客户端玩家开始生存游戏")
    end)

    -- 通知客户端玩家开始生存游戏
    ClientEventManager.Subscribe("handleAoePos", function(evt)
        self:handleAoePos(evt.args_)
    end)
end

--点选一个当前目标
function GameMenuHud:GetWorldMonster(inputObj)
    local x, y = inputObj.Position.x, inputObj.Position.y
    local ret_pick_node = nil
    local obj_list = {}     --查找范围
    for k, v in pairs(gg.clientGetContainerMonster().Children) do
        obj_list[#obj_list + 1] = v     --只找怪物
    end
    --当前点击位置
    local pick_node_
    --扩散协助选择
    for xx = 1, 10 do
        for yy = 1, 5 do
            pick_node_ = gg.UserInputService:PickObjects(x + xx * 5, y + yy * 5, obj_list)
            if pick_node_ then
                break
            end

            pick_node_ = gg.UserInputService:PickObjects(x - xx * 5, y - yy * 5, obj_list)
            if pick_node_ then
                break
            end
        end
        if pick_node_ then
            break
        end
    end
    if pick_node_ then
        --改动框的显示，明确是否被选中
        if pick_node_.ClassType == 'Actor' then
            -- 选择
            ret_pick_node = pick_node_.Name
        end
    end
    return ret_pick_node
end

-- 获取鼠标指向的物品
function GameMenuHud:GetWorldItem(inputObj)

    local ret_pick_node = nil
    -- 没有掉落物容器
    local item_container = gg.clientGetContainerItem()
    if item_container then
        -- 鼠标的位置
        local Position = inputObj.Position
        if Position == Vector3.new(0, 0, 0) then
            -- 屏幕中心点位置
            local win_size = game.WorkSpace.CurrentCamera.WindowSize
            local xx = math.floor(win_size.x * 0.5)
            local yy = math.floor(win_size.y * 0.5)
            Position = { x = xx, y = yy }
        end
        local obj_list = {}
        for k, v in pairs(item_container.Children) do
            if v.ClassType == 'Model' then
                --只找掉落物
                obj_list[#obj_list + 1] = v
                --if v.OutlineActive then
                --    v.OutlineActive = false
                --    v:ClearAllChildren()
                --end
            end
        end
        if not table.is_empty(obj_list) then
            -- 获取指定对象
            local pick_node = gg.UserInputService:PickObjects(Position.x, Position.y, obj_list)
            if not pick_node then
                for xx = 1, 5 do
                    for yy = 1, 5 do
                        pick_node = gg.UserInputService:PickObjects(Position.x + xx * 5, Position.y + yy * 5, obj_list)
                        if pick_node then
                            break
                        end
                        pick_node = gg.UserInputService:PickObjects(Position.x - xx * 5, Position.y - yy * 5, obj_list)
                        if pick_node then
                            break
                        end
                    end
                    if pick_node then
                        break
                    end
                end
            end
            if pick_node then
                -- 判断距离
                if not gg.out_distance(pick_node.Position, gg.clientGetLocalPlayer().Position, gg.client_pick_dist) then
                    if pick_node.ClassType == 'Model' then
                        ret_pick_node = pick_node
                    end
                end
            end
        end
        for k, v in pairs(obj_list) do
            if ret_pick_node ~= v then
                v.OutlineActive = false
                v:ClearAllChildren()
            end
        end
    end
    return ret_pick_node
end

-- 选择怪物
function GameMenuHud:SelectMonster(inputObj)
    local pick_nodeName = self:GetWorldMonster(inputObj)
    ClientEventManager.SendToServer("PlayerSelectTarget", {
        monsterName = pick_nodeName
    })
end

-- 选择世界物品
function GameMenuHud:ClickWorldItem(inputObj)
    local pick_node = self:GetWorldItem(inputObj)
    if pick_node then
        pick_node:ClearAllChildren()
        -- 拾取物品
        ClientEventManager.SendToServer("checkWorldDropItem", {
            item = pick_node
        })
    end
end

-- 选择世界物品
function GameMenuHud:SelectWorldItem(inputObj)
    local pick_node = self:GetWorldItem(inputObj)
    if pick_node then
        pick_node.OutlineActive = true
        -- 克隆名称
        local title = MainStorage["模型列表"]["名字标签"]["物品信息"]
        local name_title = title:Clone()
        name_title.Parent = pick_node
        name_title.Name = "item_title"
        name_title.LocalPosition = title.LocalPosition + Vector3.New(0, pick_node.Center.y + 40 / pick_node.Center.y, 0)
        name_title["物品名称"].Title = pick_node.Name
    end
end

--重新刷新ui (数据有变化后)
function GameMenuHud:refreshBagUi(items)
    items = items or {}
    for i = 1, 8 do
        local itemInfo = items[i]
        if itemInfo then
            self["bagItemName" .. i].Title = itemInfo.itemType.name
            self["bagItemNum" .. i].Title = tostring(itemInfo.amount)
        else
            self["bagItemName" .. i].Title = ""
            self["bagItemNum" .. i].Title = ""
        end
    end
end

-- 注册事件
function GameMenuHud:RegisterBtnEventFunction()
    -- 监听按键事件
    ClientEventManager.Subscribe("PressKey", function(data)
        if not data.isDown then
            -- 按键抬起时，检查是否是之前按下的数字键
            if data.key == Enum.KeyCode.LeftShift.Value then
                ClientEventManager.SendToServer("PlayerShiftMove", {
                    start = false
                })
            end
        else
            if common_const.BAG_KEYCODE[data.key] then
                ClientEventManager.SendToServer("switchMonsterAnimator", {
                    idx = common_const.BAG_KEYCODE[data.key]
                })
                ClientEventManager.SendToServer("testPlayerAnimator", {
                    idx = common_const.BAG_KEYCODE[data.key]
                })
            elseif data.key == Enum.KeyCode.LeftShift.Value then
                ClientEventManager.SendToServer("PlayerShiftMove", {
                    start = true
                })
            end
        end
    end)

    -- 监听按键事件
    ClientEventManager.Subscribe("PressKey", function(data)
        if gg.client_scene_Type == "战斗场景" then
            if not data.isDown then
                -- 按键抬起时，检查是否是之前按下的数字键
            else
                if common_const.BAG_KEYCODE[data.key] then
                    self:upDataBtnAndSwitchEquip(common_const.BAG_KEYCODE[data.key])
                elseif data.key == Enum.KeyCode.Q.Value then
                    -- Enum.KeyCode.Q.Value 丢弃
                    ClientEventManager.SendToServer("DisHandItem", {
                        idx = self.lastIdx
                    })
                elseif data.key == Enum.KeyCode.E.Value then
                    -- Enum.KeyCode.E.Value 交互
                    self:ClickWorldItem(data.inputObj)
                elseif data.key == Enum.KeyCode.R.Value then
                    -- R 换子弹
                    ClientEventManager.SendToServer("PlayerSwitchAmmunition", {})
                end
            end
        end
    end)
    -- 监听按键事件 战斗
    ClientEventManager.Subscribe("MouseButton", function(data)
        if data.left then
            if data.isDown then
                self:SelectMonster(data.inputObj)
            end
        end
    end)
end

-- 更新按钮并且切换武器
function GameMenuHud:upDataBtnAndSwitchEquip(idx)
    -- 上次选中与当前选中相同则 清空当前选中
    if self.lastIdx == idx then
        self.lastIdx = 0
    else
        self.lastIdx = idx
    end

    -- 设置选择按钮为选中状态，其他按钮为未选中状态
    for k = 1, 8 do
        if k == self.lastIdx then
            if self["bagItemName" .. k].Title ~= "" then
                self["bagItemImg" .. k].normalImg = common_const.SELECT_BOX["选中"]
                self["bagItemImg" .. k].img.Icon = common_const.SELECT_BOX["选中"]
            end
        else
            self["bagItemImg" .. k].normalImg = common_const.SELECT_BOX["未选中"]
            self["bagItemImg" .. k].img.Icon = common_const.SELECT_BOX["未选中"]
        end
    end
    -- 发送服务端用户切换武器
    ClientEventManager.SendToServer("switchEquip", {
        idx = idx
    })
end



--选择建筑物
function GameMenuHud:handleAoePos(args_)
    if not gg.client_aoe_cylinder then
        local aoe_box_ = gg.cloneFromArchitecture(args_.name .. "投影")
        aoe_box_.Parent = game.WorkSpace
        aoe_box_.Name = args_.name
        aoe_box_.OutlineActive = true
        aoe_box_.CollideGroupID = 6
        aoe_box_.CanCollide = true
        aoe_box_.CanTouch = true
        aoe_box_.Touched:Connect(function(node)
            gg.log("Touched",node)
        end)
        aoe_box_.TouchEnded:Connect(function(node)
            gg.log("TouchEnded",node)
        end)
        gg.client_aoe_cylinder = aoe_box_
    else
        gg.client_aoe_cylinder.Name = args_.name
        if gg.GetFromArchitecture(args_.name .. "投影") then
            gg.client_aoe_cylinder.ModelId = gg.GetFromArchitecture(args_.name .. "投影").ModelId
        end
    end
    gg.client_aoe_cylinder.LocalScale = Vector3.New(1, 1, 1)
    local pos_ = gg.getClientLocalPlayer().Position
    gg.client_aoe_cylinder.LocalPosition = Vector3.New(pos_.x, pos_.y + 1, pos_.z)
    gg.client_aoe_range = 500
end



--尝试选择技能触地位置
function GameMenuHud:tryAoeRayGround(x, y)
    if not gg.client_aoe_cylinder then
        return
    end
    ---@field RaycastClosest fun(self: WorldService, origin: Vector3, unitDir: Vector3, distance: number, isIgnoreTrigger: boolean, filterGroup: Table):
    --ReflexMap 射线段检测，返回最近的碰撞物
    -- 获取问大小
    local winSize = game.WorkSpace.CurrentCamera.WindowSize
    local ray_ = game.WorkSpace.Camera:ViewportPointToRay(x, winSize.y - y, 12800)
    WorldService = game:GetService('WorldService')
    local ret_table = WorldService:RaycastClosest(ray_.Origin, ray_.Direction, 12800, true, { 2 })
    if ret_table then
        local pos1_ = ret_table.position
        if pos1_ then
            local pos2_ = gg.getClientLocalPlayer().Position
            if gg.out_distance(pos1_, pos2_, gg.client_aoe_range) then
                gg.client_aoe_cylinder.OutlineColorIndex = 2
                gg.client_aoe_cylinder.Position = Vector3.New(pos1_.x, pos1_.y + 1, pos1_.z)
                return
            end

            gg.client_aoe_cylinder.OutlineColorIndex = 1
            gg.client_aoe_cylinder.Position = Vector3.New(pos1_.x, pos1_.y + 1, pos1_.z)
        end
    end
end

--aoe技能选择地点ok
function GameMenuHud:AoeRayRelease()
    if not gg.client_aoe_cylinder then
        return
    end

    --SBXSignal Touched (SandboxNode node, Vector3 pos, Vector3 normal)
    --模型被其他模型碰撞时，会触发一个Touched通知

    if gg.client_aoe_cylinder.OutlineColorIndex == 1 then
        local pos_ = gg.client_aoe_cylinder.Position
        gg.network_channel:FireServer({ cmd = 'cmd_aoe_select_pos', name = gg.client_aoe_cylinder.Name, x = pos_.x, y = pos_.y, z = pos_.z })
        gg.client_aoe_cylinder:Destroy()
        gg.client_aoe_cylinder = nil
    else
        -- 这个位置不可以放
    end
end

return GameMenuHud.New(script.Parent, uiConfig)