--- OnSelectOption() ---
--
-- Called when AI has to choose an option
-- Example card(s): Elemental HERO Stratos
-- 
-- Parameters:
-- options = table of available options, this is one of the strings from the card database (str1, str2, str3, ..)
--
-- Return: index of the selected option
function OnSelectOption(options)
local result = 0
  result = HeraldicOnSelectOption(options)
  if result ~= nil then
    return result
  end
  result = QliphortOption(options)
  if result ~= nil then
    return result
  end
  result = NeclothOption(options)
  if result ~= nil then
    return result
  end
	result = 0
   ------------------------------------------------------    
   -- Return random result if it isn't specified below.
   ------------------------------------------------------   
	if GlobalActivatedCardID ~= 98045062 and GlobalActivatedCardID ~= 34086406 and  -- Enemy Controller, Lavalval Chain
       GlobalActivatedCardID ~= 12014404 and GlobalActivatedCardID ~= 70908596 then -- Gagaga Gunman, Constellar Kaust
       result = math.random(#options) 
	   return result
	end
	
	if GlobalActivatedCardID == 98045062 then -- Enemy Controller
	for i=1,#options do
      if options[i] == 1568720992 then
      result = i
       end
      end
    end  
    
	if GlobalActivatedCardID == 34086406 then -- Lavalval Chain
	for i=1,#options do
      if options[i] == 1 then
      result = i
       end
      end
    end  
	
	if GlobalActivatedCardID == 12014404 then -- Gagaga Gunman
	for i=1,#options do
      if options[i] == 1 then
      result = i
       end
      end
    end  
	
	if GlobalActivatedCardID == 70908596 then -- Constellar Kaust
	for i=1,#options do
      if options[i] == 1134537537 then
      result = i
      GlobalActivatedCardID = nil
	    return result
	    end
      end
    end  	
  end
