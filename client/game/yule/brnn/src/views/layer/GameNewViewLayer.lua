--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC.."HeadSprite")

local Game_CMD = appdf.req(appdf.GAME_SRC.."yule.brnn.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.brnn.src.models.GameLogic")

local CardSprite = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.CardSprite")
local SitRoleNode = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.SitRoleNode")

--弹出层
local SettingLayer = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.SettingLayer")
local UserListLayer = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.UserListLayer")
local ApplyListLayer = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.ApplyListLayer")
local GameRecordLayer = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.GameRecordLayer")
local GameResultLayer = appdf.req(appdf.GAME_SRC.."yule.brnn.src.views.layer.GameResultLayer")

local GameNewViewLayer = class("GameNewViewLayer",function(scene)
        local gameViewLayer = display.newLayer()
    return gameViewLayer
end)

function GameNewViewLayer:ctor(scene)
	self._scene = scene
	--加载资源
	self:loadResource()
end

function GameNewViewLayer:loadResource()
    --加载卡牌纹理
    cc.Director:getInstance():getTextureCache():addImage("im_card.png")

    local rootLayer, csbNode = ExternalFun.loadRootCSB("GameScene.csb", self)

end

return GameNewViewLayer
--endregion
