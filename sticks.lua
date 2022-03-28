--------------------------------------------------------------------------
--     Inspired by Lee Scholfied  (Painless360)   
--     Scrollable stick commands reference (INAV, Betaflight, HDZero)
--     Version 1.0.2
--     Assumes a display resolution of 128 x 64 (Mambo, Tango 2)
--     Assumes Mode 2
--------------------------------------------------------------------------

local currentRow      = 1       -- Betaflight = 1, HDZero = 14, INAV = 20
local resetRow        = 20
local maxRows         = 41

local function drawStick(x, y, heading, label, currentHeading)

  --     NE example
  -- *  *  *  *  *  *  *     
  -- *              *  *
  -- *           *     *
  -- *        *        *
  -- *                 *
  -- *                 *
  -- *  *  *  *  *  *  *   

    stick = 3

    lcd.drawRectangle(x, y, 7, 7, 1)

    if (heading == "C") then
        lcd.drawLine(x + stick, y + stick, x + stick, y + stick, SOLID, FORCE)
    elseif (heading == "N") then    
        lcd.drawLine(x + stick, y + stick, x + 3, y + 0, SOLID, FORCE)
    elseif (heading == "NE") then    
        lcd.drawLine(x + stick, y + stick, x + 6, y + 0, SOLID, FORCE)
    elseif (heading == "E") then    
        lcd.drawLine(x + stick, y + stick, x + 6, y + 3, SOLID, FORCE)
    elseif (heading == "SE") then    
        lcd.drawLine(x + stick, y + stick, x + 6, y + 6, SOLID, FORCE)
    elseif (heading == "S") then    
        lcd.drawLine(x + stick, y + stick, x + 3, y + 6, SOLID, FORCE)
    elseif (heading == "SW") then    
        lcd.drawLine(x + stick, y + stick, x + 0, y + 6, SOLID, FORCE)
    elseif (heading == "W") then    
        lcd.drawLine(x + stick, y + stick, x + 0, y + 3, SOLID, FORCE)
    elseif (heading == "NW") then    
        lcd.drawLine(x + stick, y + stick, x + 0, y + 0, SOLID, FORCE)
    end    
end
 

local function drawSticks(labelCol, label, xLeft, row, headingLeft, xRight, headingRight, currentHeadingLeft, currentHeadingRight) 
  if (headingLeft == currentHeadingLeft and headingRight == currentHeadingRight) then
    blink = BLINK
  else
    blink = 0
  end
  lcd.drawText(labelCol, row, label, SMLSIZE + blink)
  drawStick(xLeft,  row,  headingLeft)
  drawStick(xRight, row,  headingRight)
  return row + 8
end

local function getStickHeading(stick)
  s1  = 0
  s2  = 0
  dz  = 12
  hdg = ""


  if (stick == "LEFT") then
    s1 = getValue("thr") / 10.24
    s2 = getValue("rud") / 10.24
    -- lcd.drawText(textCol1 + 20, row, string.format("%d,  %d",s1, s2), SMLSIZE)
  elseif (stick == "RIGHT") then
    s1 = getValue("ele") / 10.24
    s2 = getValue("ail") / 10.24
    -- lcd.drawText(textCol2 + 20, row, string.format("%d,  %d",s1, s2), SMLSIZE)
  end
  

  if s1 >= -dz and s1 <= dz and s2 >= -dz and s2 <= dz then
    hdg = "C"
  elseif s1 >= 100-dz and s2 >= -dz and s2 <= dz then
    hdg = "N"
  elseif s1 >= 100-dz and s2 >= 100-dz then  
    hdg = "NE"
  elseif s1 >= -dz and s1 <= dz and s2 >= 100-dz then  
    hdg = "E"
  elseif s1 <= -100+dz and s2 >= 100-dz then  
    hdg = "SE"
  elseif s1 <= -100+dz and s2 >= -dz and s2 <= dz then  
    hdg = "S"
  elseif s1 <= -100+dz and s2 <= -100+dz then  
    hdg = "SW"
  elseif s1 >= -dz and s1 <= dz and s2 <= -100+dz then  
    hdg = "W"
  elseif s1 >= 100-dz and s2 <= -100+dz then  
    hdg = "NW" 
  end
  return hdg
end

local function processEvents(event)
  if event > 0 then
    lastNumberMessage = event
  end
  if event == EVT_VIRTUAL_NEXT then
    lastMessage = "Jog wheel CW"
    if (currentRow + 11) <= maxRows then
      currentRow = currentRow + 1
    end  
    killEvents(EVT_VIRTUAL_NEXT)
  end
  if event == EVT_VIRTUAL_PREV then
    lastMessage = "Jog wheel CCW"
    if (currentRow - 1) > 0 then
      currentRow = currentRow - 1
    end
    killEvents(EVT_VIRTUAL_PREV)
  end
  if event == 96 then
    lastMessage = "Menu Button Pressed"
    currentRow = resetRow
    killEvents(96)
  end
  if event == 98 then
    lastMessage = "Navigate Button Pressed"
    killEvents(98)
  end
end

local function testRow(itemRow)
  if itemRow >= currentRow and itemRow <= (currentRow + 8) then
    return true
  else
    return false
  end
end


local function run(event)

    lcd.clear()

    processEvents(event)

    textCol      = 4
    stickCol     = 100
    row          = 0
    stickOffset  = 9
    dz           = 8
   
    currentHeadingLeft  = getStickHeading("LEFT")
    currentHeadingRight = getStickHeading("RIGHT")


    if testRow(1) == true then
      lcd.drawText(textCol - 4, row, "Betaflight", SMLSIZE)
      row = row + 8
    end
    if testRow(2) == true then
      row = drawSticks(textCol, "BetaFlight Menu",    stickCol, row, "W",  stickCol + stickOffset, "N",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(3) == true then
      row = drawSticks(textCol, "BetaFlight <Enter>", stickCol, row, "C",  stickCol + stickOffset, "E",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(4) == true then
      row = drawSticks(textCol, "Arm",                stickCol, row, "SE", stickCol + stickOffset, "C",  currentHeadingLeft, currentHeadingRight)
    end  
    if testRow(5) == true then
      row = drawSticks(textCol, "Disarm",             stickCol, row, "SW", stickCol + stickOffset, "C",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(6) == true then
      row = drawSticks(textCol, "Calibrate Gyro",     stickCol, row, "SW", stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(7) == true then
      row = drawSticks(textCol, "Calibrate Accel",    stickCol, row, "NW", stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(8) == true then
      row = drawSticks(textCol, "Calibrate Compass",  stickCol, row, "NE", stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(9) == true then
      row = drawSticks(textCol, "Save Settings",      stickCol, row, "SW", stickCol + stickOffset, "SE", currentHeadingLeft, currentHeadingRight)
    end
    if testRow(10) == true then
      row = drawSticks(textCol, "Accel Trim Left",    stickCol, row, "N",  stickCol + stickOffset, "W",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(11) == true then
      row = drawSticks(textCol, "Accel Trim Right",   stickCol, row, "N",  stickCol + stickOffset, "E",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(12) == true then
      row = drawSticks(textCol, "Accel Trim Up/Fwd",  stickCol, row, "N",  stickCol + stickOffset, "N",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(13) == true then
      row = drawSticks(textCol, "Accel Trim Dn/Bak",  stickCol, row, "N",  stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end

    if testRow(14) == true then
      lcd.drawText(textCol - 4, row, "HDZero", SMLSIZE)
      row = row + 8
    end
    if testRow(15) == true then
      row = drawSticks(textCol, "Camera Control",     stickCol, row, "E",  stickCol + stickOffset, "C",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(16) == true then
      row = drawSticks(textCol, "Non-HDZ Cam Exit",   stickCol, row, "W",  stickCol + stickOffset, "C",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(17) == true then
      row = drawSticks(textCol, "Switch to 0mw",      stickCol, row, "SW",  stickCol + stickOffset, "SE",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(18) == true then
      row = drawSticks(textCol, "Exit 0mw",           stickCol, row, "SE",  stickCol + stickOffset, "SW",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(19) == true then
      row = drawSticks(textCol, "Enter VTX Menu",     stickCol, row, "SE",  stickCol + stickOffset, "SW",  currentHeadingLeft, currentHeadingRight)
    end
    

    if testRow(20) == true then
      lcd.drawText(textCol - 4, row, "INAV", SMLSIZE)
      row = row + 8
    end
    if testRow(21) == true then
      row = drawSticks(textCol, "OSD Menu (CMS)",           stickCol, row, "W",   stickCol + stickOffset, "N",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(22) == true then
      row = drawSticks(textCol, "Save settings",            stickCol, row, "SW",  stickCol + stickOffset, "SE",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(23) == true then
      row = drawSticks(textCol, "Load WP mission",          stickCol, row, "S",   stickCol + stickOffset, "NE",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(24) == true then
      row = drawSticks(textCol, "Save WP mission",          stickCol, row, "S",   stickCol + stickOffset, "NW",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(25) == true then
      row = drawSticks(textCol, "Unload WP mission",        stickCol, row, "S",   stickCol + stickOffset, "SE",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(26) == true then
      row = drawSticks(textCol, "Inc WP mission index",     stickCol, row, "W",   stickCol + stickOffset, "E",   currentHeadingLeft, currentHeadingRight)
    end
    if testRow(27) == true then
      row = drawSticks(textCol, "Dec WP mission index",     stickCol, row, "W",   stickCol + stickOffset, "W",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(28) == true then
      row = drawSticks(textCol, "Profile 1",                stickCol, row, "SW",  stickCol + stickOffset, "W",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(29) == true then
      row = drawSticks(textCol, "Profile 2",                stickCol, row, "SW",  stickCol + stickOffset, "N",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(30) == true then
      row = drawSticks(textCol, "Profile 3",                stickCol, row, "SW",  stickCol + stickOffset, "E",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(31) == true then
      row = drawSticks(textCol, "Battery Profile 1",        stickCol, row, "NW",  stickCol + stickOffset, "W",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(32) == true then
      row = drawSticks(textCol, "Battery Profile 2",        stickCol, row, "NW",  stickCol + stickOffset, "N",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(33) == true then
      row = drawSticks(textCol, "Battery Profile 3",        stickCol, row, "NW",  stickCol + stickOffset, "E",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(34) == true then
      row = drawSticks(textCol, "Calibrate Gyro",           stickCol, row, "SW",  stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(35) == true then
      row = drawSticks(textCol, "Calibrate Accel",          stickCol, row, "NW",  stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(36) == true then
      row = drawSticks(textCol, "Calibrate Compass",        stickCol, row, "NE",  stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(37) == true then
      row = drawSticks(textCol, "Trim Accel Left",          stickCol, row, "N",  stickCol + stickOffset, "W",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(38) == true then
      row = drawSticks(textCol, "Trim Accel Right",         stickCol, row, "N",  stickCol + stickOffset, "E",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(39) == true then
      row = drawSticks(textCol, "Trim Accel Forward",       stickCol, row, "N",  stickCol + stickOffset, "N",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(40) == true then
      row = drawSticks(textCol, "Trim Accel Backward",      stickCol, row, "N",  stickCol + stickOffset, "S",  currentHeadingLeft, currentHeadingRight)
    end
    if testRow(41) == true then
      row = drawSticks(textCol, "Bypass Arming Checks",     stickCol, row, "SE", stickCol + stickOffset, "C",  currentHeadingLeft, currentHeadingRight)
    end

    return 0
end



local function init_func()
    -- Called once when model is loaded, only need to get model name once...
    local modeldata = model.getInfo()
    if modeldata then
      modelName = modeldata['name']
    end
end
 
return { run=run, init=init_func  }

