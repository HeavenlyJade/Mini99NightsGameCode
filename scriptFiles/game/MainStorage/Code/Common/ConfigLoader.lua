-- ConfigLoader.lua
-- 负责加载所有配置文件，并将其数据实例化为对应的Type对象
-- 这是一个单例模块，在游戏启动时初始化，为其他系统提供统一的配置数据访问接口

local MainStorage = game:GetService('MainStorage')

-- 引用所有 Type 的定义

local ItemType = require(MainStorage.Code.Common.TypeConfig.ItemType)
local LevelType = require(MainStorage.Code.Common.TypeConfig.LevelType)
local SceneNodeType = require(MainStorage.Code.Common.TypeConfig.SceneNodeType) ---@type SceneNodeType
local LotteryType = require(MainStorage.Code.Common.TypeConfig.LotteryType) ---@type LotteryType
local ShopItemType = require(MainStorage.Code.Common.TypeConfig.ShopItemType) ---@type ShopItemType
local EquipmentType = require(MainStorage.Code.Common.TypeConfig.EquipmentType) ---@type EquipmentType
local ProfessionType = require(MainStorage.Code.Common.TypeConfig.ProfessionType) ---@type ProfessionType
local SkillType = require(MainStorage.Code.Common.TypeConfig.SkillType) ---@type SkillType
local BuffType = require(MainStorage.Code.Common.TypeConfig.BuffType) ---@type BuffType
local MonsterType = require(MainStorage.Code.Common.TypeConfig.MonsterType) ---@type MonsterType
local TaskType = require(MainStorage.Code.Common.TypeConfig.TaskType) ---@type TaskType
local AchievementType = require(MainStorage.Code.Common.TypeConfig.AchievementType) ---@type AchievementType
-- 引用所有 Config 的原始数据
local ItemTypeConfig = require(MainStorage.Code.Common.Config.ItemTypeConfig)
local LevelConfig = require(MainStorage.Code.Common.Config.LevelConfig)
local SceneNodeConfig = require(MainStorage.Code.Common.Config.SceneNodeConfigConfig)
local LotteryConfig = require(MainStorage.Code.Common.Config.LotteryConfig)
local ShopItemConfig = require(MainStorage.Code.Common.Config.ShopItemConfig)
local EquipmentConfig = require(MainStorage.Code.Common.Config.EquipmentConfig)
local ProfessionConfig = require(MainStorage.Code.Common.Config.ProfessionConfig)
local SkillConfigConfig = require(MainStorage.Code.Common.Config.SkillConfigConfig)
local BuffConfig = require(MainStorage.Code.Common.Config.BuffConfig)
local MonsterConfigConfig = require(MainStorage.Code.Common.Config.MonsterConfigConfig)
local TaskConfigConfig = require(MainStorage.Code.Common.Config.TaskConfigConfig)
local AchievementConfigConfig = require(MainStorage.Code.Common.Config.AchievementConfigConfig)


---@class ConfigLoader
local ConfigLoader = {}

-- 用来存放实例化后的配置对象
ConfigLoader.Items = {}
ConfigLoader.Skills = {}
ConfigLoader.Equipments = {}
ConfigLoader.Professions = {}
ConfigLoader.Buffs = {}
ConfigLoader.Levels = {}
ConfigLoader.LevelNodeRewards = {} -- 新增关卡节点奖励配置存储
ConfigLoader.SceneNodes = {}
ConfigLoader.TeleportPoints = {} -- 新增传送点配置存储
ConfigLoader.PlayerInits = {}
ConfigLoader.Lotteries = {} -- 新增抽奖配置存储
ConfigLoader.ShopItems = {} -- 新增商城商品配置存储
ConfigLoader.MiniShopItems = {} -- 迷你币商品映射表：miniItemId -> ShopItemType
ConfigLoader.Monsters = {}
ConfigLoader.Tasks = {} -- 新增任务配置存储
ConfigLoader.Achievements = {} -- 新增成就配置存储 

--- 一个通用的加载函数，避免重复代码
---@param configData table 从Config目录加载的原始数据
---@param typeClass table|nil 从TypeConfig目录加载的类，可以为nil
---@param storageTable table 用来存储实例化后对象的表
---@param configName string 配置的名称，用于日志打印
function ConfigLoader.LoadConfig(configData, typeClass, storageTable, configName)
    -- 存储目标表校验
    if type(storageTable) ~= "table" then
        print(string.format("错误：%s 存储目标未初始化（storageTable 不是表）", tostring(configName)))
        return
    end
    -- 统一获取数据源：兼容 { Data = { ... } } 与直接返回 { ... } 两种结构
    local dataset = (configData and (configData.Data or configData)) or nil
    if dataset == nil then
        print(string.format("错误：%s 配置数据为空或结构不正确", tostring(configName)))
        return
    end

    -- 若无有效 Type 类，则直接存原始数据
    if not typeClass or not typeClass.New then
        print(string.format("警告：未找到 %s 的有效 Type 类。原始数据将被存储", tostring(configName)))
        for id, data in pairs(dataset) do
            storageTable[id] = data
        end
        return
    end

    -- 实例化配置
    for id, data in pairs(dataset) do
        storageTable[id] = typeClass.New(data)
    end
end

-- 模块初始化函数，一次性加载所有配置
function ConfigLoader.Init()
    ConfigLoader.LoadConfig(ItemTypeConfig, ItemType, ConfigLoader.Items, "Item")
    ConfigLoader.LoadConfig(LevelConfig, LevelType, ConfigLoader.Levels, "Level")
    ConfigLoader.LoadConfig(SceneNodeConfig, SceneNodeType, ConfigLoader.SceneNodes, "SceneNode")
    ConfigLoader.LoadConfig(LotteryConfig, LotteryType, ConfigLoader.Lotteries, "Lottery")
    ConfigLoader.LoadConfig(EquipmentConfig, EquipmentType, ConfigLoader.Equipments, "Equipment")
    ConfigLoader.LoadConfig(ProfessionConfig, ProfessionType, ConfigLoader.Professions, "Profession")
    ConfigLoader.LoadConfig(SkillConfigConfig, SkillType, ConfigLoader.Skills, "Skill")
    ConfigLoader.LoadConfig(BuffConfig, BuffType, ConfigLoader.Buffs, "Buff")
    ConfigLoader.LoadConfig(MonsterConfigConfig, MonsterType, ConfigLoader.Monsters, "Monster")
    ConfigLoader.LoadConfig(TaskConfigConfig, TaskType, ConfigLoader.Tasks, "Task")
    ConfigLoader.LoadConfig(AchievementConfigConfig, AchievementType, ConfigLoader.Achievements, "Achievement")
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

---@param id string
---@return TaskType
function ConfigLoader.GetTask(id)
    return ConfigLoader.Tasks[id]
end

---@return table<string, TaskType>
function ConfigLoader.GetAllTasks()
    return ConfigLoader.Tasks
end

--- 按任务类型筛选任务
---@param taskType string 任务类型
---@return TaskType[] 满足条件的任务列表
function ConfigLoader.GetTasksByType(taskType)
    local result = {}
    for _, task in pairs(ConfigLoader.Tasks) do
        if task.taskType == taskType then
            table.insert(result, task)
        end
    end
    return result
end

--- 按任务分类筛选任务
---@param taskCategory string 任务分类
---@return TaskType[] 满足条件的任务列表
function ConfigLoader.GetTasksByCategory(taskCategory)
    local result = {}
    for _, task in pairs(ConfigLoader.Tasks) do
        if task.taskCategory == taskCategory then
            table.insert(result, task)
        end
    end
    return result
end

--- 按任务类型和分类筛选任务
---@param taskType string|nil 任务类型，nil表示不过滤
---@param taskCategory string|nil 任务分类，nil表示不过滤
---@return TaskType[] 满足条件的任务列表
function ConfigLoader.GetTasksBy(taskType, taskCategory)
    local result = {}
    for _, task in pairs(ConfigLoader.Tasks) do
        local matchType = (taskType == nil) or (task.taskType == taskType)
        local matchCategory = (taskCategory == nil) or (task.taskCategory == taskCategory)
        if matchType and matchCategory then
            table.insert(result, task)
        end
    end
    return result
end

---@param id string
---@return ProfessionType
function ConfigLoader.GetProfession(id)
    return ConfigLoader.Professions[id]
end

---@return table<string, ProfessionType>
function ConfigLoader.GetAllProfessions()
    return ConfigLoader.Professions
end

--- 按星级筛选职业
---@param star number|nil 星级，nil表示不过滤
---@return ProfessionType[] 满足条件的职业列表
function ConfigLoader.GetProfessionsByStar(star)
    local result = {}
    for _, profession in pairs(ConfigLoader.Professions) do
        if star == nil or profession.star == star then
            table.insert(result, profession)
        end
    end
    return result
end

---@param id string
---@return AchievementType
function ConfigLoader.GetAchievement(id)
    return ConfigLoader.Achievements[id]
end

---@return table<string, AchievementType>
function ConfigLoader.GetAllAchievements()
    return ConfigLoader.Achievements
end

--- 按星级筛选成就
---@param starLevel number|nil 星级，nil表示不过滤
---@return AchievementType[] 满足条件的成就列表
function ConfigLoader.GetAchievementsByStar(starLevel)
    local result = {}
    for _, achievement in pairs(ConfigLoader.Achievements) do
        if starLevel == nil or achievement.starLevel == starLevel then
            table.insert(result, achievement)
        end
    end
    return result
end

--- 按排序获取成就列表
---@return AchievementType[] 按排序排列的成就列表
function ConfigLoader.GetAchievementsBySort()
    local result = {}
    for _, achievement in pairs(ConfigLoader.Achievements) do
        table.insert(result, achievement)
    end
    -- 按排序字段排序
    table.sort(result, function(a, b)
        return a:GetSortKey() < b:GetSortKey()
    end)
    return result
end

return ConfigLoader 