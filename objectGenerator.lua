-- Author: PixelFarm, Oscar_8599
-- Name: ObjectGenerator
-- Description: Objects Distribution from bitMap
-- Icon:
-- Hide: no

--VARIABLES--
--Path
local distributionArea = "C:/Users/XXX/Documents/My Games/FarmingSimulator2022/mods/FS22_XXX/maps/map/data/objectGenerator.grle"
source("editorUtils.lua")

-------------------
-----SETTINGS------
-------------------

local bitsObjectDistributionGrle = 8
local useBit = 1
local factor = 300000
local objectRadius = 8 -- Minimum distance between objects
local activeTemplate = 0
local resultName = "result"
local randomYRotation = true
local randomRotation = false
local sameScale = false
local differentScale = false
local randomScaleMin = 2
local randomScaleMax = 8
local randomScaleXMin = 0.8
local randomScaleXMax = 2.7
local randomScaleYMin = 0.7
local randomScaleYMax = 3
local randomScaleZMin = 0.9
local randomScaleZMax = 2
local gridSize = objectRadius -- Set grid size to match object radius

-- FUNCTIONS --
local function printf(formatString, ...)
    print(string.format(formatString, ...))
end

local terrainNode = EditorUtils.getIdsByName("terrain")[1]
if terrainNode == nil then
    printError("No terrain defined!")
    return
end

local terrainSize = getTerrainSize(terrainNode)
local grle = createBitVectorMap("ObjectDensity")
if not loadBitVectorMapFromFile(grle, distributionArea, bitsObjectDistributionGrle) then
    print("Can't load file!")
    return
end

local grid = {}

function getGridCell(x, z)
    return math.floor(x / gridSize), math.floor(z / gridSize)
end

function canPlaceObject(x, z)
    local gx, gz = getGridCell(x, z)
    local minDistSquared = objectRadius * objectRadius

    for dx = -1, 1 do
        for dz = -1, 1 do
            local cell = grid[gx + dx] and grid[gx + dx][gz + dz]
            if cell then
                for _, object in pairs(cell) do
                    local distSquared = (x - object.x) ^ 2 + (z - object.z) ^ 2
                    if distSquared < minDistSquared then
                        return false
                    end
                end
            end
        end
    end

    return true
end

function addObjectToGrid(x, z)
    local gx, gz = getGridCell(x, z)
    grid[gx] = grid[gx] or {}
    grid[gx][gz] = grid[gx][gz] or {}
    table.insert(grid[gx][gz], { x = x, z = z })
end

function createRandomPosition()
    local maxAttempts = 10
    for attempt = 1, maxAttempts do
        local x = math.random(-terrainSize / 2, terrainSize / 2)
        local z = math.random(-terrainSize / 2, terrainSize / 2)
        local value = getBitVectorMapPoint(grle, x + terrainSize / 2, z + terrainSize / 2, 0, bitsObjectDistributionGrle)

        if value == useBit then
            local y = getTerrainHeightAtWorldPos(terrainNode, x, 0, z)
            if canPlaceObject(x, z) then
                return x, y, z
            end
        end
    end
    return nil, nil, nil -- Return nil if no valid position found
end

function applyRandomScale(object)
    if sameScale and not differentScale then
        local scale = math.random(randomScaleMin, randomScaleMax) * 0.01
        setScale(object, scale, scale, scale)
    elseif differentScale and not sameScale then
        setScale(object,
            math.random(randomScaleXMin, randomScaleXMax) * 0.01,
            math.random(randomScaleYMin, randomScaleYMax) * 0.01,
            math.random(randomScaleZMin, randomScaleZMax) * 0.01
        )
    else
        setScale(object, 1, 1, 1)
    end
end

function applyRandomRotation(object)
    if randomYRotation and not randomRotation then
        setRotation(object, 0, math.random() * 2 * math.pi, 0)
    elseif randomRotation then
        setRotation(object,
            math.random() * 2 * math.pi,
            math.random() * 2 * math.pi,
            math.random() * 2 * math.pi
        )
    else
        setRotation(object, 0, 0, 0)
    end
end

function placeObject(templateTg, resultTg, x, y, z)
    local templateNum = math.random(0, getNumOfChildren(templateTg) - 1)
    local newObject = clone(getChildAt(templateTg, templateNum), false, true)
    link(resultTg, newObject)
    setTranslation(newObject, x, y, z)
    applyRandomScale(newObject)
    applyRandomRotation(newObject)
    addObjectToGrid(x, z)
end

-- MAIN SCRIPT --
local parentTg = EditorUtils.getIdsByName("objectsToDistribute")[1]
if parentTg == nil then
    print("Error: Template node not found. Node needs to be named 'objectsToDistribute'.")
    return
end

if getNumOfChildren(parentTg) == 0 or getNumOfChildren(parentTg) < (activeTemplate + 1) or activeTemplate < 0 then
    print("Error: Could not find any valid template.")
    return
end

local templateTg = getChildAt(parentTg, activeTemplate)
local resultTg = createTransformGroup(resultName)
link(getRootNode(), resultTg)

for i = 1, factor do
    local x, y, z = createRandomPosition()
    if x and y and z then
        placeObject(templateTg, resultTg, x, y, z)
    end
end

local numPlacedObjects = getNumOfChildren(resultTg)
print(string.format("%d Objects placed!", numPlacedObjects))
