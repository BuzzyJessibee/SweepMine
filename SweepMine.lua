local sweepframe = CreateFrame("Frame", "SweepMineFrame", UIParent, "BasicFrameTemplate")
local sweepreset = CreateFrame("Button", "SweepResetButton", sweepframe, "UIPanelButtonTemplate")

print("[|cFF9370DBSweepMine|r] Welcome to SweepMine - use /sweepmine to open the frame!")

-- Globals
SweepBoard = {}
SweepBombs = {}
TotalSweepBombs = 0
FlaggedBombs = 0
MissplacedBombs = 0

-- Make a title for the window
sweepframe.TitleText:SetText("SweepMine")
sweepframe.TitleText:SetPoint("TOP", sweepframe, "TOP", 0, -6);
sweepframe.TitleText:SetTextColor(0.8, 0, 0.8, 1);

-- Make our frame draggable so that people can move it where they want
sweepframe:SetMovable(true)
sweepframe:EnableMouse(true)
sweepframe:RegisterForDrag("LeftButton")
sweepframe:SetScript("OnDragStart", sweepframe.StartMoving)
sweepframe:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)
sweepframe:SetClampedToScreen(true)

-- The code below makes the frame visible.
sweepframe:SetPoint("CENTER")
sweepframe:SetSize(180, 225)

-- Make the reset button visable too
sweepreset:SetPoint("BOTTOM", sweepframe, "BOTTOM", 0, 10)
sweepreset:SetSize(80, 20)
sweepreset:SetText("Reset Game")

local function bombGenerator(bombsToPlace)
	-- If this is our first run through
	if MissplacedBombs == 0 then
		for i = 1, bombsToPlace do
			
			-- Randomly pick two coords
			local x = math.random(8)
			local y = math.random(8)

			-- If this isn't already a bomb location
			if SweepBombs[x..","..y] == nil then
				SweepBombs[x..","..y] = true
				SweepBoard[x][y] = 1
				TotalSweepBombs = TotalSweepBombs + 1
			else
				-- If a bomb location is already occupied, add one to the counter
				-- so that it will be re-placed
				-- print("[|cFF9370DBSweepMine|r] Conflict Found, will re-place bomb...")
				MissplacedBombs = MissplacedBombs + 1
			end
		end

	-- If this function is being called a second time
	else
		for i = 1, bombsToPlace do
			
			-- Random Coords
			local x = math.random(8)
			local y = math.random(8)

			-- If this isn't already a bomb location then we successfully placed the bomb
			if SweepBombs[x..","..y] == nil then
				SweepBombs[x..","..y] = true
				SweepBoard[x][y] = 1
				TotalSweepBombs = TotalSweepBombs + 1

				-- The only difference is we remove missplaced bombs as we fix them
				MissplacedBombs = MissplacedBombs - 1
			end
		end
	end
end
-- Generate a 2D gameboard
local function generateBoard()
	-- Init Board and Bombs tables
	SweepBoard = {}
	SweepBombs = {}

	print("[|cFF9370DBSweepMine|r] Generating SweepMine Board...")

	-- Create a 2D array of all 0s
	for x = 1,8 do
		SweepBoard[x] = {}
		for y = 1,8 do
			SweepBoard[x][y] = 0
		end
	end

	-- Randomly place bombs on the board
	-- A "Bomb" is just a 1 in the 2D array
	bombGenerator(10)
	while MissplacedBombs > 0 do
		-- print("[|cFF9370DBSweepMine|r] Re-placing Missplaced Bombs...")
		bombGenerator(MissplacedBombs)
	end

	print("[|cFF9370DBSweepMine|r] A SweepMine Board has been generated!")
	print("[|cFF9370DBSweepMine|r] There are |cFF9370DB"..TotalSweepBombs.."|r total bombs!")
end

-- Check if a user has won. A user wins if they flag all the bombs.
local function verifyWin()
	if FlaggedBombs == TotalSweepBombs then 
		-- Disable the board
		for x = 1, 8 do
			for y = 1, 8 do
				local framename = "x"..x.."y"..y
				_G[framename]:Disable()
			end
		end	
		message('You Win! Press the reset button or to play again!')
	end
end

-- Flag or Unflag a Space
local function flagSpace(x, y, frame)
	if SweepBoard[x][y] == 0 then
		frame:SetText("F")
		SweepBoard[x][y] = 2
	elseif SweepBoard[x][y] == 1 then
		frame:SetText("F")
		SweepBoard[x][y] = 3
		FlaggedBombs = FlaggedBombs + 1
	elseif SweepBoard[x][y] == 2 then
		frame:SetText("")
		SweepBoard[x][y] = 0
	elseif SweepBoard[x][y] == 3 then
		frame:SetText("")
		SweepBoard[x][y] = 1
		FlaggedBombs = FlaggedBombs - 1
	end
	verifyWin()
end

-- Reveals a space when clicked, also displays the numBombs close to the clicked square
local function revealSpace(x, y, frame)
	-- How many bombs are adjacent to the current square
	local adjBombs = 0

	-- Prevents a flaw in the program logic that would break the game if the user left clicked
	-- on a flagged spot. This just calls flagSpace instead to prevent that.
	if SweepBoard[x][y] == 2 then
		flagSpace(x, y, frame)
	end

	-- If player clicks on a bomb, it's game over
	if SweepBoard[x][y] == 1 or SweepBoard[x][y] == 3 then
		frame:SetText("B")

		-- Show where the bombs were and disable the board
		for x = 1, 8 do
			for y = 1, 8 do
				local framename = "x"..x.."y"..y
				-- If Bomb or Flagged Bomb
				if SweepBoard[x][y] == 1 or SweepBoard[x][y] == 3 then
					_G[framename]:SetText("B")
					_G[framename]:Disable()
				-- If flagged empty space, remove the F
				elseif SweepBoard[x][y] == 2 then
					_G[framename]:SetText("")
					_G[framename]:Disable()
				-- If empty space, just disable it
				elseif SweepBoard[x][y] == 0 then
					_G[framename]:Disable()
				end			
			end
		end	
		message('You blew up! Press the reset button to play again!')
		return
	end

	-- Game Tile States
	-- COVERED_EMPTY = 0
	-- COVERED_MINE = 1
	-- FLAG_EMPTY = 2
	-- FLAG_MINE = 3

	-- Cardinal Directions
	if (x+1) ~= 9 then
		if SweepBoard[x+1][y] == 1 or SweepBoard[x+1][y] == 3 then
			adjBombs = adjBombs + 1
		end
	end
	if (x-1) ~= 0 then
		if SweepBoard[x-1][y] == 1 or SweepBoard[x-1][y] == 3 then
			adjBombs = adjBombs + 1
		end
	end
	if (y+1) ~= 9 then
		if SweepBoard[x][y+1] == 1 or SweepBoard[x][y+1] == 3 then
			adjBombs = adjBombs + 1
		end
	end
	if (y-1) ~= 0 then
		if SweepBoard[x][y-1] == 1 or SweepBoard[x][y-1] == 3 then
			adjBombs = adjBombs + 1
		end
	end

	-- Diagonals
	-- ooX
	-- o*o
	-- ooo
	if (x+1) ~= 9 and (y-1) ~= 0 then
		if SweepBoard[x+1][y-1] == 1 or SweepBoard[x+1][y-1] == 3 then
			adjBombs = adjBombs + 1
		end
	end

	-- Xoo
	-- o*o
	-- ooo
	if (x-1) ~= 0 and (y-1) ~= 0 then
		if SweepBoard[x-1][y-1] == 1 or SweepBoard[x-1][y-1] == 3 then
			adjBombs = adjBombs + 1
		end
	end

	-- ooo
	-- o*o
	-- ooX
	if (x+1) ~= 9 and (y+1) ~= 9 then
		if SweepBoard[x+1][y+1] == 1 or SweepBoard[x+1][y+1] == 3 then
			adjBombs = adjBombs + 1
		end
	end

	-- ooo
	-- o*o
	-- Xoo
	if (x-1) ~= 0 and (y+1) ~= 9 then
		if SweepBoard[x-1][y+1] == 1 or SweepBoard[x-1][y+1] == 3 then
			adjBombs = adjBombs + 1
		end
	end

	frame:SetText(tostring(adjBombs))
	frame:Disable()

end

-- Create a button
local function MakeButtons(buttonX, buttonY)
	-- The base coords to make the grid
	local baseCoordsX = -70
	local baseCoordsY = -30

	-- Init locals
	local x
	local y

	-- Create a button and set the size
	local frame = CreateFrame("Button", "x"..buttonX.."y"..buttonY, sweepframe, "UIPanelButtonTemplate")
	frame:SetSize(20,20)

	-- Set point using size and where we are in the grid
	x = (baseCoordsX + (20 * (buttonX-1)))
	y = (baseCoordsY - (20 * (buttonY-1)))
	frame:SetPoint("TOP", sweepframe, x, y)

	frame:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	frame:SetScript("OnClick", function(self, button, down)
		-- Grab the name of the frame so that we can edit it
		local name = self:GetName()

		-- The frame's X and Y can be derived from the name
		local framex = tonumber(name:sub(2, 2))
		local framey = tonumber(name:sub(4, 4))

		-- Depending on what button the user clicks we do other stuff
		if button == "RightButton" then
			flagSpace(framex, framey, self)
		elseif button == "LeftButton" then
			revealSpace(framex, framey, self)
		end
	end)
end

-- Make the button grid
for x = 1, 8 do
	for y = 1, 8 do
		local buttonX, buttonY = x, y
		MakeButtons(buttonX, buttonY);
	end
end

-- Generate the board for the first time
generateBoard()

-- If the reset button is pressed, reset the game entirely
-- It has to be at the bottom because Lua doesn't have function hoisting
sweepreset:SetScript("OnClick", function(self, button, down)
	-- Initialize the buttons
	for x = 1, 8 do
		for y = 1, 8 do
			local framename = "x"..x.."y"..y
			_G[framename]:SetText("")
			_G[framename]:Enable()
		end
	end	

	-- Make a new Gameboard
	TotalSweepBombs = 0
	FlaggedBombs = 0
	MissplacedBombs = 0
	generateBoard()

	print("[|cFF9370DBSweepMine|r] SweepMine has been reset!")
end)

--Make a Slash Command so that we can open the frame again if we close it
SLASH_VER1 = '/sweepmine'
function SlashCmdList.VER(msg, editBox)
	if sweepframe:IsVisible() then
		sweepframe:Hide()
	else
		sweepframe:Show()
	end
end

sweepframe:Hide()













