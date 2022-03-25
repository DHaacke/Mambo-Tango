--------------------------------------------------------------------------
--     Inspired by Lee Scholfied  (Painless360)   
--     Scrollable stick commands reference (INAV, Betaflight, HDZero)
--     Version 1.0 BETA
--     Assumes a display resolution of 468 x 272 (TX16S, T16, others)
--     Assumes Mode 2
--------------------------------------------------------------------------

local currentRow      = 20       -- Betaflight = 1, HDZero = 14, INAV = 20
local resetRow        = 20
local maxRows         = 41
local textSize        = MIDSIZE
local screenWidth     = LCD_W
local screenHeight    = LCD_H
local stickRect       = 22
local lineHeight      = 24
local JOG_WHEEL_CW    = 56832
local JOG_WHEEL_CCW   = 57088

local labelCol        = 24
local row             = 0
local currentHeadingLeft  = 0
local currentHeadingRight = 0

local function drawStick(x, y, heading)

    stick = stickRect / 2
    y = y + 4

    lcd.drawRectangle(x, y, stickRect, stickRect, 0, 2)

    if (heading == "C") then
        lcd.drawLine(x + stick-1, y + stick, x + stick+1, y + stick, SOLID, 0)
        lcd.drawLine(x + stick,   y + stick-1, x + stick, y + stick+1, SOLID, 0)
    elseif (heading == "N") then
        lcd.drawLine(x + stick, y + stick, x + stick-1, y + 0, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + stick, y + 0, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + stick+1, y + 0, SOLID, 0)
    elseif (heading == "NE") then
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + 0, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + 1, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y - 1, SOLID, 0)
    elseif (heading == "E") then    
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + stick, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + stick-1, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + stick+1, SOLID, 0)
    elseif (heading == "SE") then    
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + (stick * 2), SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + (stick * 2)-1, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + (stick * 2), y + (stick * 2)+1, SOLID, 0)
    elseif (heading == "S") then    
        lcd.drawLine(x + stick, y + stick, x + stick, y + (stick * 2), SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + stick-1, y + (stick * 2), SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + stick+1, y + (stick * 2), SOLID, 0)
    elseif (heading == "SW") then    
        lcd.drawLine(x + stick, y + stick, x + 0, y + (stick * 2), SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x - 1, y + (stick * 2), SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + 1, y + (stick * 2), SOLID, 0)
    elseif (heading == "W") then    
        lcd.drawLine(x + stick, y + stick, x + 0, y + stick, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + 0, y + stick-1, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + 0, y + stick+1, SOLID, 0)
    elseif (heading == "NW") then    
        lcd.drawLine(x + stick, y + stick, x + 0, y + 0, SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + 0, y - 1 , SOLID, 0)
        lcd.drawLine(x + stick, y + stick, x + 0, y + 1, SOLID, 0)
    end    

end

local function drawStickCommand(x, y, label, headingLeft, headingRight, isBanner)
  stickCol    = 360
  stickSize   = 22
  stickOffset = 4
  stickGutter = 30

  if isBanner == true then
    lcd.drawFilledRectangle(0, row + 2, screenWidth, lineHeight, FORCE)
    -- lcd.drawRectangle(0, row + lineHeight, screenWidth, 2, 0, 1)
    lcd.setColor(TEXT_COLOR, WHITE)
    lcd.drawText(x - 12, y, label, MIDSIZE)
    lcd.setColor(TEXT_COLOR, BLACK)
  else
    lcd.drawText(x, y, label, MIDSIZE)
    drawStick(stickCol, y, headingLeft)
    drawStick(stickCol + stickGutter, y, headingRight)

    if headingLeft == currentHeadingLeft and headingRight == currentHeadingRight then
      lcd.drawRectangle(stickCol - 10, y + 3, (stickRect * 2) + stickGutter, stickRect + 2, DOTTED, 1)
    end 
  end

  return lineHeight
end

local function processEvents(event)
  if event > 0 then
    lastNumberMessage = event
  end
  if event == JOG_WHEEL_CW then
    lastMessage = "Jog wheel CW"
    if (currentRow + 11) <= maxRows then
      currentRow = currentRow + 1
    end  
    killEvents(JOG_WHEEL_CW)
  end
  if event ==JOG_WHEEL_CCW then
    lastMessage = "Jog wheel CCW"
    if (currentRow - 1) > 0 then
      currentRow = currentRow - 1
    end
    killEvents(JOG_WHEEL_CCW)
  end
  if event == 96 or event == 1538 then
    lastMessage = "Menu or Jog wheel Button Pressed"
    currentRow = resetRow
    killEvents(96)
  end
  if event == 98 then
    lastMessage = "Navigate Button Pressed"
    killEvents(98)
  end
  return event
end


local function getStickHeading(stick)
  s1  = 0
  s2  = 0
  dz  = 12
  hdg = ""

  if (stick == "LEFT") then
    s1 = getValue("thr") / 10.24
    s2 = getValue("rud") / 10.24
  elseif (stick == "RIGHT") then
    s1 = getValue("ele") / 10.24
    s2 = getValue("ail") / 10.24
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


local function testRow(itemRow)
  if itemRow >= currentRow and itemRow <= currentRow + 10  then
    return true
  else
    return false
  end
end

local function run(event)

  lcd.clear()

  processEvents(event)

  currentHeadingLeft  = getStickHeading("LEFT")
  currentHeadingRight = getStickHeading("RIGHT")

  col = 24
  row = 0

  if testRow(1) == true then
    row = row + drawStickCommand(col, row, "Betaflight",          "C",  "C",  true)
  end
  if testRow(2) == true then
    row = row + drawStickCommand(col, row, "Betaflight Menu",     "W",  "N",  false )
  end
  if testRow(3) == true then
    row = row + drawStickCommand(col, row, "Betaflight <enter>",  "C",  "E",  false )
  end
  if testRow(4) == true then
    row = row + drawStickCommand(col, row, "Arm",                "SE",  "C",  false)
  end  
  if testRow(5) == true then
    row = row + drawStickCommand(col, row, "Disarm",             "SW",  "C",  false)
  end
  if testRow(6) == true then
    row = row + drawStickCommand(col, row, "Calibrate Gyro",    "SW",  "S",  false)
  end
  if testRow(7) == true then
    row = row + drawStickCommand(col, row, "Calibrate Accel",    "NW",  "S",  false)    
  end
  if testRow(8) == true then
    row = row + drawStickCommand(col, row, "Calibrate Compass",  "NE",  "S",  false)    
  end
  if testRow(9) == true then
    row = row + drawStickCommand(col, row, "Save Settings",      "SW",  "SE", false)   
  end
  if testRow(10) == true then
    row = row + drawStickCommand(col, row, "Accel Trim Left",    "N",   "W",  false)
  end
  if testRow(11) == true then
    row = row + drawStickCommand(col, row, "Accel Trim Right",   "N",   "E",  false)
  end
  if testRow(12) == true then
    row = row + drawStickCommand(col, row, "Accel Trim Up/Fwd",  "N",   "N",  false)
  end
  if testRow(13) == true then
    row = row + drawStickCommand(col, row, "Accel Trim Dn/Bak",  "N",   "S",  false)
  end

  if testRow(14) == true then
    row = row + drawStickCommand(col, row, "HDZero",             "C",   "C",  true)
  end
  if testRow(15) == true then
    row = row + drawStickCommand(col, row, "Camera Control",     "E",   "C",  false)
  end
  if testRow(16) == true then
    row = row + drawStickCommand(col, row, "Non-HDZ Cam Exit",   "W",   "C",  false)
  end
  if testRow(17) == true then
    row = row + drawStickCommand(col, row, "Switch to 0mw",      "SW",  "SE", false)
  end
  if testRow(18) == true then
    row = row + drawStickCommand(col, row, "Exit 0mw",           "SE",  "SW", false)
  end
  if testRow(19) == true then
    row = row + drawStickCommand(col, row, "Enter VTX Menu",     "SE",  "SW", false)
  end

  if testRow(20) == true then
    row = row + drawStickCommand(col, row, "INAV",               "C",   "C",  true)
  end  
  if testRow(21) == true then
    row = row + drawStickCommand(col, row, "OSD Menu (CMS)",     "W",   "N",  false)
  end
  if testRow(22) == true then
    row = row + drawStickCommand(col, row, "Save settings",            "SW",  "SE",  false)
  end
  if testRow(23) == true then
    row = row + drawStickCommand(col, row, "Load WP mission",          "S",   "NE",  false)
  end
  if testRow(24) == true then
    row = row + drawStickCommand(col, row, "Save WP mission",          "S",   "NW",  false)
  end
  if testRow(25) == true then
    row = row + drawStickCommand(col, row, "Unload WP mission",        "S",   "SE",  false)
  end
  if testRow(26) == true then
    row = row + drawStickCommand(col, row, "Inc WP mission index",     "W",   "E",   false)
  end
  if testRow(27) == true then
    row = row + drawStickCommand(col, row, "Dec WP mission index",     "W",   "W",  false)
  end
  if testRow(28) == true then
    row = row + drawStickCommand(col, row, "Profile 1",                "SW",  "W",  false)
  end
  if testRow(29) == true then
    row = row + drawStickCommand(col, row, "Profile 2",                "SW",  "N",  false)
  end
  if testRow(30) == true then
    row = row + drawStickCommand(col, row, "Profile 3",                "SW",  "E",  false)
  end
  if testRow(31) == true then
    row = row + drawStickCommand(col, row, "Battery Profile 1",        "NW",  "W",  false)
  end
  if testRow(32) == true then
    row = row + drawStickCommand(col, row, "Battery Profile 2",        "NW",  "N",  false)
  end
  if testRow(33) == true then
    row = row + drawStickCommand(col, row, "Battery Profile 3",        "NW",  "E",  false)
  end
  if testRow(34) == true then
    row = row + drawStickCommand(col, row, "Calibrate Gyro",           "SW",  "S",  false)
  end
  if testRow(35) == true then
    row = row + drawStickCommand(col, row, "Calibrate Accel",          "NW",  "S",  false)
  end
  if testRow(36) == true then
    row = row + drawStickCommand(col, row, "Calibrate Compass",        "NE",  "S",  false)
  end
  if testRow(37) == true then
    row = row + drawStickCommand(col, row, "Trim Accel Left",          "N",  "W",  false)
  end
  if testRow(38) == true then
    row = row + drawStickCommand(col, row, "Trim Accel Right",         "N",  "E",  false)
  end
  if testRow(39) == true then
    row = row + drawStickCommand(col, row, "Trim Accel Forward",       "N",  "N",  false)
  end
  if testRow(40) == true then
    row = row + drawStickCommand(col, row, "Trim Accel Backward",      "N",  "S",  false)
  end
  if testRow(41) == true then
    row = row + drawStickCommand(col, row, "Bypass Arming Checks",     "SE", "C",  false)
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