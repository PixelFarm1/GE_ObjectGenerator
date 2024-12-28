-- Author: PixelFarm, Oscar_8599
-- Name: ObjectGenerator
-- Description: Improved Objects Distribution with Bitmap Control and Radius Enforcement
-- Icon:
-- Hide: no
-- AlwaysLoaded: no
source("editorUtils.lua")

-- VARIABLES --
local distributionArea = "C:/Users/XXX/Documents/My Games/FarmingSimulator2025/mods/FS25_XXX/maps/data/objectGenerator.grle"

local useBit = 1 -- Change only if you have multiple channels painted and need to change channel.
local factor = 300000 -- Higher => more tries and longer time to run the script.
local objectRadius = 8 -- Minimum distance between objects

-- Set Active Template
local activeTemplate = 0 -- Set active template to use for object distribution.
local resultName = "result" -- Set name for result transform containing your placed objects.

-- Rotation Setting Boolean
local randomYRotation = true -- Set to true if you want random Y rotation.
local randomRotation = false -- Set to true if you want random X, Y, Z rotation.
-- Set Both to false if you want 0 rotation.

-- Different Rotation values for  X, Z
local randomRotXMax = 3.0 -- Rotate X this much at most.
local randomRotZMax = 3.0 -- Rotate Z this much at most.


-- Scale Settings Booleans
local sameScale = false -- Set to true if you want the same scale for X, Y, Z but random for each child.
local differentScale = false -- Set to true if you want random scale for X, Y, Z for each child.

-- Scale Settings Values
local randomScaleMin = 2 -- Scale each object in the scale between the set values.
local randomScaleMax = 8

-- Different Scale values for  X, Y, Z
local randomScaleXMin = 0.8 -- Scale X between the set values.
local randomScaleXMax = 2.7 -- Scale X between the set values.

local randomScaleYMin = 0.7 -- Scale Y between the set values.
local randomScaleYMax = 3 -- Scale Y between the set values.

local randomScaleZMin = 0.9 -- Scale Z between the set values.
local randomScaleZMax = 2 -- Scale Z between the set values.


local bitsObjectDistributionGrle = 8 -- You should never have to change this
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
        setRotation(object, 0, math.random(0, 360) * math.pi / 180 , 0)
    elseif randomRotation then
        setRotation(object,
            (0 + (randomRotXMax - 0) * math.random()) * math.pi / 180,
            math.random(0, 360) * math.pi / 180,
            (0 + (randomRotZMax - 0) * math.random()) * math.pi / 180
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
