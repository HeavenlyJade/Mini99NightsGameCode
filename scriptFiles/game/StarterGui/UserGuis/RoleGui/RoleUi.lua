local script = script
local game = game
local MainStorage  = game:GetService('MainStorage')
local ClientCustomUI = require(MainStorage.code.common.customUi.ClientCustomUI) ---@type ClientCustomUI

-- 初始化职业选择路径
local function InitRolePaths(ui)
    return {
        -- 左边
        -- 刷新按钮
        refreshStoreButton = "左边底图/刷新商店",
        -- 只显示已拥有按钮
        onlyShowOwnedButton = "左边底图/显示已拥有",
        -- 只显示已拥有勾选
        onlyShowOwned = "左边底图/显示已拥有/已拥有勾选",
        -- 角色选择列表
        RoleSelectList = "左边底图/角色选择列表",

        -- 选中黄条
        YellowSelect = "选中黄条",
        -- 选择三角形
        SelectImg = "选择三角形",
        -- 职业头像
        RoleHead = "职业头像",

        -- 勾选
        HaveRoleImg = "勾选",
        -- 已装备
        EquipRole = "已装备",
        -- 星星列表
        StartList = "星星列表",
        -- 已拥有
        HaveRole = "已拥有",
        -- 购买选择
        RolePriceSelect = "购买选择",
        -- 价格
        RolePrice = "购买选择/价格",
        -- 职业名称
        RoleName = "职业名称",

        -- 中间
        -- 展示模型
        RoleModel = "中间/展示模型/职业模型",
        -- 展示立绘
        RoleImg = "中间/展示立绘",
        -- 等级需求
        RoleUpDemand = "中间/阶段需求框/需求",
        -- 装备按钮
        EquipButton = "中间/装备",
        -- 卸下装备
        UnloadButton = "中间/卸下装备",
        -- 购买按钮
        buyButton = "中间/购买",
        -- 购买按钮
        buyPrice = "中间/购买/购买价格",
        -- 购买价格
        UpDemandList = "中间/需求列表",
        -- 需求详情
        DemandDetails = "需求详情",
        -- 需求进度
        DemandProgress = "需求进度",

        -- 右边
        -- 关闭按钮
        CloseButton = "右边底图/关闭按钮",
        -- 级别列表
        LevelList = "右边底图/级别列表",

        GameEquipList = "右边底图/开局工具列表",

        Num = "数量",
        Name = "名称",

        LockedImg = "锁",

        UnlockImg = "直接解锁",

        LevelText = "级别",

        AttrList = "属性内容",

        AttrText = "属性",

        unlockedTalent = "右边底图/天赋/未解锁",

        unlockedTalentPriceButton = "右边底图/天赋/未解锁/解锁天赋价格",

        unlockedTalentPrice = "右边底图/天赋/未解锁/解锁天赋价格/价格",

        unlockedTalentReadme = "右边底图/天赋/未解锁/天赋解锁说明",

        lockedTalent = "右边底图/天赋/解锁",

        refreshTalentPriceButton = "右边底图/天赋/解锁/刷新天赋价格底图",

        refreshTalentPrice = "右边底图/天赋/解锁/刷新天赋价格底图/价格",

        TalentReadme = "右边底图/天赋/解锁/介绍底图/额外天赋介绍",

        TalentRoleHead = "右边底图/天赋/解锁/职业头像",

        ProbabilityReadme = "右边底图/天赋/概率详情介绍",
        ProbabilityReadmeClose = "右边底图/天赋/概率说明/关闭按钮",
        ProbabilityReadmeUi = "右边底图/天赋/概率说明",


    }
end

return ClientCustomUI.Load(script.Parent, InitRolePaths)