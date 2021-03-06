--- OnSelectPosition ---
--
-- Called when AI has to select the monster position.
-- 
-- Parameters (2):
-- id = card id
-- available = available positions
--
-- Return: the position
--[[
From constants.lua
POS_FACEUP_ATTACK		=0x1
POS_FACEDOWN_ATTACK		=0x2
POS_FACEUP_DEFENCE		=0x4
POS_FACEDOWN_DEFENCE	=0x8
--]]
function OnSelectPosition(id, available)
	local result = 0
	local band = bit32.band --assign bit32.band() to a local variable
  result = POS_FACEUP_ATTACK 
  
  -------------------------------------------------------
  -- If a dragon is summoned by the effect of a Hieratic 
  -- monster, always summon it in defense mode, as his 
  -- attack and defense will be 0
  -------------------------------------------------------
  if GlobalActivatedCardID == 27337596 -- Hieratic Dragon King of Atum
  then
    result = POS_FACEUP_DEFENCE
    GlobalActivatedCardID = nil
    GlobalTributedCardID = nil
  end
  
  ------------------------------------------------------
  -- Check if AI's monster's attack is lower than of strongest player's monster,
  -- or if any actions can be taken to gain advantage over player.
  -- Then summon or set monster in available position depending on results.
  ------------------------------------------------------
 if band(POS_FACEDOWN_DEFENCE,available) > 0 and Get_Card_Count_Pos(OppMon(), POS_FACEUP) > 0 then
  if AIMonGetAttackById(id) < Get_Card_Att_Def(OppMon(),"attack",">",POS_FACEUP_ATTACK,"attack") and CanChangeOutcomeSS(id) == 0 and AIMonGetAttackById(id) < 2400 then -- Also check if any action can be taken by CanChangeOutcomeSS
    result = POS_FACEDOWN_DEFENCE
    end 
  end
 if band(POS_FACEUP_DEFENCE,available) > 0 and Get_Card_Count_Pos(OppMon(), POS_FACEUP) > 0 then 
  if AIMonGetAttackById(id) < Get_Card_Att_Def(OppMon(),"attack",">",POS_FACEUP_ATTACK,"attack") and CanChangeOutcomeSS(id) == 0 and AIMonGetAttackById(id) < 2400 then -- Also check if any action can be taken by CanChangeOutcomeSS
   result = POS_FACEUP_DEFENCE
   end 
 end
  
  -------------------------------------------------------
  -- If Treeborn Frog is being special summoned, check if
  -- Creature Swap is in hand, the opponent controls 1
  -- monster, and the AI controls no other monsters.
  --
  -- If so, let the AI be a troll and special summon the
  -- frog in attack position!
  -------------------------------------------------------
  if id == 12538374 then
    if Get_Card_Count_ID(AIHand(),31036355,nil) == 0 or
       Get_Card_Count(OppMon()) ~= 1 or
       Get_Card_Count(AIMon()) ~= 0 then
      result = POS_FACEUP_DEFENCE
    end
  end

  ------------------------------------
  -- Cards to be always summoned in
  -- defence position.
  -- Expanding upon the above example.
  -- More cards to be added later.
  ------------------------------------
  if id == 19665973 or id == 52624755 or   -- Battle Fader, Peten the Dark Clown,
     id == 10002346 or id == 90411554 or   -- Gachi Gachi, Redox
     id == 33420078 or id == 15394084 or   -- Plaguespreader, Nordic Beast Token
     id == 58058134 or id == 10389142 or   -- Slacker Magician, Tomahawk
     id == 46384403 or id == 14677495 then -- Nimble Manta, Tanngnjostr
    
	result = POS_FACEUP_DEFENCE
  end
  
  ------------------------------------
  -- Cards to be always summoned in
  -- attack position.
  -- Expanding upon the above example.
  -- More cards to be added later.
  ------------------------------------
  if id == 64631466 or id == 70908596 or   -- Relinquished, Constellar Kaust
	 id == 23232295 or id == 88241506 then -- Battlin' Boxer Lead Yoke, Maiden with Eyes of Blue
	result = POS_FACEUP_ATTACK
  end

  local Position = FireFistOnSelectPosition(id,available)
  if Position then result=Position end
  Position = HeraldicOnSelectPosition(id,available)
  if Position then result=Position end
  Position = GadgetOnSelectPosition(id,available)
  if Position then result=Position end
  Position = BujinOnSelectPosition(id,available)
  if Position then result=Position end
  Position = MermailOnSelectPosition(id,available)
  if Position then result=Position end
  Position = ShadollOnSelectPosition(id,available)
  if Position then result=Position end
  Position = SatellarknightOnSelectPosition(id,available)
  if Position then result=Position end
  Position = ChaosDragonOnSelectPosition(id,available)
  if Position then result=Position end
  Position = HATPosition(id,available)
  if Position then result=Position end
  Position = QliphortPosition(id,available)
  if Position then result=Position end
  Position = NoblePosition(id,available)
  if Position then result=Position end
  Position = NeclothPosition(id,available)
  if Position then result=Position end
  
  if band(result,available) == 0 then
    if band(POS_FACEUP_ATTACK,available) > 0 then
      result = POS_FACEUP_ATTACK
    elseif band(POS_FACEUP_DEFENCE,available) > 0 then
      result = POS_FACEUP_DEFENCE
    elseif band(POS_FACEDOWN_DEFENCE,available) > 0 then
      result = POS_FACEDOWN_DEFENCE
    else
      result = POS_FACEDOWN_ATTACK
    end
  end
  return result
end
