-- ConfigLoader.lua
-- 负责加载所有配置文件，并将其数据实例化为对应的Type对象
-- 这是一个单例模块，在游戏启动时初始化，为其他系统提供统一的配置数据访问接口

local MainStorage = game:GetService('MainStorage')

-- 引用所有 Type 的定义

local ItemType = require(MainStorage.Code.Common.TypeConfig.ItemType)
local LevelType = require(MainStorage.Code.Common.TypeConfig.LevelType)
local PlayerInitType = require(MainStorage.Code.Common.TypeConfig.PlayerInitType)
local SceneNodeType = require(MainStorage.Code.Common.TypeConfig.SceneNodeType)
local LotteryType = require(MainStorage.Code.Common.TypeConfig.LotteryType) ---@type LotteryType
local ShopItemType = require(MainStorage.Code.Common.TypeConfig.ShopItemType) ---@type ShopItemType
local TeleportPointType = require(MainStorage.Code.Common.TypeConfig.TeleportPointType) ---@type TeleportPointType
local EquipmentType = require(MainStorage.Code.Common.TypeConfig.EquipmentType) ---@type EquipmentType
local ProfessionType = require(MainStorage.Code.Common.TypeConfig.ProfessionType) ---@type ProfessionType
local SkillType = require(MainStorage.Code.Common.TypeConfig.SkillType) ---@type SkillType
local BuffType = require(MainStorage.Code.Common.TypeConfig.BuffType) ---@type BuffType
local MonsterType = require(MainStorage.Code.Common.TypeConfig.MonsterType) ---@type MonsterType
-- 引用所有 Config 的原始数据
local ItemTypeConfig = require(MainStorage.Code.Common.Config.ItemTypeConfig)
-- local SkillConfig = require(MainStorage.Code.Common.Config.SkillConfig) -- 旧版技能配置，保留注释
local LevelConfig = require(MainStorage.Code.Common.Config.LevelConfig)
local SceneNodeConfig = require(MainStorage.Code.Common.Config.SceneNodeConfig)
local PlayerInitConfig = require(MainStorage.Code.Common.Config.PlayerInitConfig)
local LotteryConfig = require(MainStorage.Code.Common.Config.LotteryConfig)
local ShopItemConfig = require(MainStorage.Code.Common.Config.ShopItemConfig)
local TeleportPointConfig = require(MainStorage.Code.Common.Config.TeleportPointConfig)
local EquipmentConfig = require(MainStorage.Code.Common.Config.EquipmentConfig)
local ProfessionConfig = require(MainStorage.Code.Common.Config.ProfessionConfig)
local SkillConfigConfig = require(MainStorage.Code.Common.Config.SkillConfigConfig)
local BuffConfig = require(MainStorage.Code.Common.Config.BuffConfig)
local MonsterConfigConfig = require(MainStorage.Code.Common.Config.MonsterConfigConfig)


---@class ConfigLoader
local ConfigLoader = {}

-- 用来存放实例化后的配置对象
ConfigLoader.Items = {}
ConfigLoader.Skills = {}
ConfigLoader.Equipments = {}
ConfigLoader.Professions = {}
ConfigLoader.Buffs = {}
ConfigLoader.Monsters = {}
ConfigLoader.Levels = {}
ConfigLoader.LevelNodeRewards = {} -- 新增关卡节点奖励配置存储
ConfigLoader.SceneNodes = {}
ConfigLoader.TeleportPoints = {} -- 新增传送点配置存储
ConfigLoader.PlayerInits = {}
ConfigLoader.Lotteries = {} -- 新增抽奖配置存储
ConfigLoader.ShopItems = {} -- 新增商城商品配置存储
ConfigLoader.MiniShopItems = {} -- 迷你币商品映射表：miniItemId -> ShopItemType
ConfigLoader.Monsters = {}

--- 一个通用的加载函数，避免重复代码
---@param configData table 从Config目录加载的原始数据
---@param typeClass table|nil 从TypeConfig目录加载的类，可以为nil
---@param storageTable table 用来存储实例化后对象的表
---@param configName string 配置的名称，用于日志打印
function ConfigLoader.LoadConfig(configData, typeClass, storageTable, configName)
    -- 检查Type定义是否是一个有效的类（包含New方法）
    if not typeClass or not typeClass.New then
        print(string.format("警告：未找到 %s 的有效 Type 类。原始数据将被存储", configName))
        -- 如果没有对应的Type类，可以选择直接存储原始数据
        for id, data in pairs(configData.Data) do
            storageTable[id] = data
        end
        return
    end

    -- 实例化配置
    for id, data in pairs(configData.Data) do
        -- 使用配置的键 (例如 "加速卡", "火球") 作为唯一ID
        storageTable[id] = typeClass.New(data)
    end
end

-- 模块初始化函数，一次性加载所有配置
function ConfigLoader.Init()
    ConfigLoader.LoadConfig(ItemTypeConfig, ItemType, ConfigLoader.Items, "Item")
    ConfigLoader.LoadConfig(LevelConfig, LevelType, ConfigLoader.Levels, "Level")
    ConfigLoader.LoadConfig(PlayerInitConfig, PlayerInitType, ConfigLoader.PlayerInits, "PlayerInit")
    ConfigLoader.LoadConfig(SceneNodeConfig, SceneNodeType, ConfigLoader.SceneNodes, "SceneNode")
    ConfigLoader.LoadConfig(LotteryConfig, LotteryType, ConfigLoader.Lotteries, "Lottery")
    ConfigLoader.LoadConfig(TeleportPointConfig, TeleportPointType, ConfigLoader.TeleportPoints, "TeleportPoint")
    ConfigLoader.LoadConfig(EquipmentConfig, EquipmentType, ConfigLoader.Equipments, "Equipment")
    ConfigLoader.LoadConfig(ProfessionConfig, ProfessionType, ConfigLoader.Professions, "Profession")
    ConfigLoader.LoadConfig(SkillConfigConfig, SkillType, ConfigLoader.Skills, "Skill")
    ConfigLoader.LoadConfig(BuffConfig, BuffType, ConfigLoader.Buffs, "Buff")
    ConfigLoader.LoadConfig(MonsterConfigConfig, MonsterType, ConfigLoader.Monsters, "Monster")
    -- 构建迷你币商品映射表
    ConfigLoader.LoadConfig(ShopItemConfig, ShopItemType, ConfigLoader.ShopItems, "ShopItem")

    ConfigLoader.BuildMiniShopMapping()
    
    print("配置装载结束")

    -- ConfigLoader.LoadConfig(ItemQualityConfig, nil, ConfigLoader.ItemQualities, "ItemQuality") -- 暂无ItemQualityType
    -- ConfigLoader.LoadConfig(MailConfig, nil, ConfigLoader.Mails, "Mail") -- 暂无MailType
    -- ConfigLoader.LoadConfig(NpcConfig, nil, ConfigLoader.Npcs, "Npc") -- 暂无NpcType
end

--- 构建迷你币商品映射表
--- 提取所有配置了迷你币支付且有miniItemId的商品，建立miniItemId -> ShopItemType的映射
function ConfigLoader.BuildMiniShopMapping()
    local count = 0
    
    for shopItemId, shopItem in pairs(ConfigLoader.ShopItems) do
        -- 检查是否配置了迷你币类型且有有效的miniItemId
        if shopItem.price and 
           shopItem.price.miniCoinType == "迷你币" and
           shopItem.specialProperties and 
           shopItem.specialProperties.miniItemId and 
           shopItem.specialProperties.miniItemId > 0 then
            
            local miniItemId = shopItem.specialProperties.miniItemId
            
            -- 检查是否有重复的miniItemId
            if ConfigLoader.MiniShopItems[miniItemId] then
                print(string.format("警告：发现重复的迷你商品ID %d，商品：%s 和 %s", 
                    miniItemId, 
                    ConfigLoader.MiniShopItems[miniItemId].configName,
                    shopItem.configName))
            end
            
            -- 建立映射关系
            ConfigLoader.MiniShopItems[miniItemId] = shopItem
            count = count + 1
            
            -- print(string.format("注册迷你币商品：ID=%d, 名称=%s, 价格=%d迷你币", 
            --     miniItemId, 
            --     shopItem.configName, 
            --     shopItem.price.miniCoinAmount or 0))
        end
    end
    
    print(string.format("迷你币商品映射表构建完成，共注册 %d 个商品", count))
end

--- 提供给外部系统访问实例化后数据的接口
---@param id string
---@return ItemType
function ConfigLoader.GetItem(id)
    return ConfigLoader.Items[id]
end

---@return table<string, ItemType>
function ConfigLoader.GetAllItems()
    return ConfigLoader.Items
end


function ConfigLoader.GetLevel(id)
    return ConfigLoader.Levels[id]
end



--- 获取关卡节点奖励配置数量
---@return number 配置数量
function ConfigLoader.GetLevelNodeRewardCount()
    local count = 0
    for _ in pairs(ConfigLoader.LevelNodeRewards) do
        count = count + 1
    end
    return count
end

--- 检查指定ID的关卡节点奖励配置是否存在
---@param id string 配置ID
---@return boolean 是否存在
function ConfigLoader.HasLevelNodeReward(id)
    return ConfigLoader.LevelNodeRewards[id] ~= nil
end

---@param id string
---@return PlayerInitType
function ConfigLoader.GetPlayerInit(id)
    return ConfigLoader.PlayerInits[id]
end

---@return table<string, PlayerInitType>
function ConfigLoader.GetAllPlayerInits()
    return ConfigLoader.PlayerInits
end

---@param id string
---@return SceneNodeType
function ConfigLoader.GetSceneNode(id)
    return ConfigLoader.SceneNodes[id]
end

---@return table<string, SceneNodeType>
function ConfigLoader.GetAllSceneNodes()
    return ConfigLoader.SceneNodes
end

--- 按所属场景与场景类型筛选场景节点
---@param belongScene string|nil 所属场景，nil 表示不过滤
---@param sceneType string|nil 场景类型，nil 表示不过滤
---@return SceneNodeType[] 满足条件的场景节点列表
function ConfigLoader.GetSceneNodesBy(belongScene, sceneType)
    local result = {}
    for _, node in pairs(ConfigLoader.SceneNodes) do
        local matchScene = (belongScene == nil) or (node.belongScene == belongScene)
        local matchType = (sceneType == nil) or (node.sceneType == sceneType)
        if matchScene and matchType then
            table.insert(result, node)
        end
    end
    return result
end








---@param id string
---@return LotteryType
function ConfigLoader.GetLottery(id)
    return ConfigLoader.Lotteries[id]
end

---@return table<string, LotteryType>
function ConfigLoader.GetAllLotteries()
    return ConfigLoader.Lotteries
end

---@param id string
---@return ShopItemType
function ConfigLoader.GetShopItem(id)
    return ConfigLoader.ShopItems[id]
end

---@return table<string, ShopItemType>
function ConfigLoader.GetAllShopItems()
    return ConfigLoader.ShopItems
end

---@param id string
---@return TeleportPointType
function ConfigLoader.GetTeleportPoint(id)
    return ConfigLoader.TeleportPoints[id]
end

---@return table<string, TeleportPointType>
function ConfigLoader.GetAllTeleportPoints()
    return ConfigLoader.TeleportPoints
end

---@param category string 商品分类（如"道具"、"装备"等）
---@return ShopItemType[] 该分类下的所有商品（按品质排序）
function ConfigLoader.GetShopItemsByCategory(category)
    local itemsArray = {}
    
    -- 收集该分类下的所有商品
    for id, shopItem in pairs(ConfigLoader.ShopItems) do
        if shopItem.category == category then
            table.insert(itemsArray, shopItem)
        end
    end
    
    -- 按品质等级排序
    local qualityOrder = {UR = 1, SSR = 2, SR = 3, R = 4, N = 5}
    table.sort(itemsArray, function(a, b)
        local qualityA = a:GetBackgroundStyle() or "N"
        local qualityB = b:GetBackgroundStyle() or "N"
        local orderA = qualityOrder[qualityA] or 6
        local orderB = qualityOrder[qualityB] or 6
        return orderA < orderB
    end)
    
    return itemsArray
end

--- 根据迷你商品ID获取对应的商城商品配置
---@param miniItemId number 迷你商品ID
---@return ShopItemType|nil 商城商品配置
function ConfigLoader.GetMiniShopItem(miniItemId)
    return ConfigLoader.MiniShopItems[miniItemId]
end

--- 获取所有迷你币商品映射
---@return table<number, ShopItemType> 迷你币商品映射表
function ConfigLoader.GetAllMiniShopItems()
    return ConfigLoader.MiniShopItems
end

--- 检查指定迷你商品ID是否存在
---@param miniItemId number 迷你商品ID
---@return boolean 是否存在
function ConfigLoader.HasMiniShopItem(miniItemId)
    return ConfigLoader.MiniShopItems[miniItemId] ~= nil
end

--- 获取迷你币商品数量
---@return number 迷你币商品数量
function ConfigLoader.GetMiniShopItemCount()
    local count = 0
    for _ in pairs(ConfigLoader.MiniShopItems) do
        count = count + 1
    end
    return count
end

---@param id string
---@return MonsterType
function ConfigLoader.GetMonster(id)
    return ConfigLoader.Monsters[id]
end

---@return table<string, MonsterType>
function ConfigLoader.GetAllMonsters()
    return ConfigLoader.Monsters
end

return ConfigLoader 