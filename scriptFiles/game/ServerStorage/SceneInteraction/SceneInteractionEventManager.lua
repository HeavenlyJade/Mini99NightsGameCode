-- scriptFiles/game/ServerStorage/SceneInteraction/SceneInteractionEventManager.lua
-- 场景交互事件管理器，负责处理与场景节点相关的客户端请求
local ServerStorage = game:GetService("ServerStorage")

local MServerDataManager = require(ServerStorage.Manager.MServerDataManager) ---@type MServerDataManager
---@class SceneInteractionEventManager
local SceneInteractionEventManager = {}

--- 验证玩家
---@param evt table 事件参数
---@return MPlayer|nil 玩家对象
function SceneInteractionEventManager.ValidatePlayer(evt)
    local env_player = evt.player
    if not env_player then
        --gg.log("场景交互事件缺少玩家参数")
        return nil
    end
    local uin = env_player.uin
    if not uin then
        --gg.log("场景交互事件缺少玩家UIN参数")
        return nil
    end

    local player = MServerDataManager.getPlayerByUin(uin)
    if not player then
        --gg.log("场景交互事件找不到玩家: " .. uin)
        return nil
    end

    return player
end

--- 初始化（预留扩展点）
function SceneInteractionEventManager.Init()
    -- 预留：后续可在此注册场景交互相关事件
end
-- 已移除：事件处理与订阅，仅保留基础校验
return SceneInteractionEventManager
