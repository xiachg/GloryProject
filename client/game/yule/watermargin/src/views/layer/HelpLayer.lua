--
-- Author: luo
-- Date: 2016年12月26日 20:24:43
--
local HelpLayer = class("HelpLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

HelpLayer.BT_HOME = 1

function HelpLayer:ctor( )
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)

    local spHelp = display.newSprite("loading/preBg_01.png")
    spHelp:setPosition(yl.WIDTH/2,yl.HEIGHT/2)
    self:addChild(spHelp)

    local animation =cc.Animation:create()
	for i=1,4 do
		local frame = cc.SpriteFrame:create(string.format("loading/preBg_0%d.png",i),cc.rect(0,0,yl.WIDTH,yl.HEIGHT))
		animation:addSpriteFrame(frame)
	end
	animation:setDelayPerUnit(2)
	local pAction =cc.Animate:create(animation)

   	spHelp:runAction(
   		cc.Sequence:create(
   			pAction,
   			cc.CallFunc:create(function (  )
   				self:removeFromParent()
   			end)
   			)
   		)
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			local tag = sender:getTag()
			if HelpLayer.BT_HOME == tag then
				ExternalFun.playClickEffect()
				self:removeFromParent()
			end
		end
	end
	ccui.Button:create("game1_back_1.png", "game1_back_2.png", "p_bt_close_1.png")
	:move(yl.WIDTH -  50, yl.HEIGHT - 50)
	:setTag(HelpLayer.BT_HOME)
	:addTo(spHelp)
	:addTouchEventListener(btnEvent)
end

function HelpLayer:onTouchBegan( touch, event )
	return self:isVisible()
end

return HelpLayer