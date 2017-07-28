local cmd = cmd or {}

--[[
******
* 结构体描述
* {k = "key", t = "type", s = len, l = {}}
* k 表示字段名,对应C++结构体变量名
* t 表示字段类型,对应C++结构体变量类型
* s 针对string变量特有,描述长度
* l 针对数组特有,描述数组长度,以table形式,一维数组表示为{N},N表示数组长度,多维数组表示为{N,N},N表示数组长度
* d 针对table类型,即该字段为一个table类型
* ptr 针对数组,此时s必须为实际长度

** egg
* 取数据的时候,针对一维数组,假如有字段描述为 {k = "a", t = "byte", l = {3}}
* 则表示为 变量a为一个byte型数组,长度为3
* 取第一个值的方式为 a[1][1],第二个值a[1][2],依此类推

* 取数据的时候,针对二维数组,假如有字段描述为 {k = "a", t = "byte", l = {3,3}}
* 则表示为 变量a为一个byte型二维数组,长度都为3
* 则取第一个数组的第一个数据的方式为 a[1][1], 取第二个数组的第一个数据的方式为 a[2][1]
******
]]

--游戏版本
cmd.VERSION 					= appdf.VersionValue(6,7,0,1)
--游戏标识
cmd.KIND_ID						= 516
	
--游戏人数
cmd.GAME_PLAYER					= 1

--数目定义
cmd.ITEM_COUNT 					= 9				--图标数量
cmd.ITEM_X_COUNT				= 5				--图标横坐标数量
cmd.ITEM_Y_COUNT				= 3				--图标纵坐标数量
cmd.YAXIANNUM					= 9				--压线数字

--序列帧个数
cmd.ACT_DAGU_NUM				= 29			--打鼓
cmd.ACT_QIZHIWAIT_NUM			= 43			--旗帜等待时
cmd.ACT_QIZHI_NUM 				= 53			--旗帜滚动时
cmd.ACT_TITLE_NUM				= 10			--水浒传




--进入模式
cmd.GM_NULL						= 0				--结束
cmd.GM_SHUO_MING				= 1				--说明
cmd.GM_ONE						= 2				--开奖
cmd.GM_TWO						= 3				--比倍
cmd.GM_TWO_WAIT					= 4				--等待比倍
cmd.GM_THREE					= 5				--小玛丽


--状态定义
cmd.SHZ_GAME_SCENE_FREE			= 0			--等待开始
cmd.SHZ_GAME_SCENE_ONE			= 101		--水浒传开始
cmd.SHZ_GAME_SCENE_TWO			= 102		--比大小开始
cmd.SHZ_GAME_SCENE_THREE		= 103		--小玛丽开始


cmd.Event_LoadingFinish  = "Event_LoadingFinish"

--空闲状态
cmd.SHZ_CMD_S_StatusFree = 
{
	--游戏属性
	{k="lCellScore",t="int"},				--基础积分
	--下注值	
	{k="cbBetCount",t="byte"},				--下注数量
	{k="lBetScore",t="score",l={8}}			--下注大小
}

--开始开牌
cmd.SHZ_CMD_S_StatusTwo = 
{
	--游戏属性
	{k="lCellScore",t="int"},
	{k="cbTwoMode",t="score"},
	{k="lBet",t="score"},
	{k="lOneGameScore",t="score"},
	{k="lTwoGameScore",t="score"},
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},
	--下注值
	{k="cbBetCount",t="byte"},
	{k="lBetScore",t="score",l={8}}
}

--游戏状态
cmd.SHZ_CMD_S_StatusPlay = 
{
	--下注值
	{k="cbBetCount",t="byte"},
	{k="lBetScore",t="score",l={8}}
}

--操作记录
-- cmd.MAX_OPERATION_RECORD		= 20		--操作记录条数
-- cmd.RECORD_LENGTH				= 200		--每条记录字长

--控制类型
-- cmd.CONTROL_TYPE =
-- {
-- 	"CONTINUE_3",
-- 	"CONTINUE_4",
-- 	"CONTINUE_5",
-- 	"CONTINUE_ALL",
-- 	"CONTINUE_LOST",
-- 	"CONTINUE_CANCEL"
-- }
-- cmd.CONTROL_TYPE_ENUM = ExternalFun.declarEnumWithTable(0, cmd.CONTROL_TYPE)
-- --控制结果
-- cmd.CONTROL_RESULT =
-- {
-- 	"CONTROL_SUCCEED",
-- 	"CONTROL_FAIL",
-- 	"CONTROL_CANCEL_SUCCEED",
-- 	"CONTROL_CANCEL_SUCCEED",
-- 	"CONTROL_CANCEL_INVALiD"
-- }
-- cmd.CONTROL_RESULT_ENUM = ExternalFun.declarEnumWithTable(0, cmd.CONTROL_RESULT)
-- --用户行为
-- cmd.USERACTION =
-- {
-- 	"USER_SITDOWN",
-- 	"USER_STANDUP",
-- 	"USER_OFFLINE",
-- 	"USER_RECONNECT"
-- }
-- cmd.USERACTION_ENUM = ExternalFun.declarEnumWithTable(0, cmd.USERACTION)

-- --控制信息
-- cmd.USERCONTROL = 
-- {
-- 	{k="controlType",t="int"},
-- 	{k="cbControlData",t="byte"},
-- 	{k="cbControlCount",t="byte"},
-- 	{k="cbZhongJiang",t="byte"},
-- 	{k="cbZhongJiangjian",t="byte"},
-- }

-- cmd.ROOMUSERINFO = 
-- {
-- 	{k="wChairID",t="word"},
-- 	{k="wTableID",t="word"},
-- 	{k="dwGameID",t="word"},
-- 	{k="bAndroid",t="bool"},
-- 	{k="szNickName",t="char",l={32}},
-- 	{k="cbUserStatus",t="byte"},
-- 	{k="cbGameStatus",t="byte"},
-- 	{k="lGameScore",t="score"},
-- 	{k="UserContorl",t="int"},
-- }

-- --桌子库存投入信息
-- cmd.TABLESTORAGEINPUT =
-- {
-- 	{k="wTableId",t="word"},
-- 	{k="lTableStorageInput",t="score"}
-- }

-- --查询用户结果
-- cmd.SHZ_CMD_S_RequestQueryResult = 
-- {
-- 	{k="ROOMUSERINFO",t="int"},
-- 	{k="bFind",t="bool"}
-- }

-- --用户控制
-- cmd.SHZ_CMD_S_UserControl = 
-- {
-- 	{k="dwGameID",t="word"},
-- 	{k="szNickName",t="char",l={32}},
-- 	{k="CONTROL_RESULT",t="int"},
-- 	{k="UserControl",t="int"},
-- 	{k="cbControlCount",t="byte"}
-- }

-- --用户控制完成
-- cmd.SHZ_CMD_S_UserControlComplete = 
-- {
-- 	{k="dwGameID",t="word"},
-- 	{k="szNickName",t="char",l={32}},
-- 	{k="UserControl",t="int"},
-- 	{k="cbRemainControlCount",t="byte"}
-- }

-- --控制服务器端库存信息
-- cmd.SHZ_CMD_S_ADMIN_STORAGE_INFO = 
-- {
-- 	{k="lRoomStorageStart",t="score"},
-- 	{k="lRoomStorageCurrent",t="score"},
-- 	{k="lRoomStorageInput",t="score"},
-- 	{k="lCurrentStorageTable",t="score"},
-- 	{k="lRoomStockRecoverScore",t="score"},
-- 	{k="lCurrentDeductRoom",t="score"},
-- 	{k="lMaxStorageRoom",t="score",l={2}},
-- 	{k="wStorageMulRoom",t="word",l={2}},
-- 	{k="wGameTwo",t="word"},
-- 	{k="wGameTwoDeduct",t="word"},
-- 	{k="wGameThree",t="word"},
-- 	{k="wGameThreeDeduct",t="word"},
-- }

--操作记录
-- cmd.SHZ_CMD_S_Operation_Record = 
-- {
-- 	{k="szRecord",t="char",l={0}}
-- }

--更新房间库存


--命令定义
cmd.SUB_S_GAME_START				= 100		--压线开始
cmd.SUB_S_GAME_CONCLUDE				= 101		--压线结束
cmd.SUB_S_TWO_START					= 103		--比倍开始
cmd.SUB_S_TWO_GAME_CONCLUDE			= 104		--比倍结束
cmd.SUB_S_THREE_START				= 105		--小玛丽开始
cmd.SUB_S_THREE_KAI_JIANG			= 106       --小玛丽开奖                                                                                                   
cmd.SUB_S_THREE_END					= 107		--小玛丽结束 
cmd.SUB_S_SET_BASESCORE				= 108		--设置基数
cmd.SUB_S_AMDIN_COMMAND				= 109		--系统控制
cmd.SUB_S_ADMIN_STORAGE_INFO		= 110		--刷新控制服务器
cmd.SUB_S_REQUEST_QUERY_RESULT		= 111		--查询用户结果
cmd.SUB_S_USER_CONTROL				= 112		--用户控制
cmd.SUB_S_USER_CONTROL_COMPLETE		= 113		--用户控制完成
cmd.SUB_S_OPERATION_RECORD			= 114		--操作记录
cmd.SUB_S_UPDATE_ROOM_STORAGE		= 115		--更新房间库存
cmd.SUB_S_UPDATE_ROOM_ROOMUSERLIST	= 116		--更新房间用户列表

--游戏开始
cmd.SHZ_CMD_S_GameStart = 
{
	--下注信息
	{k="lScore",t="score"},--游戏积分
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},--开奖信息
	{k="cbGameMode",t="byte"},--游戏模式
	{k="cbBounsGameCount",t="byte"}--小玛丽次数
}

--比倍开始
cmd.SHZ_CMD_S_GameTwoStart = 
{
	{k="cbOpenSize",t="byte",l={2}},--骰子
	{k="lScore",t="score"}--游戏积分
}

--小玛丽开始
cmd.SHZ_CMD_S_GameThreeStart = 
{
	{k="cbItem",t="byte",l={4}},--图标
	{k="cbBounsGameCount",t="byte"},--小玛丽次数
	{k="lScore",t="score"}--游戏积分
}

--小玛丽开奖
cmd.SHZ_CMD_S_GameThreeKaiJiang = 
{
	{k="cbIndex",t="byte"},--位置
	{k="nTime",t="int"},--倍数
	{k="lScore",t="score"}--游戏积分
}

--游戏结束
cmd.SHZ_CMD_S_OneGameConclude = 
{
	--积分变量
	{k="lCellScore",t="score"},--单元积分
	{k="lGameScore",t="score"},--游戏积分
	{k="cbItemInfo",t="byte",l={cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT,cmd.ITEM_X_COUNT}},--开奖信息
	{k="cbGameMode",t="byte"}--游戏模式
}

--命令定义
cmd.SHZ_SUB_C_TWO_MODE		= 1		--比倍模式
cmd.SHZ_SUB_C_TWO_START		= 2		--比倍开始
cmd.SHZ_SUB_C_THREE_START 	= 3		--玛丽开始
cmd.SHZ_SUB_C_TWO_GIVEUP	= 4		--放弃比倍
cmd.SHZ_SUB_C_THREE_END		= 5		--结束玛丽
cmd.SHZ_SUB_C_ONE_START		= 6     --水浒传开始
cmd.SHZ_SUB_C_ONE_END		= 7		--水浒传结束


cmd.SHZ_SUB_C_UPDATE_TABLE_STORAGE	= 28	--更新桌子库存
cmd.SHZ_SUB_C_MODIFY_ROOM_CONFIG	= 29	--修改房间配置
cmd.SHZ_SUB_C_REQUEST_QUERY_USER	= 30	--请求查询用户
cmd.SHZ_SUB_C_USER_CONTROL			= 31	--用户控制

--请求更新命令
cmd.SHZ_SUB_C_REQUEST_UPDATE_ROOMUSERLIST	= 32	--请求更新房间用户列表
cmd.SHZ_SUB_C_REQUEST_UPDATE_ROOMSTORAGE	= 33	--请求更新房间库存

cmd.SHZ_SUB_C_SINGLEMODE_CONFIRM			= 35	--
cmd.SHZ_SUB_C_BATCHMODE_CONFIRM				= 36

--用户叫分
cmd.SHZ_CMD_C_OneStart =
{
	{k="lBet",t="score"},
}
--比倍模式
cmd.SHZ_CMD_C_TwoMode =
{
	{k="cbOpenMode",t="byte"}
}
--比倍开始
cmd.SHZ_CMD_C_TwoStart =
{
	{k="cbOpenArea",t="byte"}
}
--更新本桌库存
cmd.SHZ_CMD_C_UpdateStorageTable =
{
	{k="lStorageTable",t="score"}
}

cmd.SHZ_CMD_C_ModifyRoomConfig =
{
	{k="lStorageDeductRoom",t="score"},			--全局库存衰弱
	{k="lMaxStorageRoom",t="score",l={2}},		--全局库存上限
	{k="wStorageMulRoom",t="word",l={2}},		--全局赢分概率
	{k="wGameTwo",t="word"},					--比倍概率
	{k="wGameTwoDeduct",t="word"},				--比倍概率
	{k="wGameThree",t="word"},					--小玛丽概率
	{k="wGameThreeDeduct",t="word"}				--
}

cmd.SHZ_CMD_C_RequestQusry_User =
{
	{k="dwGameID",t="word"}						--查询用户GAMEID
}

cmd.SHZ_CMD_C_UserControl =
{
	{k="dwGameID",t="word"},					--GAMEID
	{k="userControlInfo",t="word"}				--用户控制信息
}

cmd.SHZ_CMD_C_SingleMode =
{
	{k="wTableId",t="word"},
	{k="lTableStorage",t="score"}
}

cmd.SHZ_CMD_C_BatchMode =
{
	{k="lBatchModifyStorage",t="score"},
	{k="wBatchTableCount",t="score"},			--批量修改桌子张数
	{k="bBatchTableFlag",t="bool",l={512}}		--true为修改的标志
}


return cmd