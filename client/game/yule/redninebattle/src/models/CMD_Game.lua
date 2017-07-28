local cmd = {}

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
cmd.KIND_ID						= 206
	
--游戏人数
cmd.GAME_PLAYER					= 100

--状态定义
cmd.GS_PLACE_JETTON				= 100							--下注状态
cmd.GS_GAME_END					= 101						    --结束状态
cmd.GS_MOVECARD_END				= 102						    --结束状态
cmd.GAME_SCENE_FREE				= 103                           --空闲状态

--时间标识
cmd.IDI_FREE					= 99							--空闲时间5
cmd.IDI_PLACE_JETTON			= 100							--下注时间15
cmd.IDI_DISPATCH_CARD			= 301							--发牌时间21
cmd.IDI_ANDROID_BET				= 1000

--区域索引
cmd.ID_SHUN_MEN                 = 1                             --顺门
cmd.ID_TIAN_MEN                 = 3                             --天门
cmd.ID_DI_MEN                   = 2                             --地门
cmd.MAX_ROOM_COUNT              = 2
cmd.MAX_JETTON_COUNT            = 7

--玩家索引
cmd.BANKER_INDEX				= 0								--庄家索引
cmd.SHUN_MEN_INDEX				= 1								--顺门索引
cmd.DUI_MEN_INDEX				= 3								--对门索引
cmd.DAO_MEN_INDEX				= 2								--倒门索引
cmd.MAX_INDEX					= 4								--最大索引
cmd.AREA_COUNT					= 3								--区域数目
cmd.CONTROL_AREA				= 3								--受控区域

--赔率定义
cmd.RATE_TWO_PAIR				= 12							--对子赔率
cmd.SERVER_LEN					= 32							--房间长度
cmd.MAX_CARD					= 2
cmd.MAX_CARDGROUP				= 4

--机器人信息
cmd.tagRobotInfo =
{
    --筹码定义
    {k = "nChip", t = "int", l = {7}},
    --区域几率
    {k = "nAreaChance", t = "int", l = {cmd.AREA_COUNT}},
    --配置文件
    {k = "szCfgFileName", t = "tchar", s = 260},
    --最大赔率
    {k = "nMaxTime", t = "int"},
}

--历史记录
cmd.MAX_SCORE_HISTORY			= 16                            --历史个数

--记录信息
cmd.tagServerGameRecord =
{
    {k = "bWinShunMen", t = "int"},                             --顺门胜利
    {k = "bWinDuiMen", t = "int"},                              --对门胜利
    {k = "bWinDaoMen", t = "int"},                              --倒门胜利
}
cmd.RECORDER_LEN                = 12                            --单条记录的长度

--[[cmd.SUB_S_GameRecord =
{
    {k = "RecordCount", t = "int"},
    {k = "GameRecordArrary", t = "table", d = cmd.tagServerGameRecord, l = {cmd.MAX_SCORE_HISTORY}},         --游戏记录
}]]

---------------------------------------------------------------------------------------
--服务器命令结构

cmd.SUB_S_GAME_FREE				= 799							--游戏空闲
cmd.SUB_S_GAME_START			= 800							--游戏开始
cmd.SUB_S_PLACE_JETTON			= 801							--用户下注
cmd.SUB_S_GAME_END				= 802							--游戏结束
cmd.SUB_S_APPLY_BANKER			= 803							--申请庄家
cmd.SUB_S_CHANGE_BANKER			= 804							--切换庄家
cmd.SUB_S_CHANGE_USER_SCORE		= 805							--更新积分
cmd.SUB_S_SEND_RECORD			= 806							--游戏记录
cmd.SUB_S_PLACE_JETTON_FAIL		= 807							--下注失败
cmd.SUB_S_CANCEL_BANKER			= 808							--取消申请
cmd.SUB_S_CHEAT					= 809							--作弊信息
cmd.SUB_S_AMDIN_COMMAND			= 810							--管理员命令
cmd.SUB_S_TIME_STATUS			= 812							--时间状态
cmd.SUB_S_UPDATE_STORAGE        = 813							--更新库存

--时间状态结构
cmd.SUB_S_TimeStatus = 
{
    {k = "btStatus", t = "int"},        --时间状态
    {k = "btTime", t = "int"},          --时间
}

cmd.ACK_SET_WIN_AREA            = 1
cmd.ACK_PRINT_SYN               = 2                             --无控制
cmd.ACK_RESET_CONTROL           = 3                             --重置

cmd.CR_ACCEPT                   = 2			                    --接受
cmd.CR_REFUSAL                  = 3			                    --拒绝

--请求回复
cmd.CMD_S_CommandResult =
{
    {k = "cbAckType", t = "byte"},                              --回复类型
	{k = "cbResult", t = "byte"},
    {k = "cbExtendData", t = "byte", l={20}},                   --附加数据
}

cmd.IDM_UPDATE_STORAGE		    = 1024 + 1001
cmd.RQ_REFRESH_STORAGE		    = 1
cmd.RQ_SET_STORAGE			    = 2

--更新库存
cmd.CMD_S_UpdateStorage =
{
    {k = "lStorage", t = "score"},                              --新库存值
    {k = "lStorageDeduct", t = "score"},                        --库存衰减
}

--更新库存
cmd.CMD_C_UpdateStorage =
{
    {k = "cbReqType", t = "byte"},                              --请求类型
    {k = "lStorage", t = "score"},                              --新库存值
    {k = "lStorageDeduct", t = "score"},                        --库存衰减
}

--失败结构
cmd.CMD_S_PlaceJettonFail =
{
    {k = "wPlaceUser", t = "word"},                             --下注玩家
    {k = "lJettonArea", t = "byte"},                            --下注区域
    {k = "lPlaceScore", t = "score"},                           --当前下注
}

--更新积分
cmd.CMD_S_ChangeUserScore =
{
    {k = "wChairID", t = "word"},                               --椅子号码
    {k = "lScore", t = "double"},                               --玩家积分

	--庄家信息
    {k = "wCurrentBankerChairID", t = "word"},                  --当前庄家
    {k = "cbBankerTime", t = "byte"},                           --庄家局数
    {k = "lCurrentBankerScore", t = "double"},                  --庄家分数
}

--申请庄家
cmd.CMD_S_ApplyBanker =
{
    {k = "wApplyUser", t = "word"},                             --申请玩家
}

--取消申请
cmd.CMD_S_CancelBanker =
{
    {k = "szCancelUser", t = "string", s = yl.LEN_NICKNAME},     --取消玩家
}

--切换庄家
cmd.CMD_S_ChangeBanker =
{
    {k = "wBankerUser", t = "word"},                            --当庄玩家
    {k = "lBankerScore", t = "double"},                         --庄家金币
}

--游戏状态
cmd.CMD_S_StatusFree =
{
	--全局信息
    {k = "cbTimeLeave", t = "byte"},                            --剩余时间

	--玩家信息
    {k = "lUserMaxScore", t = "score"},                         --玩家金币

	--庄家信息
    {k = "wBankerUser", t = "word"},                            --当前庄家
    {k = "cbBankerTime", t = "word"},                           --庄家局数
    {k = "lBankerWinScore", t = "score"},                       --庄家成绩
    {k = "lBankerScore", t = "score"},                          --庄家分数
    {k = "bEnableSysBanker", t = "bool"},                       --系统做庄

	--控制信息
    {k = "lApplyBankerCondition", t = "score"},                 --申请条件
    {k = "lAreaLimitScore", t = "score"},                       --区域限制

	--房间信息
    {k = "szGameRoomName", t = "tchar", s = cmd.SERVER_LEN},    --房间名称

	--房间类型
    {k = "cbRoomType", t = "byte"},                             --房间类型
}

--游戏状态
cmd.CMD_S_StatusPlay =
{
	--全局下注
    {k = "lAllJettonScore", t = "score", l = {cmd.AREA_COUNT+1}},   --全体总注

	--玩家下注
    {k = "lUserJettonScore", t = "score", l = {cmd.AREA_COUNT+1}},  --全体总注

	--玩家积分
    {k = "lUserMaxScore", t = "score"},                         --最大下注

	--控制信息
    {k = "lApplyBankerCondition", t = "score"},                 --申请条件
    {k = "lAreaLimitScore", t = "score"},                       --区域限制

	--扑克信息
    {k = "cbTableCardArray", t = "byte", l = {2,2,2,2}},        --桌面扑克

	--庄家信息
    {k = "wBankerUser", t = "word"},                            --当前庄家
    {k = "cbBankerTime", t = "word"},                           --庄家局数
    {k = "lBankerWinScore", t = "score"},                       --庄家赢分
    {k = "lBankerScore", t = "score"},                          --庄家分数
    {k = "bEnableSysBanker", t = "bool"},                       --系统做庄

	--结束信息
    {k = "lEndBankerScore", t = "score"},                       --庄家成绩
    {k = "lEndUserScore", t = "score"},                         --玩家成绩
    {k = "lEndUserReturnScore", t = "score"},                   --返回积分
    {k = "lEndRevenue", t = "score"},                           --游戏税收

	--全局信息
    {k = "cbTimeLeave", t = "byte"},                            --剩余时间
    {k = "cbGameStatus", t = "byte"},                           --游戏状态
	
	--房间信息
    {k = "szGameRoomName", t = "tchar", s = cmd.SERVER_LEN},    --房间名称

	--房间类型
    {k = "cbRoomType", t = "byte"},                             --房间类型
}

--游戏空闲
cmd.CMD_S_GameFree =
{
    {k = "cbTimeLeave", t = "byte"},                            --剩余时间
    {k = "wCurrentBanker", t = "word"},                         --当前庄家
    {k = "nBankerTime", t = "int"},                             --做庄次数
}

--游戏开始
cmd.CMD_S_GameStart =
{
    {k = "wBankerUser", t = "word"},                            --庄家位置
    {k = "lBankerScore", t = "score"},                          --庄家金币
    {k = "lUserMaxScore", t = "score"},                         --我的金币
    {k = "cbTimeLeave", t = "byte"},                            --剩余时间
    {k = "bContiueCard", t = "bool"},                           --继续发牌

    {k = "nChipRobotCount", t = "int"},                         --人数上限 (下注机器人)
    {k = "nListUserCount", t = "score"},                        --列表人数
    {k = "nAndriodCount", t = "int"},                           --机器人列表人数
}

--用户下注
cmd.CMD_S_PlaceJetton = 
{
    {k = "wChairID", t = "word"},                               --用户位置
    {k = "cbJettonArea", t = "byte"},                           --筹码区域
    {k = "lJettonScore", t = "score"},                          --加注数目
    {k = "bIsAndroid", t = "bool"},                             --是否机器人
}

--游戏结束
cmd.CMD_S_GameEnd =
{
	--下局信息
    {k = "cbTimeLeave", t = "byte"},                             --剩余时间

	--扑克信息
    {k = "cbTableCardArray", t = "byte", l = {2,2,2,2}},        --桌面扑克
    {k = "cbLeftCardCount", t = "byte"},                        --扑克数目
    {k = "bcFirstCard", t = "byte"},
 
	--庄家信息
    {k = "wCurrentBanker", t = "word"},                         --当前庄家
    {k = "lBankerScore", t = "score"},                          --庄家成绩
    {k = "lBankerTotallScore", t = "score"},                    --庄家成绩
    {k = "nBankerTime", t = "int"},                             --做庄次数

	--玩家成绩
    {k = "lUserScore", t = "score"},                            --玩家成绩
    {k = "lUserReturnScore", t = "score"},                      --返回积分

	--全局信息
    {k = "lRevenue", t = "score"},                              --游戏税收
}

--游戏作弊
cmd.CMD_S_Cheat =
{
    {k = "cbTableCardArray", t = "byte", l = {2,2,2,2}},        --桌面扑克
}

--------------------------------------------------------------------------
--客户端命令结构

cmd.SUB_C_PLACE_JETTON			= 1                             --用户下注
cmd.SUB_C_APPLY_BANKER			= 2                             --申请庄家
cmd.SUB_C_CANCEL_BANKER			= 3                             --取消申请
cmd.SUB_C_CONTINUE_CARD			= 4                             --继续发牌
cmd.SUB_C_AMDIN_COMMAND			= 5                             --管理员命令
cmd.SUB_C_GET_ACCOUNT			= 7                             --获取帐号
cmd.SUB_C_CHECK_ACCOUNT			= 8                             --获取帐号
cmd.SUB_S_SCORE_RESULT			= 9                             --积分结果
cmd.SUB_S_ACCOUNT_RESULT		= 10                            --帐号结果
cmd.SUB_C_UPDATE_STORAGE        = 11                            --更新库存
--客户端消息
cmd.IDM_ADMIN_COMMDN			= 1024+1100
cmd.IDM_GET_ACCOUNT				= 1024+1101
cmd.IDM_CHEAK_ACCOUNT			= 1024+1102
cmd.IDM_SHOWCONTROLWIN	        = 1024+1103                     --管理员显示控制消息

--控制区域信息
cmd.tagControlInfo =
{
    {k = "cbControlArea", t = "byte", l = {cmd.MAX_INDEX}},     --控制区域
}

cmd.CS_BANKER_LOSE              = 1
cmd.CS_BANKER_WIN	            = 2
cmd.CS_BET_AREA		            = 3

cmd.tagAdminReq = 
{
    {k = "m_cbExcuteTimes", t = "byte"},                        --执行次数
    {k = "m_cbControlStyle", t = "byte"},                       --控制方式
    {k = "m_bWinArea", t = "bool", l = {3}},                    --赢家区域
}

cmd.RQ_SET_WIN_AREA	            = 1
cmd.RQ_RESET_CONTROL	        = 2
cmd.RQ_PRINT_SYN		        = 3

cmd.CMD_C_AdminReq =
{
    {k = "cbReqType", t = "byte"},
    {k = "cbExtendData", t = "table", d = cmd.tagAdminReq},     --附加数据
}

--用户下注
cmd.CMD_C_PlaceJetton =
{
    {k = "cbJettonArea", t = "byte"},                           --筹码区域
    {k = "lJettonScore", t = "score"},                          --加注数目
}

cmd.CMD_C_CheakAccount =
{
    {k = "szUserAccount", t = "tchar", s = yl.LEN_NICKNAME},
}

cmd.CMD_S_ScoreResult =
{
    {k = "lUserJettonScore", t = "score", l = {cmd.AREA_COUNT+1}},  --个人总注
}

cmd.CMD_S_AccountResult =
{
    {k = "szAccount", t = "tchar", s = yl.LEN_NICKNAME, l = {100}},     --帐号昵称
}

cmd.RES_PATH 					= 	"redninebattle/res/"
print("********************************************************load cmd");
return cmd