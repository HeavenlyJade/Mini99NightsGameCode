--- V109 miniw-haima
--所有配置( 其他所有的配置文件将汇总到这个模块里 )

local pairs = pairs

local EquipmentSlot = {
    ["主卡"] = {
        [1] = "主卡"
    },
    ["副卡"] = {
        [2] = "副卡1",
        [3] = "副卡2",
        [4] = "副卡3",
        [5] = "副卡4"
    }
}

local ItemTypeEnum = {
    ["武器"] = 1,
    ["装备"] = 2,
    ["消耗品"] = 3,
    ["材料"] = 4,
    ["任务"] = 5,
    ["货币"] = 6
}

-- 反向映射：数字到名称
local ItemTypeNames = {
    [1] = "武器",
    [2] = "装备", 
    [3] = "消耗品",
    [4] = "材料",
    [5] = "任务",
    [6] = "货币"
}

-- 指令执行配置
local CommandExecutionConfig = {
}

local EverDayConfig = {
}


local PlayerStatsConfig = {
    ['生命'] = 'health',
    ['最大生命值'] = 'max_health',
    ['每秒生命恢复'] = 'health_regen',
    ['饥饿度'] = 'hunger',
    ['最大饥饿值'] = 'max_hunger',
    ['每秒减少饥饿度'] = 'hunger_decay',
    ['攻击力'] = 'attack_power',
    ['防御力'] = 'defense',
    ['攻击速度'] = 'attack_speed',
    ['换单速度'] = 'switch_speed',
    ['交互速度'] = 'interact_speed',
    ['采集速度'] = 'gather_speed',
    ['砍伐速度'] = 'chop_speed',
}


--所有配置( 其他所有的配置文件将汇总到这里， 游戏逻辑代码只需要require这个文件即可 )
---@class common_config
---@field EquipmentSlot table<string, table<number, string>> 装备槽位配置
---@field ItemTypeEnum table<string, number> 物品类型枚举 (名称 -> 编号)
---@field ItemTypeNames table<number, string> 物品类型名称 (编号 -> 名称)
---@field VariableIntervalConfig table<string, table> 变量区间/阈值命令配置
local common_config = {
    EquipmentSlot = EquipmentSlot,
    ItemTypeEnum = ItemTypeEnum,
    ItemTypeNames = ItemTypeNames,
    CommandExecutionConfig = CommandExecutionConfig,
    EverDayConfig =EverDayConfig,
    PlayerStatsConfig = PlayerStatsConfig
}



return common_config
