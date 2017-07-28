
local GameViewLayer = {}
--GameViewLayer.RES_PATH 				= device.writablePath.."game/yule/watermargin/res/"
GameViewLayer.RES_PATH              = "game/yule/watermargin/res/"
--	游戏一
local Game1ViewLayer = class("Game1ViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
GameViewLayer[1] = Game1ViewLayer
--	游戏二
local Game2ViewLayer = class("Game2ViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
GameViewLayer[2] = Game2ViewLayer
--	游戏三
local Game3ViewLayer = class("Game3ViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
GameViewLayer[3] = Game3ViewLayer

local module_pre = "game.yule.watermargin.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"

local cmd = module_pre .. ".models.CMD_Game"
local QueryDialog   = require("app.views.layer.other.QueryDialog")

local GameItem = appdf.req(module_pre .. ".views.layer.GameItem")

local PRELOAD = require(module_pre..".views.layer.PreLoading") 

local SettingLayer = appdf.req(module_pre .. ".views.layer.SettingLayer")
local HelpLayer = appdf.req(module_pre .. ".views.layer.HelpLayer")

GameViewLayer.RES_PATH 				= device.writablePath.. "game/yule/watermargin/res/"

local enGameLayer = 
{
	"TAG_SETTING_MENU",			--设置
	"TAG_QUIT_MENU",			--退出
	"TAG_START_MENU",			--开始按钮
	"TAG_HELP_MENU",			--游戏帮助
	"TAG_MAXADD_BTN",			--最大下注
	"TAG_MINADD_BTN",			--最小下注
	"TAG_ADD_BTN",				--加注
	"TAG_SUB_BTN",				--减注
	"TAG_AUTO_START_BTN",		--自动游戏
	"TAG_GAME2_BTN",			--开始游戏2
	"TAG_HIDEUP_BTN",			--隐藏上部菜单
	"TAG_SHOWUP_BTN",			--显示上部菜单
	"TAG_HALF_IN",				--半比
	"TAG_ALL_IN",				--全比
	"TAG_DOUBLE_IN",			--倍比
	"TAG_GAME2_EXIT",			--取分
	"TAG_SMALL_IN",				--押小
	"TAG_MIDDLE_IN",			--押和
	"TAG_BIG_IN",				--押大
	"TAG_GO_ON"					--继续
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enGameLayer);

local emGame2Actstate =
{
	"STATE_WAITTING",					--等待
	"STATE_WAVE",						--摇奖
	"STATE_OPEN",						--开奖
	"STATE_RESULT"						--结算
}
local Game2_ACTSTATE =  ExternalFun.declarEnumWithTable(0, emGame2Actstate)

local emGame2State =
{
	"GAME2_STATE_WAITTING",				--等待
	"GAME2_STATE_WAVING",				--摇奖
	"GAME2_STATE_WAITTING_CHOICE",		--等待下注
	"GAME2_STATE_OPEN",					--开奖
	"GAME2_STATE_RESULT"				--结算,等待继续或区分
}
local GAME2_STATE = ExternalFun.declarEnumWithTable(0, emGame2State)

local emGameLabel =
{
	"LABEL_COINS",						--玩家金钱
	"LABEL_YAXIAN",						--压线
	"LABEL_YAFEN",						--压分
	"LABEL_TOTLEYAFEN",					--总压分
	"LABEL_GETCOINS",					--获取金钱
	"LABEL_GAME3_TIMES"					--小玛丽次数
}
local GAME2_STATE = ExternalFun.declarEnumWithTable(10, emGameLabel)

function Game1ViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene
    --添加路径
    self:addPath()

    --预加载资源
	PRELOAD.loadTextures()

	-- --初始化csb界面
	 self:initCsbRes();

    --播放背景音乐
    ExternalFun.playBackgroudAudio("xiongdiwushu.mp3")
end

function Game1ViewLayer:onExit()

    PRELOAD.unloadTextures()
    PRELOAD.removeAllActions()

    PRELOAD.resetData()

    self:StopLoading(true)

    --播放大厅背景音乐
    ExternalFun.playPlazzBackgroudAudio()

    --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths();
    -- print("@@@@@@@@@@@@游戏中搜索路径@@@@@@@@@@@@@@")
    -- dump(oldPaths)

    cc.FileUtils:getInstance():setSearchPaths(self._searchPath);
    local searchpath = cc.FileUtils:getInstance():getSearchPaths()
    -- print("@@@@@@@@@@@@退出搜索路径@@@@@@@@@@@@@@")
    -- dump(searchpath)
end

function Game1ViewLayer:StopLoading( bRemove )
    PRELOAD.StopAnim(bRemove)
end

function Game1ViewLayer:addPath( )

    self._searchPath = cc.FileUtils:getInstance():getSearchPaths()

	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH)
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game1/");
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game2/");
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "game3/");

	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "common/");
	cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "setting/");
    cc.FileUtils:getInstance():addSearchPath(GameViewLayer.RES_PATH .. "sound_res/"); --  声音

end

---------------------------------------------------------------------------------------
--界面初始化
function Game1ViewLayer:initCsbRes(  )
	rootLayer, self._csbNode = ExternalFun.loadRootCSB(GameViewLayer.RES_PATH .."SHZ_Game1Layer.csb", self);

	--初始化按钮
	self:initUI(self._csbNode)

end

--初始化按钮
function Game1ViewLayer:initUI( csbNode )
	--按钮回调方法
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
        elseif eventType == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end
	--最小押注
	local Button_Min = csbNode:getChildByName("Button_Min");
	Button_Min:setTag(TAG_ENUM.TAG_MINADD_BTN);
	Button_Min:addTouchEventListener(btnEvent);
	--最大押注
	local Button_Max = csbNode:getChildByName("Button_Max");
	Button_Max:setTag(TAG_ENUM.TAG_MAXADD_BTN);
	Button_Max:addTouchEventListener(btnEvent);
	--减少
	local Button_Sub = csbNode:getChildByName("Button_Sub");
	Button_Sub:setTag(TAG_ENUM.TAG_SUB_BTN);
	Button_Sub:addTouchEventListener(btnEvent);
	--减少
	local Button_Add = csbNode:getChildByName("Button_Add");
	Button_Add:setTag(TAG_ENUM.TAG_ADD_BTN);
	Button_Add:addTouchEventListener(btnEvent);
	--进入比大小
	local Button_Game2 = csbNode:getChildByName("Button_Game2");
	Button_Game2:setTag(TAG_ENUM.TAG_GAME2_BTN);
	Button_Game2:addTouchEventListener(btnEvent);
	--自动加注
	local Button_Auto = csbNode:getChildByName("Button_Auto");
	Button_Auto:setTag(TAG_ENUM.TAG_AUTO_START_BTN);
	Button_Auto:addTouchEventListener(btnEvent);
	--开始
	local Button_Start = csbNode:getChildByName("Button_Start");
	Button_Start:setTag(TAG_ENUM.TAG_START_MENU);
	Button_Start:addTouchEventListener(btnEvent);
	--显示菜单
	local Button_Show = csbNode:getChildByName("Button_Show");
	Button_Show:setTag(TAG_ENUM.TAG_SHOWUP_BTN);
	Button_Show:addTouchEventListener(btnEvent);
	------
	--游戏币
	self.m_textScore = csbNode:getChildByName("Text_score");
	self.m_textScore:setString(self._scene:GetMeUserItem().lScore)
	--压线
	self.m_textYaxian = csbNode:getChildByName("Text_yaxian");
	self.m_textYaxian:setString(g_var(cmd).YAXIANNUM)
	--压分
	self.m_textYafen = csbNode:getChildByName("Text_yafen");
	self.m_textAllyafen = csbNode:getChildByName("Text_allyafen");
	--得到分数
	self.m_textGetScore = csbNode:getChildByName("Text_getscore");
	self.m_textGetScore:setString(0)

	self.m_textTips = csbNode:getChildByName("Text_Tips")
	self.m_textTips:setString("祝您好运！")
	------
	--菜单  
	self.m_nodeMenu = csbNode:getChildByName("Node_Menu");
	--返回
	local Button_back = self.m_nodeMenu:getChildByName("Button_back");
	Button_back:setTag(TAG_ENUM.TAG_QUIT_MENU);
	Button_back:addTouchEventListener(btnEvent);
    --帮助
	local Button_Help = self.m_nodeMenu:getChildByName("Button_Help");
	Button_Help:setTag(TAG_ENUM.TAG_HELP_MENU);
	Button_Help:addTouchEventListener(btnEvent);
    --设置
	local Button_Set = self.m_nodeMenu:getChildByName("Button_Set");
	Button_Set:setTag(TAG_ENUM.TAG_SETTING_MENU);
	Button_Set:addTouchEventListener(btnEvent);
    --隐藏
	local Button_Hide = self.m_nodeMenu:getChildByName("Button_Hide");
	Button_Hide:setTag(TAG_ENUM.TAG_HIDEUP_BTN);
	Button_Hide:addTouchEventListener(btnEvent);

	self.Node_top = csbNode:getChildByName("Node_top");

	self.Node_btnEffet = csbNode:getChildByName("Node_btnEffet")
end

--游戏1的通用动画
function Game1ViewLayer:initMainView(  )
	--打鼓
	local daguAnim = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("daguAnim"))
   	local nodeDagu = self.Node_top:getChildByName("Sprite_dagu")
   	nodeDagu:runAction(cc.RepeatForever:create(daguAnim))
   	--标题
	local titleAnim = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("titleAnim"))
   	local nodeTitle = self.Node_top:getChildByName("Sprite_title")
   	nodeTitle:runAction(cc.RepeatForever:create(titleAnim))
   	--飘旗
	local piaoqiAnim1 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("wYaoqiAnim"))
   	local nodePiaoqi = self.Node_top:getChildByName("Sprite_piaoqi")
   	nodePiaoqi:runAction(cc.RepeatForever:create(piaoqiAnim1))
    --飘旗2
   	local piaoqiAnim2 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("rYaoqiAnim"))
   	local nodePiaoqi2 = self.Node_top:getChildByName("Sprite_piaoqi2")
   	nodePiaoqi2:runAction(cc.RepeatForever:create(piaoqiAnim2))

   	--箭头
   	local nodeJiantou = self.Node_btnEffet:getChildByName("Sprite_arrow")
   	local jiantouAction = cc.Sequence:create(
   		cc.MoveBy:create(0.5,cc.p(0,10)),
   		cc.MoveBy:create(0.5,cc.p(0,-10))
   		)
   	nodeJiantou:runAction(cc.RepeatForever:create(jiantouAction))
   	--闪光
   	local flashAnim = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("flashAnim"))
	local nodeFlash = self.Node_btnEffet:getChildByName("Sprite_flash")
   	nodeFlash:runAction(cc.RepeatForever:create(flashAnim))
end
--游戏1动画开始
function Game1ViewLayer:game1Begin(  )
    print("############  game1Begin  ##############")
    for i=1,15 do

        local posx = math.ceil(i/3)
        local posy = (i-1)%3 + 1
        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
        local node = self._csbNode:getChildByName(nodeStr)
        if node ~= nil then
        	local nType = tonumber(self._scene.m_cbItemInfo[posy][posx])+1
        	if nType < 0 or nType > 9 then
        		nType = 0
        	end
			local pItem =  GameItem:create()
			if pItem then
                pItem:created(nType)
				local pItemLast = node:getChildByTag(1)
				if pItemLast then
					pItemLast:stopAllItemAction()
					pItemLast:removeFromParent()
					pItemLast = nil
				end
				node:addChild(pItem,0,1)
				pItem:setAnchorPoint(0.5,0.5)
				pItem:setContentSize(cc.size(210,145))
				pItem:setPosition(0,0)
				node:runAction(
					cc.Sequence:create(
						cc.CallFunc:create(function (  )
							pItem:beginMove(0.5+i*0.1)
							if i == 15 then
								self._scene:setGameMode(2) --表达GAME_STATE_MOVING
							end
						end)
						)
					)

			end
        end
    end
    ExternalFun.playSoundEffect("gundong.mp3")
    self:runAction(
    	cc.Sequence:create(
    		cc.DelayTime:create(3),
    		cc.CallFunc:create(function (  )
    			if self._scene:getGameMode() == 2 then --表达GAME_STATE_MOVING

    				self:game1GetLineResult()  
    			end
    		end)
    		)
    	)
end
--手动停止滚动
function Game1ViewLayer:game1End(  )
    self._scene:setGameMode(3)
    for i=1,15 do
        local posx = math.ceil(i/3)
        local posy = (i-1)%3 + 1
        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
        local node = self._csbNode:getChildByName(nodeStr)

        if node  then
        	local pItem = node:getChildByTag(1)
        	if pItem then
        		pItem:stopAllItemAction()
        	end
        end
    end
    self:stopAllActions()
    self:game1Result()
	--切换旗帜动作
	self:game1ActionBanner(false)
end
--游戏1结果
function Game1ViewLayer:game1Result()

	self._scene:setGameMode(3) --GAME_STATE_RESULT
	self.m_textGetScore:setString(self._scene.m_lGetCoins)
    for i=1,15 do
        local posx = math.ceil(i/3)
        local posy = (i-1)%3 + 1
        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
        local node = self._csbNode:getChildByName(nodeStr)
        if node  then
        	local pItem = node:getChildByTag(1)
        	if pItem then
        		if self._scene.m_lGetCoins > 0 then
        			if self._scene.tagActionOneKaiJian.bZhongJiang[posy][posx] == true then 
        				pItem:setState(0) --STATE_NORMAL
        				self:runAction(
        					cc.Sequence:create(
        						cc.DelayTime:create(0.5),
        						cc.CallFunc:create(function (  )
        							--显示中奖的动画
        							pItem:setState(1) --STATE_SELECT
        							--对应音效
                                    self:Game1ZhongxianAudio(pItem.m_nType)
        						end),
        						cc.DelayTime:create(3.0),
        						cc.CallFunc:create(function (  )
        							if self.m_textTips then
        								self.m_textTips:setString("恭喜中奖")
        							end
        							local nodeTip = self._csbNode:getChildByName("Node_win")

        							if nodeTip then
        								--win精灵
        								nodeTip:setVisible(true)
        								--显示中奖分数
        								nodeTip:removeChildByTag(1)
                                        local winIcon = nodeTip:getChildByName("Sprite_icon")
                                        local wLen = winIcon:getContentSize().width
                                        winIcon:setPositionX(345)
										local endScoreStr =  "zhongjiang_num.png"
										local labNum = cc.LabelAtlas:_create(txtCellScoreStr,GameViewLayer.RES_PATH.."game1/" .. endScoreStr,101,101,string.byte("0"))
										labNum:setAnchorPoint(cc.p(0.5,0.5))
										nodeTip:addChild(labNum,0,1)
										local nLen = labNum:getContentSize().width
										labNum:setPosition(667-(nLen-400)/2,375)
										labNum:setString(self._scene.m_lGetCoins)
                                        
                                        --隐藏
	        							nodeTip:runAction(cc.Sequence:create(
	        									cc.DelayTime:create(1),
	        									cc.Hide:create()
	        									))
        							end

        						end)
        						)
        					)
        			else
        				pItem:setState(2) --STATE_GREY
        			end
        		else
        			pItem:setState(0)  --STATE_NORMAL
                    
        		end
        	end
        end
    end
    --切换按钮状态
    self:updateStartButtonState(true)

    if  self._scene.m_bIsAuto == false  then
	    --切换旗帜动画
	    self:game1ActionBanner(true)
    end
    if self._scene.m_bEnterGame3 == true then     --设置小玛丽状态
    	self._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_THREE
    else
    	if self._scene.m_lGetCoins > 0 then     --设置比倍状态
    		self._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_TWO
    	end
    end
    local fTime = 0.5
    if self._scene.m_lGetCoins > 0 then
    	fTime = 4
    end
    --即将进入小玛丽
    if g_var(cmd).SHZ_GAME_SCENE_THREE == self._scene.m_cbGameStatus then
    	self:runAction(
    		cc.Sequence:create(
    			cc.CallFunc:create(function (  )
    				if self.m_textTip then
    					self.m_textTip:setString("即将进入小玛丽")
    				end
    			end),
    			cc.DelayTime:create(fTime),
    			cc.CallFunc:create(function (  )
    				self._scene.m_bIsItemMove = false
    				--游戏模式
    				self._scene:setGameMode(5) --GAME_STATE_END
    				--即将进入小玛丽
                    print("即将进入小玛丽")
    				self._scene:onEnterGame3()

    			end)
    			)
    		)
    else
    	if self._scene.m_bIsAuto == true and self._scene.m_lGetCoins > 0 then --自动游戏中，将有3秒时间让玩家选择是否进入比倍
    			self:runAction(
    				cc.Sequence:create(
    					cc.DelayTime:create(fTime),
    					cc.CallFunc:create(function (  )
                            if  self._scene.m_bIsAuto == false then
                                --切换旗帜动画
                                self:game1ActionBanner(true)
                            end
    						self._scene.m_bIsItemMove = false
    						--游戏模式
    						self._scene:setGameMode(4)  --GAME_STATE_WAITTING_GAME2
    						if self._scene.m_lGetCoins > 0 then
                                if self._scene.m_bReConnect1 == true then
    						          self:enableGame2Btn(false)
                                else
                                    self:enableGame2Btn(true)
                                end
                            else
                                --结束游戏1消息
                                --self._scene:sendEndGame1Msg()
    						end
    						if self.m_textTips then
    							self.m_textTips:setString("3s后自动开始游戏")
    						end
    					end),
    					cc.DelayTime:create(1),
    					cc.CallFunc:create(function (  )
    						if self.m_textTips then
    							self.m_textTips:setString("2s后自动开始游戏")
    						end
                            if self._scene.m_bReConnect1 == true then
                                  self:enableGame2Btn(false)
                            end
    					end),
    		    		cc.DelayTime:create(1),
    					cc.CallFunc:create(function (  )
    						if self.m_textTips then
    							self.m_textTips:setString("1s后自动开始游戏")
    						end
                            if self._scene.m_bReConnect1 == true then
                                self:enableGame2Btn(false)
                            end
    					end),
                        cc.DelayTime:create(0.7),
                        cc.CallFunc:create(function (  )
                            --if self._scene.m_bIsAuto == true then
                                self:enableGame2Btn(false)
                            --end
                        end),
    					cc.DelayTime:create(0.3),
    					cc.CallFunc:create(function()
                            print("自动游戏中，将有3秒时间让玩家选择是否进入比倍后")
                            --断线重连后
                            if self._scene.m_bReConnect1 == true then
                                local useritem = self._scene:GetMeUserItem()
                                if useritem.cbUserStatus ~= yl.US_READY then 
                                    print("---框架准备 断线重连后")
                                    self._scene:SendUserReady()
                                end
                                --发送准备消息
                                self._scene:sendReadyMsg()

                                self._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
                                self._scene:setGameMode(1)
                                self._scene.m_bReConnect1 = false
                                print(" ---断线重连 over")
                                if self.m_textTips then
                                    self.m_textTips:setString("祝您好运！")
                                end
                                return
                            end
                            --if self._scene.m_bIsAuto == true then
                                self._scene:setGameMode(5) --GAME_STATE_END
                                if self._scene.m_lGetCoins > 0 then
                                    --发送放弃比大小游戏
                                    self._scene:sendGiveUpMsg()
                                else
                                    --结束游戏1消息
                                    self._scene:sendEndGame1Msg()
                                end
                            --end
                            if self.m_textTips then
                                self.m_textTips:setString("祝您好运！")
                            end

    					end)
    					)
    				)
    	else
    		self:runAction(
    			cc.Sequence:create(
    				cc.DelayTime:create(fTime),
    				cc.CallFunc:create(function (  )
    					self._scene.m_bIsItemMove = false
    					self._scene:setGameMode(5)
						for i=1,15 do
					        local posx = math.ceil(i/3)
					        local posy = (i-1)%3 + 1
					        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
					        local node = self._csbNode:getChildByName(nodeStr)
					        if node  then
					        	local pItem = node:getChildByTag(1)
					        	if pItem then
					        		pItem:setState(0)  --STATE_NORMAL
					        	end
					        end
					    end
					    if self._scene.m_lGetCoins > 0 then
 
					    	--显示游戏2按钮
					    	self:enableGame2Btn(true)
					    	--改变提示语
					    	if self.m_textTips then
					    		self.m_textTips:setString("恭喜中奖！")
					    	end

                        else
                            --结束游戏1消息
                            self._scene:sendEndGame1Msg()
					    end
                        if self.m_textTips then
                            self.m_textTips:setString("祝您好运！")
                        end
    				end),
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function (  )
                        --断线重连后
                        if self._scene.m_bReConnect1 == true then
                            local useritem = self._scene:GetMeUserItem()
                            if useritem.cbUserStatus ~= yl.US_READY then 
                                print(" ---框架准备 断线重连后")
                                self._scene:SendUserReady()
                            end
                            --发送准备消息
                            self._scene:sendReadyMsg()

                            self._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
                            self._scene:setGameMode(1)
                            self._scene.m_bReConnect1 = false
                            print(" ---断线重连 over")
                            return
                        end
                        if self._scene.m_bIsAuto == true and self._scene.m_lGetCoins > 0 then
                            --发送消息
                            self._scene:setGameMode(5) --GAME_STATE_END
                            self:enableGame2Btn(false)
                            self._scene:sendGiveUpMsg()
                        end
                    
                    end)
    				)
    			)
    	end
    end
end

--游戏连线结果
function Game1ViewLayer:game1GetLineResult(  )
	print("游戏连线结果")
    self._scene:setGameMode(3)  --GAME_STATE_RESULT
    self.m_textGetScore:setString(self._scene.m_lGetCoins)
    --画中奖线
    --中奖线路径
    local pathLine = 
    {
    	"prizeLine/01.png",
    	"prizeLine/02.png",
    	"prizeLine/03.png",
    	"prizeLine/04.png",
    	"prizeLine/05.png",
    	"prizeLine/06.png",
    	"prizeLine/07.png",
    	"prizeLine/08.png",
    	"prizeLine/09.png",
	}
	--绘制中奖线
	if self._scene.m_lGetCoins > 0 then
		--每条线间隔
		local delayTime = 1.5
		for lineIndex=1,#self._scene.m_UserActionYaxian do
			local pActionOneYaXian = self._scene.m_UserActionYaxian[lineIndex]
			if pActionOneYaXian then
				self:runAction(
					cc.Sequence:create(
						cc.DelayTime:create(delayTime*(lineIndex-1)),
						cc.CallFunc:create(function ()
							--音效
                            ExternalFun.playSoundEffect("gundong_1.mp3")
							--如果是最后一个，进入结算界面
							if lineIndex == #self._scene.m_UserActionYaxian then
								self:runAction(
									cc.Sequence:create(
										cc.DelayTime:create(1.5),
										cc.CallFunc:create(function (  )
												self:game1Result()
										end)
										)
									)
							end
							local sprLine = display.newSprite(pathLine[pActionOneYaXian.nZhongJiangXian])
							self:removeChildByTag(lineIndex)
							self._csbNode:addChild(sprLine,0,lineIndex)
							sprLine:setPosition(667,375)
							sprLine:runAction(
								cc.Sequence:create(
									cc.DelayTime:create(1),
									cc.Hide:create()
									)
								)
							--设置每个精灵状态
							for i=1,15 do
						        local posx = math.ceil(i/3)
						        local posy = (i-1)%3 + 1
						        local nodeStr = string.format("Node_%d_%d",posx-1,posy-1)
						        local node = self._csbNode:getChildByName(nodeStr)
						        if node then
						        	local pItem = node:getChildByTag(1)
						        	if pItem then
						        		pItem:setState(0) -- STATE_NORMAL
						        		--判断是否中奖的
						        		local isOnLine = false
						        		for j=1,g_var(cmd).ITEM_X_COUNT do
						        			local pos = {}
						        			pos.x = pActionOneYaXian.ptXian[j].x
						        			pos.y = pActionOneYaXian.ptXian[j].y
						        			if pos.x == posy and pos.y == posx then
						        				isOnLine = true
						        				--上方方框序列帧
						        				--创建序列帧
												local nodeAct = cc.Node:create()
												nodeAct:setPosition(node:getPosition())
												self._csbNode:addChild(nodeAct)
												--item框
												local spBox = display.newSprite("#game1_box_1.png")
												nodeAct:addChild(spBox)
												spBox:setPosition(0,0)
   												local action = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("game1BoxAnim"))
											   	spBox:runAction(cc.RepeatForever:create(action))
											   	--闪光精灵
												local spLight = display.newSprite("#common_light_01.png")
												local spLight = cc.Sprite:create()
												nodeAct:addChild(spLight)
												spLight:setPosition(0,0)
												local action2 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("lightAnim"))
											   	spLight:runAction(cc.RepeatForever:create(action2))

											 	nodeAct:runAction(cc.Sequence:create(
												 	cc.DelayTime:create(1.5),
												 	cc.CallFunc:create(function (  )
												 		nodeAct:removeFromParent()
												 	end)
												 	))
						        				--显示得分
						        				 self.m_textTips:setString(string.format("得分：%d",pActionOneYaXian.lXianScore))
						        			end
						        		end
						        		if isOnLine == false then
						        			pItem:setState(2) --STATE_GREY
						        		end
						        	end
						        end
							end
						end)
						)
					)
			end
		end
	else
		self:game1Result()
	end
end

function Game1ViewLayer:onButtonClickedEvent(tag,ref)
	if tag == TAG_ENUM.TAG_QUIT_MENU then  			--退出
        self._scene.m_bIsLeave = true
        self._scene:onExitTable()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_START_MENU  then    		--开始游戏
		self._scene:onGameStart()
		self:game1ActionBanner(false)             --切换旗帜动作
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_SETTING_MENU  then    --	设置
		self:onSetLayer()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_HELP_MENU  then    	--游戏帮助
        self:onHelpLayer()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_MAXADD_BTN  then    --	最大加注
		self._scene:onAddMaxScore()
        --声音
        ExternalFun.playSoundEffect("shangfen.mp3")
	elseif tag == TAG_ENUM.TAG_MINADD_BTN  then    --	最小减注
		self._scene:onAddMinScore()
        --声音
        ExternalFun.playSoundEffect("shangfen1.mp3")
	elseif tag == TAG_ENUM.TAG_ADD_BTN  then    --	加注
		self._scene:onAddScore()
        --声音
        ExternalFun.playSoundEffect("shangfen.mp3")
	elseif tag == TAG_ENUM.TAG_SUB_BTN  then    --	减注
		self._scene:onSubScore()
        --声音
        ExternalFun.playSoundEffect("shangfen1.mp3")
	elseif tag == TAG_ENUM.TAG_AUTO_START_BTN  then   --自动游戏
		self._scene:onAutoStart()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_GAME2_BTN  then    --	开始游戏2
		self._scene:onEnterGame2()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_HIDEUP_BTN  then   --隐藏上部菜单
		self:onHideTopMenu()
        ExternalFun.playClickEffect()
	elseif tag == TAG_ENUM.TAG_SHOWUP_BTN  then   --显示上部菜单
		self:onShowTopMenu()
        ExternalFun.playClickEffect()
	else
		showToast(self,"功能尚未开放！",1)
	end
end

--隐藏上部菜单
function Game1ViewLayer:onHideTopMenu()
    if self.m_nodeMenu:getPositionX() == -667 then
        return
    end
	local actMove = cc.MoveTo:create(0.5,cc.p(-667,703.5))
	local Sequence = cc.Sequence:create(
		actMove,
		cc.CallFunc:create(function (  )
			local Button_Show = self._csbNode:getChildByName("Button_Show")
			if Button_Show then
				Button_Show:setVisible(true)
			end
		end)
		)
	self.m_nodeMenu:runAction(Sequence)
end

--显示上部菜单
function Game1ViewLayer:onShowTopMenu()
    if self.m_nodeMenu:getPositionX() == 667 then
        return
    end
	local actMove = cc.MoveTo:create(0.5,cc.p(667,703.5))
	local spawn = cc.Spawn:create(
		cc.CallFunc:create(function (  )
			local Button_Show = self._csbNode:getChildByName("Button_Show")
			if Button_Show then
				Button_Show:setVisible(false)
			end
		end),
		actMove
		)
	self.m_nodeMenu:runAction(spawn)
end
--声音设置界面
function Game1ViewLayer:onSetLayer(  )
    self:onHideTopMenu()
    local mgr = self._scene._scene:getApp():getVersionMgr()
    local verstr = mgr:getResVersion(g_var(cmd).KIND_ID) or "0"
    verstr = "游戏版本:" .. appdf.BASE_C_VERSION .. "." .. verstr
	local set = SettingLayer:create(verstr)
    self._csbNode:addChild(set)
    set:setLocalZOrder(9)
end

function Game1ViewLayer:onHelpLayer(  )
    self:onHideTopMenu()
    local help = HelpLayer:create()
    self._csbNode:addChild(help)
    help:setLocalZOrder(9)
end

--自动游戏
function Game1ViewLayer:setAutoStart( bisShow )
	--显示勾
	local spSelect = self._csbNode:getChildByName("game1_check")
	if spSelect then
		spSelect:setVisible(bisShow)
	end
end

--改变比倍按钮和
function Game1ViewLayer:enableGame2Btn( isEnable )
	if self.Node_btnEffet then
		self.Node_btnEffet:setVisible(isEnable)		
	end
	local Button_Game2 = self._csbNode:getChildByName("Button_Game2");
	Button_Game2:setEnabled(isEnable)
end

--切换开始按钮和停止按钮的纹理
function Game1ViewLayer:updateStartButtonState( bIsStart)
    local Button_Start = self._csbNode:getChildByName("Button_Start");
    if bIsStart == true then
        Button_Start:loadTextureNormal("game1/game1_start_1.png")
        Button_Start:loadTexturePressed("game1/game1_start_2.png")
    else
        Button_Start:loadTextureNormal("game1/game1_stop_1.png")
        Button_Start:loadTexturePressed("game1/game1_stop_2.png")
    end
end

function Game1ViewLayer:game1ActionBanner( bIsWait )
	local qizhi1 = self.Node_top:getChildByName("Sprite_piaoqi")
	qizhi1:setVisible(bIsWait)
	local qizhi2 = self.Node_top:getChildByName("Sprite_piaoqi2")
	qizhi2:setVisible(not bIsWait)
end

function Game1ViewLayer:Game1ZhongxianAudio( bIndex )
    local soundPath = 
    {
        "winsound.mp3",
        "winsound.mp3",
        "winsound.mp3",
        "luzhisheng.mp3",
        "lincong.mp3",
        "songjiang.mp3",
        "titianxingdao.mp3",
        "zhongyitang.mp3",
        "shuihuchuan3.mp3"
    }
    ExternalFun.playSoundEffect(soundPath[bIndex])
end
---------------------------------------------------------------------
--						游戏2 摇骰子
---------------------------------------------------------------------
function Game2ViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene

    self._scene:game2DataInit();
	self:initCsbRes();
end

--界面初始化
function Game2ViewLayer:initCsbRes(  )
	rootLayer, self._csbNode = ExternalFun.loadRootCSB(GameViewLayer.RES_PATH .. "SHZ_Game2Layer.csb", self);
	 --初始化按钮
	 self:initUI(self._csbNode)

end
--初始化按钮等控件
function Game2ViewLayer:initUI( csbNode )
	--按钮列表
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            ExternalFun.popupTouchFilter(1, false)
        elseif eventType == ccui.TouchEventType.canceled then
            ExternalFun.dismissTouchFilter()
        elseif eventType == ccui.TouchEventType.ended then
            ExternalFun.dismissTouchFilter()
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end
	--半比
	local Button_half = csbNode:getChildByName("Button_half");
	Button_half:setTag(TAG_ENUM.TAG_HALF_IN);
	Button_half:addTouchEventListener(btnEvent);
	--全比
	local Button_all = csbNode:getChildByName("Button_all");
	Button_all:setTag(TAG_ENUM.TAG_ALL_IN);
	Button_all:addTouchEventListener(btnEvent);
	--倍比
	local Button_double = csbNode:getChildByName("Button_double");
	Button_double:setTag(TAG_ENUM.TAG_DOUBLE_IN);
	Button_double:addTouchEventListener(btnEvent);
	--继续
	local Button_goon = csbNode:getChildByName("Button_goon");
	Button_goon:setTag(TAG_ENUM.TAG_GO_ON);
	Button_goon:addTouchEventListener(btnEvent);
	--取分
	local Button_get = csbNode:getChildByName("Button_get");
	Button_get:setTag(TAG_ENUM.TAG_GAME2_EXIT);
	Button_get:addTouchEventListener(btnEvent);
	--押小
	local Button_small = csbNode:getChildByName("Button_small");
	Button_small:setTag(TAG_ENUM.TAG_SMALL_IN);
	Button_small:addTouchEventListener(btnEvent);
	--押和
	local Button_middle = csbNode:getChildByName("Button_middle");
	Button_middle:setTag(TAG_ENUM.TAG_MIDDLE_IN);
	Button_middle:addTouchEventListener(btnEvent);
	--押大
	local Button_big = csbNode:getChildByName("Button_big");
	Button_big:setTag(TAG_ENUM.TAG_BIG_IN);
	Button_big:addTouchEventListener(btnEvent);
	------
	--游戏币
	self.m_textScore = csbNode:getChildByName("Text_score");
	self.m_textScore:setString(self._scene.m_lCoins)
	--压分
	self.m_textYafen = csbNode:getChildByName("Text_yafen"); 
	self.m_textYafen:setString(self._scene.m_lGetCoins)
	--得到分数
	self.m_textGetScore = csbNode:getChildByName("Text_getscore");
	self.m_textGetScore:setString(0)
	self.m_textGetScore:setAnchorPoint(1,0.5)
end

--摇骰子游戏 按钮回调方法
function Game2ViewLayer:onButtonClickedEvent(tag,ref)
	ExternalFun.playClickEffect()
	if tag == TAG_ENUM.TAG_HALF_IN then  			 --半比
		self._scene:onHalfIn()
	elseif tag == TAG_ENUM.TAG_ALL_IN  then   		 --全比
		self._scene:onAllIn()
	elseif tag == TAG_ENUM.TAG_DOUBLE_IN  then       --倍比
		self._scene:onDoubleIn()  
	elseif tag == TAG_ENUM.TAG_GO_ON  then           --继续
		self._scene:onGoon()
	elseif tag == TAG_ENUM.TAG_GAME2_EXIT  then      --取分
		self._scene:onExitGame2()
	elseif tag == TAG_ENUM.TAG_SMALL_IN  then        --押小  --1是小，2是和，3是大
		self._scene:onYaZhu(1)
	elseif tag == TAG_ENUM.TAG_MIDDLE_IN  then    	 --押和
		self._scene:onYaZhu(2)
	elseif tag == TAG_ENUM.TAG_BIG_IN  then          --押大
		self._scene:onYaZhu(3)
	else
		showToast(self,"功能尚未开放！",1)
	end
end
--初始化等待界面  
function Game2ViewLayer:initWaittingView(  )
	--初始化界面，该隐藏的隐藏
	local nodeTouzi = self._csbNode:getChildByName("Node_touzi")
	local spResult1 = self._csbNode:getChildByName("Sprite_result1")
	local spResult2 = self._csbNode:getChildByName("Sprite_result2")
	local spOneGold = self._csbNode:getChildByName("Sprite_oneGold")
	nodeTouzi:setVisible(false)
	spResult1:setVisible(false)
	spResult2:setVisible(false)
	spOneGold:setVisible(false)
   	--荷官默认动作
   	--创建序列帧
	local dealerAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("dealerComAnim"))
   	local spDealer = self._csbNode:getChildByName("Sprite_dealer")
    spDealer:stopAllActions()
   	spDealer:setPositionY(495)
   	spDealer:runAction(cc.RepeatForever:create(dealerAni))
   	--左边
 	local leftAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("leftComAnim"))
   	local spLeft = self._csbNode:getChildByName("Sprite_left")
   	spLeft:stopAllActions()
   	spLeft:runAction(cc.RepeatForever:create(leftAni))
   	--右边
 	local rightAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("rightComAnim"))
   	local spRight = self._csbNode:getChildByName("Sprite_right")
   	spRight:stopAllActions()
   	spRight:runAction(cc.RepeatForever:create(rightAni))
end

--摇奖动画
function Game2ViewLayer:initDiceView(  )
	self._scene:setGame2Mode(1) --GAME2_STATE_WAVING
  	--荷官默认动作
   	--创建序列帧
 	local dealerAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("dealerDiceAnim"))         
   	local spDealer = self._csbNode:getChildByName("Sprite_dealer")
   	spDealer:setPositionY(510)
   	spDealer:stopAllActions()
   	spDealer:runAction(dealerAni)

   	--音效
    ExternalFun.playSoundEffect("yaosaizi.mp3")
   	--左边
 	local leftAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("leftCheerAnim"))

   	local spLeft = self._csbNode:getChildByName("Sprite_left")
   	spLeft:stopAllActions()
   	spLeft:runAction(leftAni)
   	--右边
   	local rightAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("rightCheerAnim"))
   	local spRight = self._csbNode:getChildByName("Sprite_right")
 	spRight:stopAllActions()
   	spRight:runAction(rightAni)
   	--桌子
   	local deskAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("deskAnim"))
   	local spDesk = self._csbNode:getChildByName("Sprite_desk")
   	spDesk:stopAllActions()
   	spDesk:runAction(
   		cc.Sequence:create(
   			cc.DelayTime:create(2.5),
			deskAni
   			)
   		)
   	--金元宝
	local goldAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("goldAnim"))
   	local spGold = self._csbNode:getChildByName("Sprite_gold")
   	spGold:stopAllActions()
   	spGold:runAction(   	
   		cc.Sequence:create(
	   		cc.DelayTime:create(2.5),
	   		goldAni
   		))
   	--等待下注闪烁动画
   	local nodeLight = self._csbNode:getChildByName("Node_light")
   	local spLight = nodeLight:getChildByName("game2_light")
   	spLight:runAction(cc.RepeatForever:create(cc.Blink:create(2,4)))
   	nodeLight:runAction(
   		cc.Sequence:create(
   			cc.DelayTime:create(3.5),
   			cc.Show:create(),
   			cc.CallFunc:create(function (  )
   				
   				--等待音效
                ExternalFun.playSoundEffect("xia.wav")
   				self._scene:setGame2Mode(2) --GAME2_STATE_WAITTING_CHOICE
   				self:enableDickButton(true)
   				self:initWaittingView()
   			end)
   			)
   		)
end

function Game2ViewLayer:initOpenDiceCup(  )
	self._scene:setGame2Mode(3)	--设置状态
	--等待下注闪烁动画隐藏
	local nodeLight = self._csbNode:getChildByName("Node_light")
	nodeLight:setVisible(false)
  	--开骰子动作
   	--创建序列帧
	local dealerAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("dealerOpenAnim"))
   	local spDealer = self._csbNode:getChildByName("Sprite_dealer")
   	spDealer:setPositionY(503)
   	spDealer:stopAllActions()
	spDealer:runAction(dealerAni)

   	--左边
 	local leftAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("leftCheerAnim"))
   	local spLeft = self._csbNode:getChildByName("Sprite_left")
   	spLeft:stopAllActions()
   	spLeft:runAction(leftAni)
   	--右边
 	local rightAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("rightCheerAnim"))
   	local spRight = self._csbNode:getChildByName("Sprite_right")
   	spRight:stopAllActions()
   	spRight:runAction(rightAni)
   	--摇开了放置骰子
   	local nodeTouzi = self._csbNode:getChildByName("Node_touzi")
   	local nodeTouzi1 = nodeTouzi:getChildByName("Node_touzi1")
   	local nodeTouzi2 = nodeTouzi:getChildByName("Node_touzi2")
   	--创建骰子
   	--骰子一
   	local spTouzi1 = cc.Sprite:create(string.format(GameViewLayer.RES_PATH .. "game2/touzi_small_%d.png",self._scene.m_pGame2Result.cbOpenSize[1]))
   	nodeTouzi1:addChild(spTouzi1)
   	--骰子二
   	local spTouzi2 = cc.Sprite:create(string.format(GameViewLayer.RES_PATH .. "game2/touzi_small_%d.png",self._scene.m_pGame2Result.cbOpenSize[2]) )
   	nodeTouzi2:addChild(spTouzi2)
   	nodeTouzi:runAction(
   		cc.Sequence:create(
   			cc.DelayTime:create(0.5),
   			cc.CallFunc:create(function()
   				nodeTouzi:setVisible(true)
                --音效
                local totalNum = self._scene.m_pGame2Result.cbOpenSize[1]+self._scene.m_pGame2Result.cbOpenSize[2]
                local soundStr = string.format("%ddian.mp3",totalNum)
                ExternalFun.playSoundEffect(soundStr)
   			end),
   			cc.DelayTime:create(1),
   			cc.CallFunc:create(function()

   				self:initGame2Result()
   			end)
   			)
   		)
end

--游戏2结果
function Game2ViewLayer:initGame2Result()
	--获取金钱
	if self.m_textGetScore then
		self.m_textGetScore:setString(self._scene.m_lAllGetCoin2)
	end
	--展示大骰子
	--创建骰子一
	local spResult1 = self._csbNode:getChildByName("Sprite_result1")
	local frame1 = cc.SpriteFrame:create(string.format(GameViewLayer.RES_PATH .. "game2/touzi_big_%d.png",self._scene.m_pGame2Result.cbOpenSize[1]),cc.rect(0,0,115,84)) --,cc.rect()
	spResult1:setSpriteFrame(frame1)
	spResult1:setVisible(true)
	--创建骰子二
	local spResult2 = self._csbNode:getChildByName("Sprite_result2")
	local frame2 = cc.SpriteFrame:create(string.format(GameViewLayer.RES_PATH .. "game2/touzi_big_%d.png",self._scene.m_pGame2Result.cbOpenSize[2]),cc.rect(0,0,115,84)) --,
	spResult2:setSpriteFrame(frame2)
	spResult2:setVisible(true)
	if self._scene.m_pGame2Result.lScore > 0 then
		--赢的音效
        ExternalFun.playSoundEffect("ying.mp3")
	else
		--输的音效
        ExternalFun.playSoundEffect("shu.mp3")
	end
  	--默认动作
   	--创建序列帧
   	local animation --= cc.Animation:create()
   	local spDealer = self._csbNode:getChildByName("Sprite_dealer")
   	--local dealerAni
	if self._scene.m_pGame2Result.lScore > 0 then
		animation = cc.AnimationCache:getInstance():getAnimation("dealerAngerAnim")
		spDealer:setPositionY(520)
	else
		animation = cc.AnimationCache:getInstance():getAnimation("dealerHappyAnim")
		spDealer:setPositionY(510)
	end

   	local delayTime = 0.1
   	local nTimes = 1
   	local pos = {x=21,y=21}
   	if self._scene.m_pGame2Result.lScore == 0 then
   		delayTime = 0.3
   		nTimes = 2
   		pos = {x=-3.5,y=14}
   	else
   		local nodeTouzi = self._csbNode:getChildByName("Node_touzi")
   		if nodeTouzi then
   			nodeTouzi:runAction(
   				cc.Sequence:create(
   					cc.DelayTime:create(2),
   					cc.Hide:create()
   					)
   				)
   		end
   	end
   	--animation:setDelayPerUnit(delayTime)          --设置两个帧播放时间     
   	local dealerAni =cc.Animate:create(animation)
   	spDealer:stopAllActions()
   	spDealer:runAction(cc.Repeat:create(dealerAni,nTimes))

   	--左边
   	local leftAni
    local spLeft = self._csbNode:getChildByName("Sprite_left")
   	if self._scene.m_pGame2Result.lScore > 0 then
		leftAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("leftHappyAnim"))
   	else
		leftAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("leftCryAnim"))
   	end    
   	spLeft:stopAllActions()
   	spLeft:runAction(leftAni)
    --右边
	local rightAni
    local spRight = self._csbNode:getChildByName("Sprite_right")
    if self._scene.m_pGame2Result.lScore > 0 then
        spRight:setPositionY(425)
		rightAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("rightHappyAnim"))
    else
        spRight:setPositionY(428)
		rightAni = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("rightCryAnim"))
    end
   	spRight:stopAllActions()
   	spRight:runAction(rightAni)

   	self:runAction(
   		cc.Sequence:create(
            cc.DelayTime:create(1.5),
            cc.CallFunc:create(function()
                if self._scene.m_pGame2Result.lScore <= 0 then
                    self._scene.m_lCoins = self._scene.m_lCoins + self._scene.m_lAllGetCoin2
                    self.m_textScore:setString(self._scene.m_lCoins)
                end
            end),
   			cc.DelayTime:create(1.5),
   			cc.CallFunc:create(function()

   				if self._scene.m_pGame2Result.lScore > 0 then
   					self._scene:setGame2Mode(4) --GAME2_STATE_RESULT
   					self:initWaittingView()
   				else
                    self._scene:sendGiveUpMsg() --放弃比大小
   					self:backOneGame()
   				end
   			end)
   			)
   		)
end

function Game2ViewLayer:backOneGame()
	--切换回第一个游戏
	local gameview = self._scene._gameView
	gameview:setPosition(0,0)
	gameview:setVisible(true)
    gameview.m_textTips:setString("祝您好运！")
    gameview.m_textScore:setString(self._scene.m_lCoins)
    gameview.m_textGetScore:setString(0)
    self._scene.m_lGetCoins = 0
	self._scene:setGameMode(0) --GAME_STATE_WAITTING


    self:removeFromParent()
	if gameview._scene.m_bIsAuto == true and gameview._scene.m_bReConnect2 == false then

        gameview._scene:onGameStart()
        gameview:game1ActionBanner(false) --切换旗帜动作
        gameview._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
        --gameview._scene:setGameMode(4) --GAME_STATE.GAME_STATE_WAITTING_GAME2
	end

end

--是否能点击倍率按钮
function Game2ViewLayer:enableButton( enable )
	--半比
	local Button_half = self._csbNode:getChildByName("Button_half");
	Button_half:setEnabled(enable)
	--全比
	local Button_all = self._csbNode:getChildByName("Button_all");
	Button_all:setEnabled(enable)
	--倍比
	local Button_double = self._csbNode:getChildByName("Button_double");
	Button_double:setEnabled(enable)
end
--是否能点击押大押小等按钮
function Game2ViewLayer:enableDickButton( enable )
	--押小
	local Button_small = self._csbNode:getChildByName("Button_small");
	Button_small:setEnabled(enable)
	--押和
	local Button_middle = self._csbNode:getChildByName("Button_middle");
	Button_middle:setEnabled(enable)
	--押大
	local Button_big = self._csbNode:getChildByName("Button_big");
	Button_big:setEnabled(enable)
end


--设置下注元宝的位置
function Game2ViewLayer:setYuanBaoPostion( areaType )  --
	local spOneGold = self._csbNode:getChildByName("Sprite_oneGold")
	spOneGold:setVisible(true)
	if areaType == 1 then
		local Button_small = self._csbNode:getChildByName("Button_small");
		spOneGold:setPosition(Button_small:getPosition())
	elseif areaType == 2 then
		local Button_middle = self._csbNode:getChildByName("Button_middle");
		spOneGold:setPosition(Button_middle:getPosition())
	else
		local Button_big = self._csbNode:getChildByName("Button_big");
		spOneGold:setPosition(Button_big:getPosition())
	end
end
-- ---------------------------------------------------------------------------------------
------						游戏3 小玛丽
------------------------------------------------------------------------------------

function Game3ViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	self._scene = scene

    self.oneCircle = 24  --一圈大小
    self.m_cbLeftTime = 0     --倒计时时间
    self.time = 0.05
    self.count = 0
    self.endindex = -1
    self.index = 1

    self._scene:game3DataInit();
    self:initCsbRes();
	self._scene:sendReadyMsg3()   --发送准备消息
end

--界面初始化
function Game3ViewLayer:initCsbRes(  )
	rootLayer, self._csbNode = ExternalFun.loadRootCSB(GameViewLayer.RES_PATH .. "SHZ_Game3Layer.csb", self);
	--初始化按钮
	self:initUI(self._csbNode)
end

function Game3ViewLayer:initUI(  )
	--左边
	local animationL =cc.Animation:create()
	for i=1,2 do
	    local frameName = string.format(GameViewLayer.RES_PATH .. "game3/time_light/20L_0%d.png",i)
		--print("frameName =%s",frameName)	
	    local spriteFrame = cc.SpriteFrame:create(frameName,cc.rect(0,0,273,39))
	   animationL:addSpriteFrame(spriteFrame)
	end
   	animationL:setDelayPerUnit(0.5)          --设置两个帧播放时间                   
   	animationL:setRestoreOriginalFrame(false)    --动画执行后还原初始状态
   	local actionL =cc.Animate:create(animationL)
   	local nodeL = self._csbNode:getChildByName("Node_TimeL")
   	local spL = nodeL:getChildByName("Sprite_1")
   	spL:runAction(cc.RepeatForever:create(actionL))
	nodeL:setVisible(false)

   	--中间
	local animationM =cc.Animation:create()
	for i=1,2 do
	   	local frameName = string.format(GameViewLayer.RES_PATH .. "game3/time_light/500_0%d.png",i)
	    --print("frameName =%s",frameName)
	    local spriteFrame = cc.SpriteFrame:create(frameName,cc.rect(0,0,273,39))
	   animationM:addSpriteFrame(spriteFrame)
	end
   	animationM:setDelayPerUnit(0.5)          --设置两个帧播放时间                   
   	animationM:setRestoreOriginalFrame(false)    --动画执行后还原初始状态
   	local actionM =cc.Animate:create(animationM)
   	local nodeM = self._csbNode:getChildByName("Node_TimeM")
   	local spM = nodeM:getChildByName("Sprite_1")
   	spM:runAction(cc.RepeatForever:create(actionM))
	nodeM:setVisible(false)

   	--右边
   	local animationR =cc.Animation:create()
	for i=1,2 do
	   	local frameName = string.format(GameViewLayer.RES_PATH .. "game3/time_light/20R_0%d.png",i)
	    --print("frameName =%s",frameName)
	    local spriteFrame = cc.SpriteFrame:create(frameName,cc.rect(0,0,273,39))
	   animationR:addSpriteFrame(spriteFrame)
	end
   	animationR:setDelayPerUnit(0.5)          --设置两个帧播放时间                   
   	animationR:setRestoreOriginalFrame(false)    --动画执行后还原初始状态
   	local actionR =cc.Animate:create(animationR)
   	local nodeR = self._csbNode:getChildByName("Node_TimeR")
   	local spR = nodeR:getChildByName("Sprite_1")
   	spR:runAction(cc.RepeatForever:create(actionR))
	nodeR:setVisible(false)

	--游戏币
	self.m_textScore = self._csbNode:getChildByName("Text_Coins")
	self.m_textScore:setString(self._scene.m_lCoins)

	--压分
	self.m_textYafen = self._csbNode:getChildByName("Text_On")
	self.m_textYafen:setString(self._scene.m_lYafen3)

	--得到分数
	self.m_textGetScore = self._csbNode:getChildByName("Text_GetCoins")
    self.m_textGetScore:setString(0)

	--得到倍数
	self.m_textTimes = self._csbNode:getChildByName("Text_Times")
	self.m_textTimes:setString(0)
end

function Game3ViewLayer:game3Begin()
	self.m_textTimes:setString(#self._scene.m_pGame3Info)

	local pGameInfo = self._scene.m_pGame3Info[1]
	for i=1,4 do
		local pItem = GameItem:create()
        if pGameInfo.cbItem[1][i]+1 then
            pItem:created(pGameInfo.cbItem[1][i]+1)
        end
		local node = self._csbNode:getChildByName(string.format("Node_%d",i))
		if node then
			pItemLast = node:getChildByTag(1)
			if pItemLast then
				pItemLast:removeFromParent()
				pItemLast = nil 
			end
			node:addChild(pItem)
			pItem:setAnchorPoint(0.5,0.5)
			pItem:setContentSize(cc.size(210,145))
			pItem:setPosition(0,0)
			node:runAction(
				cc.Sequence:create(
					cc.CallFunc:create(function (  )
						pItem:beginMove(0.5+(i-1)*0.1)
                        ExternalFun.playSoundEffect("Threegundong.wav")
					end)
					)
				)
		end
	end
    local nodeM  = self._csbNode:getChildByName("Node_TimeM")
    nodeM:setVisible(false)
    local nodeL  = self._csbNode:getChildByName("Node_TimeL")
    nodeL:setVisible(false)
    local nodeR  = self._csbNode:getChildByName("Node_TimeR")
    nodeR:setVisible(false)
	if pGameInfo.lScore > 0 then
		if pGameInfo.lScore/self._scene.m_lYafen3 == 500 then
			nodeM:setVisible(true)
		elseif pGameInfo.lScore/self._scene.m_lYafen3 == 20 and pGameInfo.cbItem[1][1] == pGameInfo.cbItem[1][2] then
			nodeL:setVisible(true)
		else
			nodeR:setVisible(true)
		end
	end

	self:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(1.5),
			cc.CallFunc:create(function()
                if pGameInfo.lScore > 0 then
                    self:showPrize(tostring(pGameInfo.lScore))
                end

                local pGame3Result = self._scene.m_pGame3Result[1]
				self:game3Run(self.index,pGame3Result.cbIndex+1)

			end)
			)
		)

end
--改变分数
function Game3ViewLayer:showPrize( lScore )
    self.m_textGetScore:setString(tonumber(self.m_textGetScore:getString()) + lScore )
	-- self._scene.m_lCoins = self._scene.m_lCoins + lScore
	-- self.m_textScore:setString(self._scene.m_lCoins)
end

--启动转动动画
function Game3ViewLayer:game3Run(beginPos,endIndex)
    --local pGame3Result = self._scene.m_pGame3Result[self.m_lRunTime]
    self.endindex = endIndex--pGame3Result.cbIndex+1
    self.count = 0
    self.time = 0.05

    self:RunCircleAction(beginPos)
end

function Game3ViewLayer:RunCircleAction(beginPos)    --转动动画
    --ExternalFun.playSoundEffect("gundong.mp3")
    self.index = beginPos
    --光圈默认位置
    local spIcon = self._csbNode:getChildByName(string.format("sp_icon_%02d",beginPos))
    spIcon:setVisible(true)

    local hideIndex = self.oneCircle-math.mod(self.oneCircle-self.index + 1,self.oneCircle)
    local spIconHide = self._csbNode:getChildByName(string.format("sp_icon_%02d",hideIndex))

    local delay = cc.DelayTime:create(self.time)
    local call = cc.CallFunc:create(function()
        -- if self.spIcon == nil or self.spIconHide then
        --     return
        -- end
         local spIcon = self._csbNode:getChildByName(string.format("sp_icon_%02d",beginPos))
        if nil ~= spIcon then
            spIcon:setVisible(false)
        end

        self.index = math.mod(self.index,self.oneCircle) + 1
        self.count = self.count + 1

        local spNextIcon = self._csbNode:getChildByName(string.format("sp_icon_%02d",self.index))

        if nil ~= spNextIcon then
            spNextIcon:setVisible(true)
        end
        spNextIcon:stopAllActions()
        spNextIcon:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.2),cc.ScaleTo:create(0.1,1.0)))

        
        -- if self.count > self.oneCircle and self.count < self.oneCircle*2 then    
        --     self.time = self:getAddTime(self.count-self.oneCircle)
        if self.count > self.oneCircle * 2 and self.count < self.oneCircle*3 then
            self.time = self:getReduceTime(self.count-self.oneCircle * 2)

        elseif self.count >= self.oneCircle*3 then
            self.time = 0.3
            if self.index  == self.endindex  then
                self:SetEndView()
                return
            end
        end

        self:RunCircleAction(self.index)
    end)

    self:runAction(cc.Sequence:create(delay,call))
end
--递减
-- function Game3ViewLayer:getAddTime(index)
    
--     local a1 = 0.3
--     local per = (24-index+1)/24
--     local  time  = a1 - (0.3-0.05)*per

--     return time
-- end
--递增
function Game3ViewLayer:getReduceTime(index)
    
    local a1 = 0.05
    local per = index/(24)
    local  time  = a1 + (0.3-0.05)*per
    return time
end

function Game3ViewLayer:SetEndView()

    local nPrizeTimes = {
        5,7,1,8,6,-1,3,5,7,8,2,-1,
        4,6,8,5,3,-1,4,7,8,6,2,-1
    }

    local pGame3Result = self._scene.m_pGame3Result[1]
    local stopPos = pGame3Result.cbIndex+1

    local spIcon = self._csbNode:getChildByName(string.format("sp_icon_%02d",stopPos))
    spIcon:runAction(cc.Blink:create(2,12))

    --中奖突然闪烁
    if pGame3Result.lScore > 0 then
        local spTimes = self._csbNode:getChildByName(string.format("game3_times_%d",nPrizeTimes[stopPos]))
        if spTimes  then
            spTimes:runAction(
                cc.Sequence:create(
                    cc.Show:create(),
                    cc.Blink:create(2,12),
                    cc.Hide:create()
                    )
                )
        end
    end
    self:runAction(
        cc.Sequence:create(
            cc.CallFunc:create(function ()
                if pGame3Result.lScore > 0 then
                    self:showPrize(pGame3Result.lScore)
                end
            end),
            cc.DelayTime:create(2),
            cc.CallFunc:create(function (  )
                table.remove(self._scene.m_pGame3Result,1)
                if 0 < #self._scene.m_pGame3Result then  --and 0 < #self._scene.m_pGame3Info    --#self._scene.m_pGame3Result > 0  then
                    --发送准备消息
                    --self._scene:SendUserReady()
                    if pGame3Result.cbIndex == 5 or pGame3Result.cbIndex == 11 or pGame3Result.cbIndex == 17 or pGame3Result.cbIndex == 23  then
                        --print("不中奖")
                        table.remove(self._scene.m_pGame3Info,1)
                        self:game3Begin()
                    else
                        --print("中奖")
                        local pGame3Result2 = self._scene.m_pGame3Result[1]
                        self:game3Run(self.index,pGame3Result2.cbIndex+1)
                    end
                else
                    --小玛丽结束
                    --移除页面

                    self:backOneGame()
                    self._scene:sendThreeEnd()  --放弃
                end
            end)
            )
        )
end

function Game3ViewLayer:backOneGame()
	--切换回第一个游戏
	local gameview = self._scene._gameView
	gameview:setPosition(0,0)
	gameview:setVisible(true)

	self._scene:setGameMode(0) --GAME_STATE_WAITTING
    --刷新分数
    --self:showPrize(self._scene.m_lGetCoins3)
    self._scene.m_lCoins = self._scene.m_lCoins + self._scene.m_lGetCoins3
    if self._scene.m_lGetCoins > 0 then
        self._scene.m_lCoins = self._scene.m_lCoins + self._scene.m_lGetCoins
    end
    self._scene.m_lGetCoins3 = 0
    self._scene.m_lGetCoins = 0
    gameview.m_textScore:setString(self._scene.m_lCoins)
    gameview.m_textGetScore:setString(self._scene.m_lGetCoins)

	self:removeFromParent()

	if gameview._scene.m_bIsAuto == true  then
		gameview:runAction(
			cc.Sequence:create(
				cc.DelayTime:create(1),
				cc.CallFunc:create(function( )
                    gameview._scene:onGameStart()
                    gameview:game1ActionBanner(false) --切换旗帜动作
                    gameview._scene.m_cbGameStatus = g_var(cmd).SHZ_GAME_SCENE_FREE
                    --gameview._scene:setGameMode(4) --GAME_STATE.GAME_STATE_WAITTING_GAME2
				end)
				)
			)

	end

end

return GameViewLayer