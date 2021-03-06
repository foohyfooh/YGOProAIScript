--- OnDeclareCard ---
--
-- Called when AI has to declare a card. 
-- Example card(s): Prohibition, Mind Crush
-- 
-- Parameters:
-- none
--
-- Return: id of the selected card
function OnDeclareCard()
 local result = 85138716	
 
--------------------------------------------------
-- Select random card in player's hand when using 
-- "Mind Crush".
--------------------------------------------------	
 if GlobalActivatedCardID == 15800838 then 
  local OppHand = AI.GetOppHand() 
   for i=1,#OppHand do
    if OppHand[i] ~= false then
       GlobalActivatedCardID = nil
	   Result = OppHand[math.random(#OppHand)].id		
	   AI.Chat("Let's see what card should I chose...")
		return Result
		end
	  end
    end

-----------------------------------------------------------------------
-- Returns id of the card if it exist in any location of the field
-- ** This will be used as a default implementation for now **
-----------------------------------------------------------------------			
 local AllCards = UseLists({OppGrave(),OppDeck(),OppHand(),OppExtra(),OppMon(),OppBanish(),AIMon(),AIDeck(),AIHand(),AIGrave(),AIExtra(),AIBanish()})
   for i=1,#AllCards do
	if AllCards[i] ~= false then
      Result = AllCards[i].id
      return Result
	 end
  end
		
	-- Example implementation: Return the card id of rescue rabbit
	return result 
end
