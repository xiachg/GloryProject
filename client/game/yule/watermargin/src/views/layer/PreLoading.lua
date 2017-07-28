--
-- Author: luo
-- Date: 2016年12月30日 17:46:35
-- 预加载资源
local PreLoading = {}
local module_pre = "game.yule.watermargin.src"
local res_path = "game/yule/watermargin/res/"
local cmd = module_pre .. ".models.CMD_Game"
local ExternalFun = require(appdf.EXTERNAL_SRC.."ExternalFun")
local g_var = ExternalFun.req_var
PreLoading.bLoadingFinish = false
PreLoading.loadingPer = 20
PreLoading.bFishData = false

function PreLoading.resetData()
	PreLoading.bLoadingFinish = false
	PreLoading.loadingPer = 20
	PreLoading.bFishData = false
end

function PreLoading.StopAnim(bRemove)
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = scene:getChildByTag(2000) 

	if not layer  then
		return
	end

	if not bRemove then
		-- if nil ~= PreLoading.fish then
		-- 	PreLoading.fish:stopAllActions()
		-- end
	else
	
		layer:stopAllActions()
		layer:removeFromParent()
	end
end

function PreLoading.loadTextures()
	local m_nImageOffset = 0

	local totalSource = 1 

	local plists = {"game1/gameAction/dagu.plist",
					"game1/gameAction/flash.plist",
					"game1/gameAction/game1_itemCommon.plist",
					"game1/gameAction/game1_itemJump.plist",
					"game1/gameAction/piaoqi.plist",
					"game1/gameAction/piaoqi2.plist",
					"game1/gameAction/shz_title.plist",
					"game1/itemAction/box_frame.plist",
					"game1/itemAction/dadao.plist",
					"game1/itemAction/futou.plist",
					"game1/itemAction/lin.plist",
					"game1/itemAction/lu.plist",
					"game1/itemAction/shuihuzhuan.plist",
					"game1/itemAction/song.plist",
					"game1/itemAction/titianxingdao.plist",
					"game1/itemAction/yinqiang.plist",
					"game1/itemAction/zhongyitang.plist",
					"game1/itemAction/light.plist",

					"game2/dealer/dealer_common.plist",
					"game2/dealer/dealer_anger1.plist",
					"game2/dealer/dealer_anger2.plist",
					"game2/dealer/dealer_cry.plist",
					"game2/dealer/dealer_dice1.plist",
					"game2/dealer/dealer_dice2.plist",
					"game2/dealer/dealer_happy.plist",
					"game2/dealer/dealer_open.plist",

					"game2/left/left_cheer.plist",
					"game2/left/left_common.plist",
					"game2/left/left_cry.plist",
					"game2/left/left_happy.plist",

					"game2/right/right_cheer1.plist",
					"game2/right/right_cheer2.plist",
					"game2/right/right_common.plist",
					"game2/right/right_common2.plist",
					"game2/right/right_cry.plist",
					"game2/right/right_happy.plist",

					"game2/desk/desk.plist",
					"game2/gold_action/gold.plist",

					"setting/setLayer.plist"
				   }

	local function imageLoaded(texture)--texture
		
        m_nImageOffset = m_nImageOffset + 1
		print("m_nImageOffset",m_nImageOffset)
		print("totalSource",totalSource)	
        if m_nImageOffset == totalSource then
        	
        	--加载PLIST
        	for i=1,#plists do
        		cc.SpriteFrameCache:getInstance():addSpriteFrames(res_path..plists[i])
        		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i])
        		local framesDict = dict["frames"]
				if nil ~= framesDict and type(framesDict) == "table" then
					for k,v in pairs(framesDict) do
						local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
						if nil ~= frame then
							frame:retain()
						end
					end
				end
        	end

        	PreLoading.readAniams()
        	PreLoading.bLoadingFinish = true

			--通知
			local event = cc.EventCustom:new(g_var(cmd).Event_LoadingFinish)
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

			if PreLoading.bFishData  then
				PreLoading.bFishData = false
				local scene = cc.Director:getInstance():getRunningScene()
				local layer = scene:getChildByTag(2000) 
				if not layer  then
					return
				end
				PreLoading.loadingPer = 100
				PreLoading.updatePercent(PreLoading.loadingPer)

				local callfunc1 = cc.CallFunc:create(function()
					PreLoading.loadingBG:loadTexture(res_path.."loading/preBg_02.png")
				end)
				local callfunc2 = cc.CallFunc:create(function()
					PreLoading.loadingBG:loadTexture(res_path.."loading/preBg_03.png")
				end)
				local callfunc3 = cc.CallFunc:create(function()
					PreLoading.loadingBG:loadTexture(res_path.."loading/preBg_04.png")
				end)
				local callfunc4 = cc.CallFunc:create(function()
					PreLoading.loadingBar:stopAllActions()
					PreLoading.loadingBar = nil
					layer:stopAllActions()
					layer:removeFromParent()

				end)
				layer:stopAllActions()
				layer:runAction(cc.Sequence:create(callfunc1,cc.DelayTime:create(0.8),callfunc2,cc.DelayTime:create(0.8),callfunc3,cc.DelayTime:create(0.8),callfunc4))
			end
        	print("资源加载完成")
        end
    end
    local function 	loadImages()
    	cc.Director:getInstance():getTextureCache():addImageAsync(res_path.."game1/gameAction/game1_itemCommon.png", imageLoaded)
    end
    local function createSchedule( )
    	local function update( dt )
			PreLoading.updatePercent(PreLoading.loadingPer)
		end
		local scheduler = cc.Director:getInstance():getScheduler()
		PreLoading.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
    end
	--进度条
	PreLoading.GameLoadingView()

	loadImages()
	--createSchedule()
	PreLoading.addEvent()
end

function PreLoading.unloadTextures( )

	local plists = {"game1/gameAction/dagu.plist",
					"game1/gameAction/flash.plist",
					"game1/gameAction/game1_itemCommon.plist",
					"game1/gameAction/game1_itemJump.plist",
					"game1/gameAction/piaoqi.plist",
					"game1/gameAction/piaoqi2.plist",
					"game1/gameAction/shz_title.plist",
					"game1/itemAction/box_frame.plist",
					"game1/itemAction/dadao.plist",
					"game1/itemAction/futou.plist",
					"game1/itemAction/lin.plist",
					"game1/itemAction/lu.plist",
					"game1/itemAction/shuihuzhuan.plist",
					"game1/itemAction/song.plist",
					"game1/itemAction/titianxingdao.plist",
					"game1/itemAction/yinqiang.plist",
					"game1/itemAction/zhongyitang.plist",
					"game1/itemAction/light.plist",

					"game2/dealer/dealer_common.plist",
					"game2/dealer/dealer_anger1.plist",
					"game2/dealer/dealer_anger2.plist",
					"game2/dealer/dealer_cry.plist",
					"game2/dealer/dealer_dice1.plist",
					"game2/dealer/dealer_dice2.plist",
					"game2/dealer/dealer_happy.plist",
					"game2/dealer/dealer_open.plist",

					"game2/left/left_cheer.plist",
					"game2/left/left_common.plist",
					"game2/left/left_cry.plist",
					"game2/left/left_happy.plist",

					"game2/right/right_cheer1.plist",
					"game2/right/right_cheer2.plist",
					"game2/right/right_common.plist",
					"game2/right/right_common2.plist",
					"game2/right/right_cry.plist",
					"game2/right/right_happy.plist",

					"game2/desk/desk.plist",
					"game2/gold_action/gold.plist",

					"setting/setLayer.plist"
				   }

	for i=1,#plists do
		local dict = cc.FileUtils:getInstance():getValueMapFromFile(res_path..plists[i])

		local framesDict = dict["frames"]
		if nil ~= framesDict and type(framesDict) == "table" then
			for k,v in pairs(framesDict) do
				local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
				if nil ~= frame then
					frame:release()
				end
			end
		end
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(res_path..plists[i])
	end

	--cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(res_path .. "game1/gameAction/dagu.plist")
    --cc.Director:getInstance():getTextureCache():removeTextureForKey("gameAction/dagu.png.png")
    
 	cc.Director:getInstance():getTextureCache():removeTextureForKey(res_path.."game1/gameAction/game1_itemCommon.png")

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

function PreLoading.addEvent()
   --通知监听
  local function eventListener(event)
	PreLoading.Finish()
  end
  local listener = cc.EventListenerCustom:create(g_var(cmd).Event_LoadingFinish, eventListener)
  cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function PreLoading.Finish()
	PreLoading.bFishData = true
	if  PreLoading.bLoadingFinish then
		local scene = cc.Director:getInstance():getRunningScene()
		local layer = scene:getChildByTag(2000) 
		if nil ~= layer then
			local callfunc = cc.CallFunc:create(function()
				PreLoading.loadingBar:stopAllActions()
				PreLoading.loadingBar = nil
				layer:stopAllActions()
				layer:removeFromParent()
			end)
			layer:stopAllActions()
			layer:runAction(cc.Sequence:create(cc.DelayTime:create(3.3),callfunc))
		end
	end
end

function PreLoading.GameLoadingView()
	local scene = cc.Director:getInstance():getRunningScene()
	local layer = display.newLayer()
	layer:setTag(2000)
	scene:addChild(layer,30)

	PreLoading.loadingBG = ccui.ImageView:create(res_path.."loading/preBg_01.png")
	PreLoading.loadingBG:setTag(1)
	PreLoading.loadingBG:setTouchEnabled(true)
	PreLoading.loadingBG:setPosition(cc.p(yl.WIDTH/2,yl.HEIGHT/2))
	layer:addChild(PreLoading.loadingBG)

	local loadingBarBG = ccui.ImageView:create(res_path.."loading/progress_bar_bg.png")
	loadingBarBG:setTag(2)
	loadingBarBG:setPosition(cc.p(yl.WIDTH/2,12))
	layer:addChild(loadingBarBG)

	PreLoading.loadingBar = cc.ProgressTimer:create(cc.Sprite:create(res_path.."loading/progress_bar.png"))
	PreLoading.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	PreLoading.loadingBar:setMidpoint(cc.p(0.0,0.5))
	PreLoading.loadingBar:setBarChangeRate(cc.p(1,0))
    PreLoading.loadingBar:setPosition(cc.p(loadingBarBG:getContentSize().width/2,loadingBarBG:getContentSize().height/2))
    PreLoading.loadingBar:runAction(cc.ProgressTo:create(0.2,20))
    loadingBarBG:addChild(PreLoading.loadingBar)
end

function PreLoading.updatePercent(percent )
	if nil ~= PreLoading.loadingBar then
		local dt = 1.0
		if percent == 100 then
			dt = 2.0
		end
		PreLoading.loadingBar:runAction(cc.ProgressTo:create(dt,percent))
	end

	if PreLoading.bLoadingFinish  then
		if nil ~= PreLoading.m_scheduleUpdate then
    		local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(PreLoading.m_scheduleUpdate)
			PreLoading.m_scheduleUpdate = nil
		end
	end
end

--[[
@function : readAnimation
@file : 资源文件
@key  : 动作 key
@num  : 幀数
@time : float time 
@formatBit 

]]
function PreLoading.readAnimation(file, key, num, time,formatBit)
   	local animation =cc.Animation:create()
	for i=1,num do
		local frameName
		if formatBit == 1 then
			frameName = string.format(file.."%d.png", i)
		elseif formatBit == 2 then
		 	frameName = string.format(file.."%02d.png", i)
		end
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) 
		animation:addSpriteFrame(frame)
	end
	animation:setDelayPerUnit(time)
   	cc.AnimationCache:getInstance():addAnimation(animation, key)
end

function PreLoading.readAniByFileName( file,width,height,rownum,linenum,savename)
	local frames = {}
	for i=1,rownum do
		for j=1,linenum do
			local frame = cc.SpriteFrame:create(file,cc.rect(width*(j-1),height*(i-1),width,height))
			table.insert(frames, frame)
		end
	end
	local  animation =cc.Animation:createWithSpriteFrames(frames,0.03)
   	cc.AnimationCache:getInstance():addAnimation(animation, savename)
end

function PreLoading.removeAllActions()
    cc.AnimationCache:getInstance():removeAnimation("daguAnim")
    cc.AnimationCache:getInstance():removeAnimation("titleAnim")
    cc.AnimationCache:getInstance():removeAnimation("wYaoqiAnim")
    cc.AnimationCache:getInstance():removeAnimation("rYaoqiAnim")
    cc.AnimationCache:getInstance():removeAnimation("flashAnim")

    cc.AnimationCache:getInstance():removeAnimation("game1BoxAnim")
    cc.AnimationCache:getInstance():removeAnimation("lightAnim")

    cc.AnimationCache:getInstance():removeAnimation("dealerComAnim")
    cc.AnimationCache:getInstance():removeAnimation("leftComAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightComAnim")
    cc.AnimationCache:getInstance():removeAnimation("deskAnim")
    cc.AnimationCache:getInstance():removeAnimation("goldAnim")

    cc.AnimationCache:getInstance():removeAnimation("dealerDiceAnim")
    cc.AnimationCache:getInstance():removeAnimation("leftCheerAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightCheerAnim")

    cc.AnimationCache:getInstance():removeAnimation("dealerOpenAnim")
    cc.AnimationCache:getInstance():removeAnimation("dealerAngerAnim")
    cc.AnimationCache:getInstance():removeAnimation("dealerHappyAnim")

    cc.AnimationCache:getInstance():removeAnimation("leftHappyAnim")
    cc.AnimationCache:getInstance():removeAnimation("leftCryAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightHappyAnim")
    cc.AnimationCache:getInstance():removeAnimation("rightCryAnim")
end

function PreLoading.readAniams()
 	--game1
    PreLoading.readAnimation("action_dagu_", "daguAnim", g_var(cmd).ACT_DAGU_NUM,0.1,2);
    PreLoading.readAnimation("action_title_", "titleAnim", g_var(cmd).ACT_TITLE_NUM,0.3,2);
 	PreLoading.readAnimation("action_wyaoqi_", "wYaoqiAnim", g_var(cmd).ACT_QIZHIWAIT_NUM,0.1,2);
	PreLoading.readAnimation("action_ryaoqi_", "rYaoqiAnim", g_var(cmd).ACT_QIZHI_NUM,0.1,2);
	PreLoading.readAnimation("game1_flash_", "flashAnim", 10,0.1,2);
	PreLoading.readAnimation("game1_box_", "game1BoxAnim",6,0.1,1);
	PreLoading.readAnimation("common_light_", "lightAnim",9,0.1,2);
	--game2
	PreLoading.readAnimation("dealer_common_0","dealerComAnim",8,0.1,1);
	PreLoading.readAnimation("left_common_", "leftComAnim",27,0.1,2);
	PreLoading.readAnimation("right_common_", "rightComAnim",25,0.5,2);
	PreLoading.readAnimation("desk_", "deskAnim",5,0.1,1);
	PreLoading.readAnimation("game2_Gold_", "goldAnim",4,0.1,1);

	PreLoading.readAnimation("dealer_dice_", "dealerDiceAnim",29,0.1,2);
	PreLoading.readAnimation("left_cheer_", "leftCheerAnim",29,0.1,2);
	PreLoading.readAnimation("right_cheer_", "rightCheerAnim",29,0.1,2);
	PreLoading.readAnimation("desk_", "deskAnim",5,0.1,1);
	PreLoading.readAnimation("game2_Gold_", "goldAnim",4,0.1,1);

	PreLoading.readAnimation("dealer_open_", "dealerOpenAnim",14,0.1,2);
	PreLoading.readAnimation("dealer_anger_", "dealerAngerAnim",25,0.1,2);
	PreLoading.readAnimation("dealer_happy_0", "dealerHappyAnim",7,0.3,1);

	PreLoading.readAnimation("left_happy_", "leftHappyAnim",55,0.1,2);
	PreLoading.readAnimation("left_cry_", "leftCryAnim",36,0.1,2);

	PreLoading.readAnimation("right_happy_", "rightHappyAnim",18,0.1,2);
	PreLoading.readAnimation("right_cry_", "rightCryAnim",26,0.1,2);
end

return PreLoading