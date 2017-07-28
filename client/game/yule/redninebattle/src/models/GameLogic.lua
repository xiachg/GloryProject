local GameLogic = GameLogic or {}

--牌值掩码
GameLogic.MASK_VALUE			= 0X0F
--花色掩码
GameLogic.MASK_COLOR			= 0XF0
--最大手牌数目
GameLogic.MAX_CARDCOUNT			= 20
--牌库数目
GameLogic.FULL_COUNT			= 54
--正常手牌数目
GameLogic.NORMAL_COUNT			= 17

--排序类型
--大小排序
GameLogic.ST_ORDER				= 1
--数目排序
GameLogic.ST_COUNT				= 2
--自定排序
GameLogic.ST_CUSTOM				= 3

--扑克数目
GameLogic.CARD_COUNT				= 32								--扑克数目

--牌型
GameLogic.CT_ERROR					= 0									--错误类型
GameLogic.CT_POINT					= 1									--点数类型
GameLogic.CT_SPECIAL_19				= 2									--特殊类型
GameLogic.CT_SPECIAL_18				= 3									--特殊类型
GameLogic.CT_SPECIAL_17				= 4									--特殊类型
GameLogic.CT_SPECIAL_16				= 5									--特殊类型
GameLogic.CT_SPECIAL_15				= 6									--特殊类型
GameLogic.CT_SPECIAL_14				= 7									--特殊类型
GameLogic.CT_SPECIAL_13				= 8									--特殊类型
GameLogic.CT_SPECIAL_12				= 9									--特殊类型
GameLogic.CT_SPECIAL_11				= 10								--特殊类型
GameLogic.CT_SPECIAL_10				= 11								--特殊类型
GameLogic.CT_SPECIAL_9				= 12								--特殊类型
GameLogic.CT_SPECIAL_8				= 13								--特殊类型
GameLogic.CT_SPECIAL_7				= 14								--特殊类型
GameLogic.CT_SPECIAL_6				= 15								--特殊类型
GameLogic.CT_SPECIAL_5				= 16								--特殊类型
GameLogic.CT_SPECIAL_4				= 17								--特殊类型
GameLogic.CT_SPECIAL_3				= 18								--特殊类型
GameLogic.CT_SPECIAL_2				= 19								--特殊类型
GameLogic.CT_SPECIAL_1				= 20								--特殊类型

------------------------------------------------------------------
--类型函数

--获取类型
--param[cbCardDataTable] 扑克数据table
--[[function GameLogic.GetCardType( cbCardDataTable )
	
end]]

--获取类型
function GameLogic.GetBackCardType( cbCardDataTable )
	-- body
end

--获取数值
function GameLogic.GetCardValue( cbCardData )
	return bit:_and(cbCardData, GameLogic.MASK_VALUE);
end
------------------------------------------------------------------

------------------------------------------------------------------
--控制函数

function GameLogic.SortCardList( cbCardDataTable, cbSortType )
	local cbCount = #cbCardDataTable;
	--数目过滤cmd.RES_PATH..
	if cbCount == 0 or cbCount > 10 then
		return;
	end

	cbSortType = cbSortType or GameLogic.ST_ORDER;
	if cbSortType == GameLogic.ST_CUSTOM then
		return;
	end

	--转换数值
	local cbSortValue = {};
	for i=1,cbCount do		
		cbSortValue[i] = GameLogic.GetCardValue(cbCardDataTable[i])
	end

	--排序操作
	local bSorted = true;
	local cbLast = cbCount - 1;
	repeat
		bSorted = true;
		for i=1,cbLast do
			if (cbSortValue[i] < cbSortValue[i+1])
				or ((cbSortValue[i] == cbSortValue[i + 1]) and (cbCardDataTable[i] < cbCardDataTable[i + 1])) then
				--设置标志
				bSorted = false;

				--扑克数据
				cbCardDataTable[i], cbCardDataTable[i + 1] = cbCardDataTable[i + 1], cbCardDataTable[i];				

				--排序权位
				cbSortValue[i], cbSortValue[i + 1] = cbSortValue[i + 1], cbSortValue[i];
			end
		end
		cbLast = cbLast - 1;
	until bSorted ~= false;
end
------------------------------------------------------------------

------------------------------------------------------------------
--逻辑函数

function GameLogic.GetCardListPip(cbCardData, cbCardCount)
	--变量定义
	local cbPipCount=0;

	--获取牌点
	local cbCardValue=0;
	for i=1,cbCardCount do
		cbCardValue = GameLogic.GetCardValue(cbCardData[i])

        local v = 6
        if 1 ~= cbCardValue then
            v = cbCardValue
        end

		cbPipCount = cbPipCount + v
	end

	return cbPipCount % 10
end

function GameLogic.CompareCard(cbFirstCardData, cbFirstCardCount, cbNextCardData, cbNextCardCount)
	--获取牌型
	local cbFirstCardType = GameLogic.GetCardType(cbFirstCardData, cbFirstCardCount);
	local cbNextCardType = GameLogic.GetCardType(cbNextCardData, cbNextCardCount);

	--牌型比较
	if cbFirstCardType ~= cbNextCardType then
		if cbNextCardType > cbFirstCardType then
            return 1
		else 
            return -1
        end
	end

	--特殊牌型判断
	if GameLogic.CT_POINT ~= cbFirstCardType and cbFirstCardType == cbNextCardType then
		return -1
	end

	--获取点数
	local cbFirstPip = GameLogic.GetCardListPip(cbFirstCardData, cbFirstCardCount)
	local cbNextPip = GameLogic.GetCardListPip(cbNextCardData, cbNextCardCount)

	--点数比较
	if cbFirstPip ~= cbNextPip then
		if cbNextPip > cbFirstPip then
            return 1
		else
            return -1
        end
	end

	--零点判断
	if 0==cbFirstPip and 0==cbNextPip then
        return -1
    end

	local cbFirstLogicValue = GameLogic.GetCardPointLogicValue(cbFirstCardData, cbFirstCardCount)
	local cbNextLogicValue = GameLogic.GetCardPointLogicValue(cbNextCardData, cbNextCardCount)
	if cbFirstLogicValue ~= cbNextLogicValue then
		if cbNextLogicValue > cbFirstLogicValue then
            return 1
		else
            return -1
        end
	end

	return -1;
end

function GameLogic.GetCardType(cbCardData, cbCardCount)
	--双天
	if (12==cbCardData[1] and 44==cbCardData[2]) or (12==cbCardData[2] and 44==cbCardData[1]) then return GameLogic.CT_SPECIAL_1 end   	
	--双地
	if (2==cbCardData[1] and 34==cbCardData[2]) or (2==cbCardData[2] and 34==cbCardData[1]) then return GameLogic.CT_SPECIAL_2 end
	--至尊
	if (49==cbCardData[1] and 51==cbCardData[2]) or (49==cbCardData[2] and 51==cbCardData[1]) then return GameLogic.CT_SPECIAL_3 end 
	--双人
	if (8==cbCardData[1] and 40==cbCardData[2]) or (8==cbCardData[2] and 40==cbCardData[1]) then return GameLogic.CT_SPECIAL_4 end 
	--双和
	if (4==cbCardData[1] and 36==cbCardData[2]) or (4==cbCardData[2] and 36==cbCardData[1]) then return GameLogic.CT_SPECIAL_5 end
	--双梅
	if (26==cbCardData[1] and 58==cbCardData[2]) or (26==cbCardData[2] and 58==cbCardData[1]) then return GameLogic.CT_SPECIAL_6 end
	--双长
	if (22==cbCardData[1] and 54==cbCardData[2]) or (22==cbCardData[2] and 54==cbCardData[1]) then return GameLogic.CT_SPECIAL_7 end
	--双板凳
	if (20==cbCardData[1] and 52==cbCardData[2]) or (20==cbCardData[2] and 52==cbCardData[1]) then return GameLogic.CT_SPECIAL_8 end
	--双斧头
	if (27==cbCardData[1] and 59==cbCardData[2]) or (27==cbCardData[2] and 59==cbCardData[1]) then return GameLogic.CT_SPECIAL_9 end
	--双红头
	if (10==cbCardData[1] and 42==cbCardData[2]) or (10==cbCardData[2] and 42==cbCardData[1]) then return GameLogic.CT_SPECIAL_10 end
	--双铜锤
	if (7==cbCardData[1] and 39==cbCardData[2]) or (7==cbCardData[2] and 39==cbCardData[1]) then return GameLogic.CT_SPECIAL_11 end
	--双幺五
	if (6==cbCardData[1] and 38==cbCardData[2]) or (6==cbCardData[2] and 38==cbCardData[1]) then return GameLogic.CT_SPECIAL_12 end
	--杂九
	if (9==cbCardData[1] and 41==cbCardData[2]) or (9==cbCardData[2] and 41==cbCardData[1]) then return GameLogic.CT_SPECIAL_13 end
	--杂八
	if (24==cbCardData[1] and 56==cbCardData[2]) or (24==cbCardData[2] and 56==cbCardData[1]) then return GameLogic.CT_SPECIAL_14 end
	--杂七
	if (23==cbCardData[1] and 55==cbCardData[2]) or (23==cbCardData[2] and 55==cbCardData[1]) then return GameLogic.CT_SPECIAL_15 end
	--杂五
	if (5==cbCardData[1] and 37==cbCardData[2]) or (5==cbCardData[2] and 37==cbCardData[1]) then return GameLogic.CT_SPECIAL_16 end
	--获取点数
	local cbFirstCardValue = GameLogic.GetCardValue(cbCardData[1])
	local cbSecondCardValue = GameLogic.GetCardValue(cbCardData[2])
	--天九王
	if (12==cbFirstCardValue and 9==cbSecondCardValue) or (9==cbFirstCardValue and 12==cbSecondCardValue) then return GameLogic.CT_SPECIAL_17 end
	--天杠
	if (12==cbFirstCardValue and 8==cbSecondCardValue) or (8==cbFirstCardValue and 12==cbSecondCardValue) then return GameLogic.CT_SPECIAL_18 end
	--地杠
	if (2==cbFirstCardValue and 8==cbSecondCardValue) or (8==cbFirstCardValue and 2==cbSecondCardValue) then return GameLogic.CT_SPECIAL_19 end
	--点数牌型
	return GameLogic.CT_POINT
end

--逻辑大小
function GameLogic.GetCardLogicValue(cbCardData)
	--获取数值
	local cbValue = GameLogic.GetCardValue(cbCardData)

	--红桃方片Q
	if 12==cbCardData or 44==cbCardData then return 17 end
	--红桃方片2
	if 2==cbCardData or 34==cbCardData then return 16 end
	--红桃方片8
	if 8==cbCardData or 40==cbCardData then return 15 end
	--红桃方片4
	if 4==cbCardData or 36==cbCardData then return 14 end
	--黑桃梅花10
	if 26==cbCardData or 58==cbCardData then return 13 end
	--黑桃梅花6
	if 22==cbCardData or 54==cbCardData then return 12 end
	--黑桃梅花4
	if 20==cbCardData or 52==cbCardData then return 11 end
	--红桃方片J *判断黑桃梅花J
	if 27==cbCardData or 59==cbCardData then return 10 end
	--红桃方片10
	if 10==cbCardData or 42==cbCardData then  return 9 end
	--红桃方片7
	if 7==cbCardData or 39==cbCardData then return 8 end
	--红桃方片6
	if 6==cbCardData or 38==cbCardData then return 7 end
	--红桃方片9
	if 9==cbCardData or 41==cbCardData then return 6 end
	--黑桃梅花8
	if 24==cbCardData or 56==cbCardData then  return 5 end
	--黑桃梅花7
	if 23==cbCardData or 55==cbCardData then return 4 end
	--红桃方片5
	if 5==cbCardData or 37==cbCardData then return 3 end
	--黑桃A
	if 49==cbCardData then return 2 end
	--黑桃3
	if 51==cbCardData then return 1 end

	return 0
end

--逻辑大小
function GameLogic.GetCardPointLogicValue(cbCardData, cbCardCount)
	--数目过虑
	if cbCardCount==0 then
        return 0
    end

	local cbMaxValue = 0
	local cbCardValue = {0,0}
	for i=1,cbCardCount do
		cbCardValue[i] = GameLogic.GetCardLogicValue(cbCardData[i])	

		if cbCardValue[i] > cbMaxValue then
			cbMaxValue = cbCardValue[i]
        end
	end

	return cbMaxValue
end
------------------------------------------------------------------

return GameLogic;