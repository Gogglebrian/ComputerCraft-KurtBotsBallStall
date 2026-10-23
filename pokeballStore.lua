local buttonAPI = require("button")
local utils = require("utils")

--balls data filename
ballsDataFile = "pokeballs.txt"
salesDataFile = "sales.txt"

--Peripheral Names! Update these as necessary if peripherals are changed/moved
monitor = peripheral.wrap("monitor_2")
inBarrel = peripheral.wrap("minecraft:barrel_2")
outChest = peripheral.wrap("front")
workChest = peripheral.wrap("minecraft:chest_67") --must be directly above the turtle but also wired to modem
speaker = peripheral.wrap("left")
workbench = peripheral.wrap("right")

--Apricorn chest names
aChest = {}
aChest["red"] = peripheral.wrap("minecraft:chest_108")
aChest["blue"] = peripheral.wrap("minecraft:chest_109")
aChest["green"] = peripheral.wrap("minecraft:chest_107")
aChest["yellow"] = peripheral.wrap("minecraft:chest_106")
aChest["pink"] = peripheral.wrap("minecraft:chest_105")
aChest["white"] = peripheral.wrap("minecraft:chest_104")
aChest["black"] = peripheral.wrap("minecraft:chest_103")

--Other chest names
paymentChest = peripheral.wrap("minecraft:chest_68")

----other settings
--show or hide sales section
enableSales = true
--don't care about apricorn counts higher than this
apricornShortcutCount = 64
--max craftingsAtATime
maxCraftingsLimit = 16

----runtime vars
--apricorn counts
aCount = {}
aCount["red"] = 0
aCount["blue"] = 0
aCount["green"] = 0
aCount["yellow"] = 0
aCount["pink"] = 0
aCount["white"] = 0
aCount["black"] = 0
acceptingClicks = true
maxX, maxY = monitor.getSize()

balls = {}
function loadBallData()
	balls = {}
	--look through lines in balls data file
	for line in io.lines(ballsDataFile) do
		--exclude empty lines and commented lines
		if not utils.isEmptyLine(line) and string.sub(line,1,1) ~= "#" then
			--Split the line by commas
			lineValues = utils.splitString(line, ",")
			
			--Unload data to table
			newBall = {}
			newBall.name = lineValues[1]
			newBall.description = lineValues[2]
			newBall.leadingSpaces = lineValues[3]
			newBall.newLine = (lineValues[4] == "true")
			newBall.buttonTextColor = tonumber(lineValues[5])
			newBall.buttonBackColor = tonumber(lineValues[6])
			newBall.recipeCenter = lineValues[7]
			newBall.recipeApricornTop = lineValues[8]
			newBall.recipeApricornLeft = lineValues[9]
			newBall.recipeApricornBottom = lineValues[10]
			newBall.recipeApricornRight = lineValues[11]
			
			--Format recipe data
			newBall.recipeCenter = "minecraft:"..newBall.recipeCenter
			if (newBall.recipeApricornLeft == nil) then
				newBall.recipeApricornLeft = newBall.recipeApricornTop
			end
			if (newBall.recipeApricornBottom == nil) then
				newBall.recipeApricornBottom = newBall.recipeApricornTop
			end
			if (newBall.recipeApricornRight == nil) then
				newBall.recipeApricornRight = newBall.recipeApricornLeft
			end
			--insert this table into balls array
			table.insert(balls,newBall)
		end
	end
end

saleItems = {}
function loadSalesData()
	saleItems = {}
	for line in io.lines(salesDataFile) do
		--exclude empty lines and commented lines
		if not utils.isEmptyLine(line) and string.sub(line,1,1) ~= "#" then
			--Split the line by commas
			lineValues = utils.splitString(line, ",")
			
			--Unload data to table
			newItem = {}
			newItem.name = lineValues[1]
			newItem.goodName = lineValues[2]
			newItem.description = lineValues[3]
			newItem.description2 = lineValues[4]
			newItem.leadingSpaces = lineValues[5]
			newItem.newLine = (lineValues[6] == "true")
			newItem.saleQuantity = tonumber(lineValues[7])
			newItem.costItem = lineValues[8]
			newItem.costItemGoodName = lineValues[9]
			newItem.costQuantity = tonumber(lineValues[10])
			newItem.buttonTextColor = tonumber(lineValues[11])
			newItem.buttonBackColor = tonumber(lineValues[12])
			newItem.chest = peripheral.wrap(lineValues[13])
			
			--insert this table into balls array
			table.insert(saleItems,newItem)
		end
	end
end

function doBallButton(i)
	--printOnNextLine(balls[i].name)
	
	--play sound
	speaker.playNote("bit",1.2,14)
	
	return doBallScreen(i)
end

function doItemSaleButton(i)
	speaker.playNote("bit",1.2,14)
	return doItemSaleScreen(i)
end

function resetColors()
	monitor.setTextColor(colors.white)
	monitor.setBackgroundColor(colors.black)
end

function printCentered(text,y,xoffset,textColor,backColor)
	monitor.setCursorPos(getPosForCentered(text,xoffset),y)
	if (textColor ~= nil) then
		monitor.setTextColor(textColor)
	end
	if (backColor ~= nil) then
		monitor.setBackgroundColor(backColor)
	end
	print(text)
end

function getPosForCentered(text,xoffset)
	return maxX/2 - #text/2 + (xoffset or 0) 
end

function clearLine(y)
	posX, posY = monitor.getCursorPos()
	monitor.setCursorPos(1,y)
	monitor.clearLine()
	monitor.setCursorPos(posX,posY)
end

function printOnNextLine(text)
	insertNewLine()
	print(text)
end

function insertNewLine()
	x, y = monitor.getCursorPos()
	if (x ~= 1) then
		monitor.setCursorPos(1,y+1)
	end
end

--given the minecraft item name, gives a properly formatted name
function getIngredientGoodName(ingredient)
	if (ingredient == "minecraft:copper_ingot") then
		return "Copper Ingot"
	elseif (ingredient == "minecraft:iron_ingot") then
		return "Iron Ingot"
	elseif (ingredient == "minecraft:gold_ingot") then
		return "Gold Ingot"
	elseif (ingredient == "minecraft:diamond") then
		return "Diamond"
	else
		return "Unknown"
	end
end

function getColorFromApricornName(apricornName)
	firstSplitArray = utils.splitString(apricornName, ":")
	secondSplitArray = utils.splitString(firstSplitArray[2],"_")
	return secondSplitArray[1]
end

function doMainMenu()
	--Reset term
	monitor.clear()
	resetColors()

	--Write headings
	printCentered("Welcome to KurtBot's",2,1)
	printCentered("Deluxe Ball Stall!",3, 1)
	printCentered("Select your desired ball:",5, 1)

	--Draw buttons
	monitor.setCursorPos(1,7)
	ballButtons = {}
	for i, v in ipairs(balls) do
		if (v.newLine == true) then
			local _, curY = monitor.getCursorPos()
			monitor.setCursorPos(1,curY+2)
		end
		ballButtons[v.name] = Button:newInPlace(monitor, 1+v.leadingSpaces,0 ," "..v.name.." ", function() return doBallButton(i) end,v.buttonTextColor,v.buttonBackColor, 1+v.leadingSpaces, 1)
	end
	resetColors()
	
	--another heading for extra items
	if (enableSales == true) then
		printCentered("Other items for sale:",12, 1)
		monitor.setCursorPos(1,14)
		for i, v in ipairs(saleItems) do
			if (v.newLine == true) then
				local _, curY = monitor.getCursorPos()
				monitor.setCursorPos(1,curY+2)
			end
			ballButtons[v.name] = Button:newInPlace(monitor, 1+v.leadingSpaces,0 ," "..v.goodName.." ", function() return doItemSaleButton(i) end,v.buttonTextColor,v.buttonBackColor, 1+v.leadingSpaces, 1)
		end
		resetColors()
	end
	
	acceptingClicks = true
	while true do
		--wait for touch
		local event, monitorId, x, y = os.pullEvent("monitor_touch")
		
		--Check if touch is a valid click
		--print(monitorId .. " was touched at (" .. x .. ", " .. y .. ")")
		for _,v in pairs(ballButtons) do
			if (acceptingClicks) then
				result = v:processClick(x,y)
				if (result == "back") then
					return
				end
			end
		end
	end
end

function doBackButton()
	speaker.playNote("bit",1.2,12)
	
	return "back"
end

function drawSaleQuantityButton(i, numSales, maxPossible)
	if (numSales <= maxPossible) then
		return Button:newInPlace(monitor, 1,0 ," "..numSales*saleItems[i].saleQuantity .." ", function() speaker.playNote("bit",1.2,16); return doSaleNumberSelect(i, numSales) end,1,8192, 1, 1)
	else
		return Button:newInPlace(monitor, 1,0 ," "..numSales*saleItems[i].saleQuantity .." ", function() ; end,1,128, 1, 1)
	end
end

function drawBallQuantityButton(b, numCraftings, maxPossible)
	if (numCraftings <= maxPossible) then
		return Button:newInPlace(monitor, 1,0 ," "..numCraftings*4 .." ", function() speaker.playNote("bit",1.2,16); return doBallNumberSelect(b,numCraftings) end,1,8192, 1, 1)
	else
		return Button:newInPlace(monitor, 1,0 ," "..numCraftings*4 .." ", function() ; end,1,128, 1, 1)
	end
end

function doBallScreen(b)	
	--do preliminary counting
	countApricorns()
	
	--Reset term
	monitor.clear()
	resetColors()
	
	--Draw back button
	buttons = {}
	buttons["back"] = Button:new(monitor, 2, 2 ," ".." Back ".." ", function() return doBackButton() end,1,16384, 1, 1)
	resetColors()
		
	--Write headings
	ball = balls[b]
	printCentered(" "..ball.name.." Ball ",4,1, ball.buttonTextColor, ball.buttonBackColor)
	resetColors()
	printCentered(ball.description,6,1)
	printCentered("Cost:",8,1)
	printCentered("1 " .. getIngredientGoodName(ball.recipeCenter) .. " for 4 balls",9)
	resetColors()

	--Calculate which buttons to show
	maxPossible = getMaxPossibleCraftings(b)

	--Draw buttons
	monitor.setCursorPos(21,12)
	if (maxPossible >= 1) then
		buttons["4"]  = drawBallQuantityButton(b,1,maxPossible)
		buttons["8"]  = drawBallQuantityButton(b,2,maxPossible)
		buttons["16"] = drawBallQuantityButton(b,4,maxPossible)
		buttons["32"] = drawBallQuantityButton(b,8,maxPossible)
		buttons["64"] = drawBallQuantityButton(b,16,maxPossible)
		buttons["Max"] = Button:newInPlace(monitor, 1,0 ," Max ", function() speaker.playNote("bit",1.2,16); return doBallMaxSelect(b,maxPossible) end,1,8192, 1, 1)
	else
		printCentered("Currently unavailable. Sorry! :C",10)
	end
	resetColors()
	
	--
	while true do
		--wait for touch
		local event, monitorId, x, y = os.pullEvent("monitor_touch")
		
		--Check if touch is a valid click
		--print(monitorId .. " was touched at (" .. x .. ", " .. y .. ")")
		for k,v in pairs(buttons) do
			if acceptingClicks then
				result = v:processClick(x,y)
				if (result == "back") then
					return "back"
				end
			end
		end
	end
end

function doItemSaleScreen(i)
	item = saleItems[i]

	--do preliminary counting
	itemCount = getCountInInventory(item.chest,item.name)
	
	--Reset term
	monitor.clear()
	resetColors()
	
	--Draw back button
	buttons = {}
	buttons["back"] = Button:new(monitor, 2, 2 ," ".." Back ".." ", function() return doBackButton() end,1,16384, 1, 1)
	resetColors()
		
	--Write headings
	printCentered(" "..item.goodName.." ",4,1, item.buttonTextColor, item.buttonBackColor)
	resetColors()
	if (item.description2 == "_") then
		printCentered(item.description,6,1)
	else
		printCentered(item.description..",",6,1)
		printCentered(item.description2,7,1)
	end
	printCentered("Cost:",8,1)
	printCentered( item.costQuantity.." ".. item.costItemGoodName .."(s) for ".. item.saleQuantity .." ".. item.goodName .. "(s)",9)
	resetColors()

	--Calculate which buttons to show
	maxPossible = itemCount / item.saleQuantity

	--Draw buttons
	monitor.setCursorPos(27,12)
	if (maxPossible >= 1) then
		sq = 1
		q = item.saleQuantity
		while (q <= 64) do
			buttons[tostring(q)] = drawSaleQuantityButton(i,sq,maxPossible)
			sq = sq * 2
			q = sq * item.saleQuantity
		end
	else
		printCentered("Currently unavailable. Sorry! :C",10)
	end
	resetColors()
	
	--
	while true do
		--wait for touch
		local event, monitorId, x, y = os.pullEvent("monitor_touch")
		
		--Check if touch is a valid click
		--print(monitorId .. " was touched at (" .. x .. ", " .. y .. ")")
		for k,v in pairs(buttons) do
			if acceptingClicks then
				result = v:processClick(x,y)
				if (result == "back") then
					return "back"
				end
			end
		end
	end
end

function doSaleNumberSelect(i, sales)
	acceptingClicks = false
	if (isPaymentProvided(saleItems[i].costItem,sales*saleItems[i].costQuantity)) then
		clearLine(maxY-3)
		clearLine(maxY-2)
		printCentered("Dispensing "..sales*saleItems[i].saleQuantity .. " "..saleItems[i].goodName.."(s)",maxY-3)
		return dispenseSaleItem(i,sales)
	else
		clearLine(maxY-3)
		clearLine(maxY-2)
		printCentered("Insert "..sales*saleItems[i].costQuantity .." "..saleItems[i].costItemGoodName.."(s) below",maxY-3)
		printCentered("then select again to confirm.",maxY-2)
		acceptingClicks = true
	end
end

function dispenseSaleItem(i, numSales)
	
	if transferQuantity(saleItems[i].chest,workChest,numSales*saleItems[i].saleQuantity,saleItems[i].name) then
		
		--if gold failed to transfer
		if not transferQuantity(inBarrel,paymentChest,numSales*saleItems[i].costQuantity,saleItems[i].costItem) then
			--dump items and quit
			transferQuantity(workChest,paymentChest,numSales*saleItems[i].saleQuantity,saleItems[i].name)
			return "back"
		end
		
		--fake work time 'cause it's satisfying ;)
		os.sleep(1)
		--grab from workchest and transfer to front chest
		turtle.suckUp(64)
		turtle.drop()
		speaker.playNote("bit",1.2,14)
		speaker.playNote("bit",1.2,16)
		speaker.playNote("bit",1.2,26)
		return "back"
	else
		return "back"
	end
end

function doBallNumberSelect(b,craftings)
	acceptingClicks = false
	if (isInputProvided(b,craftings)) then
		clearLine(maxY-3)
		clearLine(maxY-2)
		printCentered("Crafting "..craftings*4 .. " "..balls[b].name .." Balls",maxY-3)
		return craftBalls(b,craftings)
	else
		clearLine(maxY-3)
		clearLine(maxY-2)
		printCentered("Insert "..craftings .." "..getIngredientGoodName(balls[b].recipeCenter).."(s) below",maxY-3)
		printCentered("then select again to confirm.",maxY-2)
		acceptingClicks = true
	end
end

function doBallMaxSelect(b,maxPossible)
	acceptingClicks = false
	maxPossibleFromInput = getMaxPossibleCraftingsByInput(b,maxPossible)
	if (isInputProvided(b,1)) then
		clearLine(maxY-3)
		clearLine(maxY-2)
		printCentered("Crafting "..maxPossibleFromInput * 4 .. " "..balls[b].name .." Balls",maxY-3)
		return craftBalls(b,maxPossibleFromInput)
	else
		clearLine(maxY-3)
		clearLine(maxY-2)
		printCentered("Insert up to "..maxPossible.." "..getIngredientGoodName(balls[b].recipeCenter).."(s) below,",maxY-3)
		printCentered("then select again to confirm.",maxY-2)
		acceptingClicks = true
	end
end

--returns true if the input chest contains enough stuff to start crafting
function isInputProvided(b,targetQuantity)
	return doesInventoryContain(inBarrel, balls[b].recipeCenter, targetQuantity)
end

function isPaymentProvided(item,targetQuantity)
	return doesInventoryContain(inBarrel, item, targetQuantity)
end

function doesInventoryContain(inventory, targetItem, targetQuantity)
	total = 0
	for k, item in pairs(inventory.list()) do
		if (item.name == targetItem) then
			if (item.count >= targetQuantity) then
				return true
			else
				total = total + item.count
			end
		end
	end
	
	if (total >= targetQuantity) then
		return true
	else
		return false
	end
end

function getCountInInventory(inventory, targetItem)
	total = 0
	for k, item in pairs(inventory.list()) do
		if (item.name == targetItem) then
			total = total + item.count
		end
	end
	--print(targetItem.." "..total)
	return total
end

function countApricorns()
	for k, v in pairs(aCount) do
		aCount[k] = getCountInInventory(aChest[k],"cobblemon:"..k.."_apricorn")
	end
end

--given a particular ball, returns a table of the number of apricorns of each color required per 1 crafting recipe (4 balls)
function getRequiredApricorns(b, craftings)
	craftings = (craftings or 1)
	
	rA = {}
	for k, _ in pairs(aChest) do
		rA[k] = 0
	end
	
	rA[balls[b].recipeApricornTop] = craftings
	rA[balls[b].recipeApricornLeft] = rA[balls[b].recipeApricornLeft] + craftings
	rA[balls[b].recipeApricornRight] = rA[balls[b].recipeApricornRight] + craftings
	rA[balls[b].recipeApricornBottom] = rA[balls[b].recipeApricornBottom] + craftings
	return rA
end

function doWeHaveEnoughApricornsFor(b,craftings)
	reqA = getRequiredApricorns(b,craftings)
	for k, v in pairs(reqA) do
		if v > aCount[k] then
			return false
		end
	end
	return true
end

function getMaxPossibleCraftings(b)
	rA = getRequiredApricorns(b) -- get amount required for 1 crafting recipe
	
	--calculate how many ball b each color of apricorn could theoretically provide for
	maxCraftingsProvidedFor = {}
	for color, totalAvailable in pairs(aCount) do
		if rA[color] == 0 then
			maxCraftingsProvidedFor[color] = math.maxinteger
		elseif (totalAvailable >= apricornShortcutCount) then
			maxCraftingsProvidedFor[color] = maxCraftingsLimit
		else 
			maxCraftingsProvidedFor[color] = totalAvailable / rA[color]
		end
		--print(totalAvailable)
	end
	
	--get the min value in our maxCraftingsProvidedFor table
	craftingLimit = maxCraftingsLimit
	for color, maxP in pairs(maxCraftingsProvidedFor) do
		if maxP < craftingLimit then
			craftingLimit = maxP
		end
		--print(maxP)
	end
	
	return craftingLimit
end

function getMaxPossibleCraftingsByInput(b,limitByApricorns)
	inputCount = getCountInInventory(inBarrel,balls[b].recipeCenter)
	return math.min(inputCount,limitByApricorns)
end

function craftBalls(b, craftings)
	if not slotApricorns(2,balls[b].recipeApricornTop,craftings) then return false end
	if not slotApricorns(5,balls[b].recipeApricornLeft,craftings) then return false end
	if not slotApricorns(7,balls[b].recipeApricornRight,craftings) then return false end
	if not slotApricorns(10,balls[b].recipeApricornBottom,craftings) then return false end
	if not slotCenterIngredient(balls[b].recipeCenter,craftings) then return false end
	if turtle.craft() then
		turtle.drop()
		speaker.playNote("bit",1.2,14)
		speaker.playNote("bit",1.2,16)
		speaker.playNote("bit",1.2,26)
		return "back"
	end
end

function slotApricorns(slot, color, quantity)
	if transferQuantity(aChest[color],workChest, math.min(quantity,16)) then
		turtle.select(slot)
		return turtle.suckUp(16)
	else
		return false
	end
end

function slotCenterIngredient(ingredient, quantity)
	if transferQuantity(inBarrel,workChest,math.min(quantity,16),ingredient) then
		turtle.select(6)
		return turtle.suckUp(16)
	else
		return false
	end
end

function transferQuantity(fromChest, toChest, quantity, targetItem)
	totalGrabbed = 0
	contents = fromChest.list()
	if (contents == nil) then
		return false
	end
	for k, v in pairs(contents) do
		--skip this item if it's not a match to our target item, if any
		if (targetItem ~= nil) then
			if (v.name ~= targetItem) then
				goto continue
			end
		end
		
		itemsPushed = fromChest.pushItems(peripheral.getName(toChest),k,quantity-totalGrabbed,1)
		if itemsPushed == quantity then
			return true
		else 
			totalGrabbed = totalGrabbed + itemsPushed
		end
		
		::continue::
	end
	if (totalGrabbed < quantity) then
		return false
	else
		return true
	end
end


--------------------------------
----Main program starts here----
--------------------------------
print("Starting Pokeball Storefront")
term.redirect(monitor)

loadBallData()
if (enableSales == true) then
  loadSalesData()
end

while true do
	doMainMenu()
end