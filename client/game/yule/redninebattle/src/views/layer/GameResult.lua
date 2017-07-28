--
-- Author: zhong
-- Date: 2016-07-04 19:06:23
--
--游戏结果层
local GameResultLayer = class("GameResultLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local module_pre = "game.yule.redninebattle.src"
local cmd = module_pre .. ".models.CMD_Game"

function GameResultLayer:ctor( )
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("GameResult.csb",self)
	
    --本家得分
	self.m_meScore = csbNode:getChildByName("lb_me_score")
	--本家返还分
	self.m_meScoreReturn = csbNode:getChildByName("lb_me_score_0")
	--闲点数
	self.m_bankerScore = csbNode:getChildByName("lb_banker_score")

	self:hideGameResult()
end

function GameResultLayer:hideGameResult( )
	self:reSet()
	self:setVisible(false)
end

function GameResultLayer:showGameResult( rs )
	self:reSet()
	self:setVisible(true)

    local function scoreToString(score)
        local str = ""
        if score >= 0 then
            str = tostring(score)--string.format("%d", score)
        else
            str = "."..tostring(-score)--string.format(".%d", math.abs(score))
        end
        return str
    end

	self.m_meScore:setString( scoreToString(rs.lEndUserScore) )
	self.m_meScoreReturn:setString( scoreToString(rs.lEndUserReturnScore) )
	self.m_bankerScore:setString( scoreToString(rs.lEndBankerScore) )
end

function GameResultLayer:reSet( )
	self.m_meScore:setString("0")
	self.m_meScoreReturn:setString("0")
	self.m_bankerScore:setString("0")
end
return GameResultLayer