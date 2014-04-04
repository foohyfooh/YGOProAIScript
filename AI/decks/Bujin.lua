Bujin = nil
function BujinCheck()
  if Bujin == nil then
    Bujin = HasID(UseLists({AIDeck(),AIHand()}),32339440) -- check if the deck has Yamato
  end 
  return Bujin
end

BujinPrio = {}
-- {hand,hand+,field,field+,grave,grave+,banished}
--  "+" == has one already
BujinPrio[32339440] = {9,2,9,5,1,1,2} -- Yamato
BujinPrio[53678698] = {5,1,5,4,2,1,2} -- Mikazuchi
BujinPrio[23979249] = {3,1,3,3,2,1,2} -- Arasuda
BujinPrio[09418365] = {4,1,4,3,2,1,2} -- Hirume
BujinPrio[68601507] = {7,2,0,0,0,0,2} -- Crane
BujinPrio[59251766] = {3,1,2,2,9,5,0} -- Hare
BujinPrio[05818294] = {3,1,2,2,8,4,0} -- Turtle
BujinPrio[69723159] = {2,1,2,2,7,3,0} -- Quilin
BujinPrio[88940154] = {2,1,2,2,6,3,0} -- Centipede
BujinPrio[50474354] = {3,1,0,0,2,2,5} -- Peacock
BujinPrio[37742478] = {8,2,0,0,0,0,2} -- Honest

BujinPrio[73906480] = {4,2,0,0,0,0,0} -- Bujincarnation
BujinPrio[30338466] = {3,1,0,0,0,0,0} -- Bujin Regalia - The Sword
BujinPrio[57103969] = {8,1,0,0,0,0,0} -- Fire Formation - Tenki
BujinPrio[98645731] = {1,0,0,0,4,3,0} -- Pot of Duality
BujinPrio[81439173] = {1,0,0,0,3,2,0} -- Foolish Burial
BujinPrio[05318639] = {2,1,0,0,2,1,0} -- Mystical Space Typhoon
BujinPrio[27243130] = {2,1,0,0,2,1,0} -- Forbidden Lance
BujinPrio[78474168] = {1,1,0,0,3,3,0} -- Breakthrough Skill
BujinPrio[94192409] = {2,1,0,0,2,1,0} -- Compulsory Evacuation Device
BujinPrio[53582587] = {2,1,0,0,2,1,0} -- Torrential Tribute
BujinPrio[84749824] = {3,1,0,0,2,1,0} -- Solemn Warning
BujinPrio[29401950] = {2,1,0,0,2,1,0} -- Bottomless Trap Hole

function BujinGetPriority(id,loc)
  local index = 0
  local checklist = nil
  local result = 0
  if loc == LOCATION_HAND then
    index = 1
    checklist = AIHand()
    if id==32339440 or id==53678698 then checklist = UseLists({AIHand(),AIMon()}) end
  elseif loc == LOCATION_FIELD then
    index = 3
    checklist = AIMon()
  elseif loc == LOCATION_GRAVE then
    index = 5
    checklist = AIGrave()
  elseif loc == LOCATION_REMOVED then
    index = 7
  else
    --print("unknown location requested")
  end
  if checklist and HasID(checklist,id,true) then index=index+1 end
  checklist = BujinPrio[id]
  if checklist and checklist[index] then result = checklist[index] end
  return result
end
function BujinAssignPriority(cards,loc)
  local index = 0
  for i=1,#cards do
    cards[i].index=i
    cards[i].prio=BujinGetPriority(cards[i].id,loc)
  end
end
function BujinPriorityCheck(cards,loc,count)
  if count == nil then count = 1 end
  if loc==nil then loc=LOCATION_HAND end
  if #cards==0 then return -1 end
  BujinAssignPriority(cards,loc)
  table.sort(cards,function(a,b) return a.prio>b.prio end)
  return cards[count].prio
end
function BujinAdd(cards,loc,count)
  local result={}
  if count==nil then count=1 end
  if loc==nil then loc=LOCATION_HAND end
  local compare = function(a,b) return a.prio>b.prio end
  BujinAssignPriority(cards,loc)
  table.sort(cards,compare)
  for i=1,count do
    result[i]=cards[i].index
  end
  return result
end
function SummonMikazuchi()
  return OverExtendCheck()
end
function SummonArasuda()
  return OverExtendCheck()
end
function SummonSusanowo()
  local cards=OppMon()
  return #cards>2 or not HasID(UseLists({AIMon(),AIHand()}),32339440,true)
  or OppHasStrongestMonster() and Get_Card_Att_Def(cards,"attack",">",POS_FACEUP_ATTACK,"attack")<4800
end
function SummonKagutsuchi()
  local cards=AIMon()
  return Chance(30) and not HasID(AIMon(),32339440,true) 
end
function SummonTsukuyomi()
  return UseTsukuyomi(AIHand())
end
function UseTsukuyomi(cards)
  return #cards==1 and BujinPriorityCheck(cards,LOCATION_GRAVE)>3 
  or #cards==2 and BujinPriorityCheck(cards,LOCATION_GRAVE,2)>4
end
function AmaterasuFilter(card)
  return card and card.level==4 and bit32.band(card.setcode,0x88)>0
end
function SummonAmaterasu()
  return CardsMatchingFilter(AIBanish(),AmaterasuFilter)>2 and BujinPriorityCheck(AIBanish(),LOCATION_GRAVE,2)>4
end
function SummonHirume()
  return OverExtendCheck() and BujinPriorityCheck(AIGrave(),LOCATION_REMOVED)>0
end
function UseBujincarnation()
  return true
end
function UseQuilin()
  local cards=OppST()
  local result = 0
  for i=1,#cards do
    if bit32.band(cards[i].position,POS_FACEUP)>0
    and cards[i]:is_affected_by(EFFECT_INDESTRUCTIBLE_EFFECT)==0
    and cards[i]:is_affected_by(EFFECT_IMMUNE_EFFECT)==0
    then
      result = result +1
    end
  end
  return OppHasStrongestMonster() or result>0
end
function UseCentipede()
  return true
end
function UseRegaliaGrave()
	local cg = RemovalCheck()
	if cg then
		if cg:IsExists(function(c) return c:IsControler(player_ai) and c:IsCode(30338466) end, 1, nil) then
      if BujinPriorityCheck(AIGrave())>2 then --and BujinPriorityCheck(AIBanish(),LOCATION_GRAVE)<=3
        GlobalCardMode=1
        return true 
      end
    end	
  end
  if Duel.GetTurnPlayer()==player_ai and BujinPriorityCheck(AIHand(),LOCATION_FIELD)<2 
  and BujinPriorityCheck(AIGrave(),LOCATION_FIELD)>4 and OverExtendCheck() 
  and not Duel.CheckNormalSummonActivity(player_ai)
  then
    GlobalCardMode=2
    return true
  end
  if Duel.GetCurrentPhase() == PHASE_BATTLE and HasID(AIGrave(),68601507,true) 
  and not HasID(AIHand(),68601507,true) and not HasID(AIHand(),37742478,true)
  then
		local source = Duel.GetAttacker()
		local target = Duel.GetAttackTarget()
    if source and target then
      if source:IsControler(player_ai) then
        target = Duel.GetAttacker()
        source = Duel.GetAttackTarget()
      end
      if target:IsControler(player_ai)
      and (source:GetAttack() >= target:GetAttack() 
      and source:GetAttack() <= target:GetBaseAttack()*2
      and source:IsPosition(POS_FACEUP_ATTACK) 
      or source:GetDefence() >= target:GetAttack()  
      and source:GetDefence() < target:GetBaseAttack()*2
      and source:IsPosition(POS_FACEUP_DEFENCE))
      and target:IsPosition(POS_FACEUP_ATTACK)
      and not source:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) 
      and not target:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) 
      and not target:IsHasEffect(EFFECT_IMMUNE_EFFECT) 
      then
        GlobalCardMode=3
        return true
      end
    end
  end
  return
end
function UseRegaliaBanish()
	local cg = RemovalCheck()
	if cg then
		if cg:IsExists(function(c) return c:IsControler(player_ai) and c:IsCode(30338466) end, 1, nil) then
      return BujinPriorityCheck(AIGrave())<2 and BujinPriorityCheck(AIBanish(),LOCATION_GRAVE)>3
    end	
  end
  return
end
function BujinXYZCheck()
  return BujinCheck() and (not HasID(AIMon(),32339440) or OppHasStrongestMonster())
end
function SummonTigerKingBujin()
  return BujinCheck() and not HasID(UseLists({AIMon(),AIHand()}),32339440) 
  and HasID(AIDeck(),32339440) and HasID(AIDeck(),57103969) and MP2Check()
end
function SummonOmegaBujin()
  local cards=OppST()
  return BujinCheck() and Chance((#cards-1)*25)
end
function BujinOnSelectInit(cards, to_bp_allowed, to_ep_allowed)
  local Activatable = cards.activatable_cards
  local Summonable = cards.summonable_cards
  local SpSummonable = cards.spsummonable_cards
  local Repositionable = cards.repositionable_cards
  local SetableMon = cards.monster_setable_cards
  local SetableST = cards.st_setable_cards
  --
  if HasIDNotNegated(Activatable,46772449) and UseBelzebuth() then
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,30338466,false,485415456) and UseRegaliaGrave() then
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,30338466,false,485415457) and UseRegaliaBanish() then
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,73906480) and UseBujincarnation() then
    GlobalCardMode = 1
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,57103969) then -- Tenki
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,69723159) and UseQuilin() then
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,88940154) and UseCentipede() then
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,81439173) then -- Foolish Burial
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,73289035) and UseTsukuyomi(AIHand()) then
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,98645731) then -- Duality
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasID(Activatable,50474354) then -- Peacock
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,75840616) then -- Susanowo
    GlobalCardMode = 1
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,68618157) then -- Amaterasu
    GlobalCardMode = 1
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,94380860) then  -- Ragna Zero
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,48739166) then  -- SHArk Knight
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  if HasIDNotNegated(Activatable,96381979) and UseTigerKing() then  
    return {COMMAND_ACTIVATE,CurrentIndex}
  end
  --
  BujinAssignPriority(Summonable,LOCATION_FIELD)
  table.sort(Summonable,function(a,b) return a.prio>b.prio end)
  if Summonable and Summonable[1] and (Summonable[1].prio>0 
  or HasID(AIMon(),32339440) and Summonable[1].prio>3)
  and OverExtendCheck() 
  then
    return {COMMAND_SUMMON,Summonable[1].index}
  end
  --
  if HasID(SpSummonable,09418365) and SummonHirume() then
    GlobalActivatedCardID=09418365
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  
  GlobalBujinSS=true
  if HasID(cards,12014404) and SummonCowboyDef() then
    result=IndexByID(cards,12014404)
  end
  if HasID(SpSummonable,75840616) and SummonSusanowo() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,46772449) and SummonBelzebuth() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,46772449)}
  end
  if HasID(SpSummonable,01855932) and SummonKagutsuchi() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,73289035) and SummonTsukuyomi() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,68618157) and SummonAmaterasu() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,96381979) and SummonTigerKingBujin() then
    return {COMMAND_SPECIAL_SUMMON,CurrentIndex}
  end
  if HasID(SpSummonable,94380860) and BujinXYZCheck() and SummonRagnaZero() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,94380860)}
  end  
  if HasID(SpSummonable,61344030) and BujinXYZCheck() and SummonPaladynamo() and Chance(50) then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,61344030)}
  end
  if HasID(SpSummonable,48739166) and BujinXYZCheck() and SummonSharkKnight() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,48739166)}
  end
  if HasID(SpSummonable,26329679) and BujinXYZCheck() and SummonOmegaBujin() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,26329679)}
  end
  if HasID(SpSummonable,48739166) and BujinXYZCheck() and SummonCowboyAtt() then
    return {COMMAND_SPECIAL_SUMMON,IndexByID(SpSummonable,48739166)}
  end
  GlobalBujinSS=nil
  return nil
end
function YamatoTarget(cards)
  if GlobalCardMode==1 then
    GlobalCardMode = nil
    if BujinPriorityCheck(AIHand(),LOCATION_GRAVE)>4 then
      return BujinAdd(cards)
    end
  end
  return BujinAdd(cards,LOCATION_GRAVE)
end
function TsukuyomiTarget(cards)
  return BujinAdd(cards,LOCATION_GRAVE)
end
function KagutsuchiTarget(cards)
  return BujinAdd(cards,LOCATION_GRAVE)
end
function SusanowoTarget(cards)
  local result = nil
  if GlobalCardMode == 1 then
    GlobalCardMode = nil
    return BujinAdd(cards,LOCATION_GRAVE)
  else
    if not (HasID(AIHand(),68601507) or HasID(AIHand(),37742478)) 
    and OppHasStrongestMonster() 
    then
      result = {IndexByID(cards,68601507)}
    end
    if result == nil or #result==0 then
      result=BujinAdd(cards)
    end
    return result
  end
end
function AmaterasuTarget(cards)
  if GlobalCardMode == 1 then
    GlobalCardMode = nil
    return BujinAdd(cards,LOCATION_GRAVE)
  else
    if Duel.GetTurnPlayer()==player_ai then
      return BujinAdd(cards,LOCATION_GRAVE)
    else
      return BujinAdd(cards)
    end
  end
end
function HareTarget(cards)
  return {IndexByID(cards,GlobalTargetID)}
end
function QuilinTarget(cards)
  return BestTargets(cards)
end
function CentipedeTarget(cards)
  return BestTargets(cards)
end
function HirumeTarget(cards)
  if GlobalCardMode==1 then
    GlobalCardMode=nil
    return BujinAdd(cards,LOCATION_GRAVE)
  end
  return BujinAdd(cards,LOCATION_REMOVED)
end
function BujincarnationTarget(cards)
  local result=BujinAdd(cards,LOCATION_FIELD)
  if GlobalCardMode==1 then
    GlobalCardMode=nil
  else
    if BujinPriorityCheck(cards,LOCATION_GRAVE)>3 then
      result=BujinAdd(cards,LOCATION_GRAVE)
    end
  end
  return result
end
function RegaliaTarget(cards)
  local result=nil
  if GlobalCardMode==1 then
    result=BujinAdd(cards)
  elseif GlobalCardMode==2 then
    result=BujinAdd(cards,LOCATION_FIELD)
  elseif GlobalCardMode==3 then
    result={IndexByID(cards,68601507)}
  else
    result=BujinAdd(cards,LOCATION_GRAVE)
  end
  if result == nil or #result == 0 then
    result = BujinAdd(cards)
  end
  GlobalCardMode=nil
  return result
end
function ArasudaTarget(cards)
  return BujinAdd(cards,LOCATION_GRAVE)
end
function BujinXYZTarget(cards,count)
  GlobalBujinSS=nil
  result={}
  BujinAssignPriority(cards,LOCATION_FIELD)
  table.sort(cards,function(a,b) return a.prio<b.prio end)
  for i=1,count do
    result[i]=cards[i].index
  end
  return result
end
function BujinOnSelectCard(cards, minTargets, maxTargets, ID)
  if ID == 98645731 or ID == 50474354  -- Duality, Peacock
  or ID == 53678698 then -- Mikazuchi
    return BujinAdd(cards)
  end
  if ID == 30338466 then
    return RegaliaTarget(cards)
  end
  if ID == 32339440 then
    return YamatoTarget(cards)
  end
  if ID == 23979249 then
    return ArasudaTarget(cards)
  end
  if GlobalActivatedCardID == 09418365 then
    GlobalActivatedCardID=nil
    return HirumeTarget(cards)
  end
  if ID == 09418365 then
    GlobalCardMode=1
    return HirumeTarget(cards)
  end
  if ID == 73289035 then
    return TsukuyomiTarget(cards)
  end
  if ID == 01855932 then
    return KagutsuchiTarget(cards)
  end
  if ID == 75840616 then
    return SusanowoTarget(cards)
  end
  if ID == 68618157 then
    return AmaterasuTarget(cards)
  end
  if ID == 59251766 then
    return HareTarget(cards)
  end
  if ID == 69723159 then
    return QuilinTarget(cards)
  end
  if ID == 88940154 then
    return CentipedeTarget(cards)
  end
  if ID == 73906480 then
    return BujincarnationTarget(cards)
  end
  if GlobalBujinSS then
    return BujinXYZTarget(cards,minTargets)
  end
  return nil
end
function ChainArasuda()
  if HasID(AIHand(),23979249) then
    return Duel.GetTurnPlayer()==player_ai and OverExtendCheck()
  else
    return BujinPriorityCheck(AIHand(),LOCATION_GRAVE)>4
  end
end
function HareFilter(card)
  return card:IsControler(player_ai) and card:IsPosition(POS_FACEUP) 
  and card:IsSetCard(0x88) and card:IsRace(RACE_BEASTWARRIOR)
  and not card:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT) 
  and not card:IsHasEffect(EFFECT_IMMUNE_EFFECT) 
  and not card:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET) 
end
function ChainHare()
  local ex,cg = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
  local tg = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TARGET_CARDS)
  local e = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
  if e and e:GetHandler():GetCode()==30338466 and e:GetHandlerPlayer()==player_ai then
    return false
  end
  if ex then
    if tg then
      local g = tg:Filter(HareFilter, nil):GetMaxGroup(Card.GetAttack)
      if g then
        GlobalTargetID = g:GetFirst():GetCode() 
      end
      return tg:IsExists(HareFilter, 1, nil)
    else
      local g = cg:Filter(HareFilter, nil):GetMaxGroup(Card.GetAttack)
      if g then
        GlobalTargetID = g:GetFirst():GetCode()
      end
      return cg:IsExists(HareFilter, 1, nil)
    end
  end
  if Duel.GetCurrentPhase() == PHASE_BATTLE then
		local source = Duel.GetAttacker()
		local target = Duel.GetAttackTarget()
    if source and target then
      if source:IsControler(player_ai) then
        target = Duel.GetAttacker()
        source = Duel.GetAttackTarget()
      end
      if source:GetAttack() >= target:GetAttack() 
      and target:IsControler(player_ai) 
      and source:IsPosition(POS_FACEUP_ATTACK)
      and (not (HasID(AIHand(),68601507,true) or HasID(AIHand(),37742478,true))
      or source:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE))
      and not target:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
      --and not target:IsHasEffect(EFFECT_IMMUNE_EFFECT) 
      then
        GlobalTargetID=target:GetCode()
        return true
      end
    end
  end
  return false
end
function ChainCrane()
  local e
  for i=1,Duel.GetCurrentChain() do
    e = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT)
    if e and e:GetHandler():GetCode()==68601507 and e:GetHandlerPlayer()==player_ai  then
      return false
    end
  end
  if Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL then
		local source = Duel.GetAttacker()
		local target = Duel.GetAttackTarget()
    if source and target then
      if source:IsControler(player_ai) then
        target = Duel.GetAttacker()
        source = Duel.GetAttackTarget()
      end
      if target:IsControler(player_ai)
      and (source:GetAttack() >= target:GetAttack() 
      and source:GetAttack() <= target:GetBaseAttack()*2
      and source:IsPosition(POS_FACEUP_ATTACK) 
      or source:GetDefence() >= target:GetAttack()  
      and source:GetDefence() < target:GetBaseAttack()*2
      and source:IsPosition(POS_FACEUP_DEFENCE))
      and target:IsPosition(POS_FACEUP_ATTACK)
      and not source:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) 
      and not target:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) 
      --and not target:IsHasEffect(EFFECT_IMMUNE_EFFECT) 
      then
        return true
      end
    end
  end
  return false
end
function ChainHonest()
  local e
  for i=1,Duel.GetCurrentChain() do
    e = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT)
    if e and e:GetHandler():GetCode()==68601507 and e:GetHandlerPlayer()==player_ai  then
      return false
    end
  end
  if Duel.GetCurrentPhase() == PHASE_DAMAGE_CAL then
		local source = Duel.GetAttacker()
		local target = Duel.GetAttackTarget()
    if source and target then
      if source:IsControler(player_ai) then
        target = Duel.GetAttacker()
        source = Duel.GetAttackTarget()
      end
      if target:IsControler(player_ai)
      and (source:GetAttack() >= target:GetAttack() 
      and source:IsPosition(POS_FACEUP_ATTACK) 
      or source:GetDefence() >= target:GetAttack() 
      and source:GetDefence() < target:GetAttack()+source:GetAttack()
      and source:IsPosition(POS_FACEUP_DEFENCE))
      and target:IsPosition(POS_FACEUP_ATTACK)
      and not source:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) 
      and not target:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) 
      --and not target:IsHasEffect(EFFECT_IMMUNE_EFFECT) 
      then
        return true
      end
    end
  end
  return false
end
function ChainTurtle()
  local player = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_PLAYER)
  return player and player ~= player_ai
end
function ChainHirume()
  return BujinPriorityCheck(AIHand(),LOCATION_GRAVE)>4
end
function OmegaFilter(card)
	return card:IsControler(player_ai) and card:IsType(TYPE_MONSTER) 
  and card:IsLocation(LOCATION_MZONE) and card:IsPosition(POS_FACEUP)
  and not card:IsHasEffect(EFFECT_IMMUNE_EFFECT) and card:IsSetCard(0x53)
end
function ChainOmega()
  local cc=Duel.GetCurrentChain()
  local cardtype = Duel.GetChainInfo(cc, CHAININFO_EXTTYPE)
  local ex,cg = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
  local tg = Duel.GetChainInfo(cc, CHAININFO_TARGET_CARDS)
  local e = Duel.GetChainInfo(cc, CHAININFO_TRIGGERING_EFFECT)
  local p = Duel.GetChainInfo(cc, CHAININFO_TRIGGERING_PLAYER)
  if ex then
    local g = cg:Filter(OmegaFilter, nil):GetMaxGroup(Card.GetAttack)
    return bit32.band(cardtype, TYPE_SPELL+TYPE_TRAP) ~= 0 and g
  elseif tg then
    local g = tg:Filter(OmegaFilter, nil):GetMaxGroup(Card.GetAttack)
    return bit32.band(cardtype, TYPE_SPELL+TYPE_TRAP) ~= 0 and g and p~=player_ai
  end
  return false
end
function BujinOnSelectChain(cards,only_chains_by_player)
  if HasID(cards,30338466--[[,false,485415456]]) and UseRegaliaGrave() then
    if CardsMatchingFilter(AIBanish(),AmaterasuFilter)>0 then
      CurrentIndex = CurrentIndex-1
    end
    return {1,CurrentIndex}
  end
  --[[if HasID(cards,30338466,false,485415457) and UseRegaliaBanish() then
    return {1,CurrentIndex}
  end]]--
  if HasID(cards,68601507) and ChainCrane() then
    return {1,CurrentIndex}
  end
  if HasID(cards,37742478) and ChainHonest() then
    return {1,CurrentIndex}
  end
  if HasID(cards,59251766) and ChainHare() then
    return {1,CurrentIndex}
  end
  if HasID(cards,05818294) and ChainTurtle() then
    return {1,CurrentIndex}
  end
  if HasIDNotNegated(cards,68618157) then -- Amaterasu
    GlobalCardMode = 1
    return {1,CurrentIndex}
  end
  if HasIDNotNegated(cards,23979249) and ChainArasuda() then
    return {1,CurrentIndex}
  end
  if HasIDNotNegated(cards,53678698) then -- Mikazuchi
    return {1,CurrentIndex}
  end
  if HasIDNotNegated(cards,32339440) then -- Yamato
    GlobalCardMode = 1
    return {1,CurrentIndex}
  end
  if HasIDNotNegated(cards,26329679) and ChainOmega() then
    return {1,CurrentIndex}
  end
  return nil
end
function BujinOnSelectEffectYesNo(id)
  local result = nil
  if id == 09418365 then --Hirume
    if ChainHirume() then
      result = 1
    else
      result = 0
    end
  end
  if id == 53678698 then -- Mikazuchi
    result = 1
  end
  if id == 32339440 then -- Yamato
    GlobalCardMode = 1
    result = 1
  end
  return result
end
BujinAtt={
  32339440,53678698,09418365, -- Yamato, Mika, Hirume
  75840616,01855932,68618157 -- Susan, Kagu, Amaterasu
}
BujinDef={
  23979249,73289035 -- Arasuda, Tsukuyomi
}
function BujinOnSelectPosition(id, available)
  result = nil
  for i=1,#BujinAtt do
    if BujinAtt[i]==id then result=POS_FACEUP_ATTACK end
  end
  for i=1,#BujinDef do
    if BujinDef[i]==id then result=POS_FACEUP_DEFENCE end
  end
  return result
end