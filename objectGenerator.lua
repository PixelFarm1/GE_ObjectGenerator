-- Author: PixelFarm, Oscar_8599
-- Name: ObjectGenerator
-- Description: Objects Distribution from bitMap
-- Icon:
-- Hide: no

--VARIABLES--
--Path
local distributionArea = "C:/Users/XXX/Documents/My Games/FarmingSimulator2022/mods/FS22_XXX/maps/map/data/objectGenerator.grle"

-------------------
-----SETTINGS------
-------------------

local bitsObjectDistributionGrle = 8



local useBit = 1 -- Change only if you have multiple channels painted and need to change channel.
local factor = 750000 -- Higher => more tries and longer time to run the script.
local objectRadius = 10 -- Handles distance between objects.

-- Set Active Template
local activeTemplate = 0 -- Set active template to use for object distribution.
local resultName = "result" -- Set name for result transform containing your placed objects.

-- Rotation Setting Boolean
local randomYRotation = true -- Set to true if you want random Y rotation.
local randomRotation = false -- Set to true if you want random X, Y, Z rotation.
-- Set Both to false if you want 0 rotation.

-- Scale Settings Booleans
local sameScale = false -- Set to true if you want the same scale for X, Y, Z but random for each child.
local differentScale = false -- Set to true if you want random scale for X, Y, Z for each child.

-- Scale Settings Values
local randomScaleMin = 0.8 -- Scale each object in the scale between the set values.
local randomScaleMax = 2.7

-- Different Scale values for  X, Y, Z
local randomScaleXMin = 0.8 -- Scale X between the set values.
local randomScaleXMax = 2.7 -- Scale X between the set values.

local randomScaleYMin = 0.7 -- Scale Y between the set values.
local randomScaleYMax = 3 -- Scale Y between the set values.

local randomScaleZMin = 0.9 -- Scale Z between the set values.
local randomScaleZMax = 2 -- Scale Z between the set values.

--------------------
--NO CHANGES BELOW--
--------------------

local function printf(formatString, ...)
    print(string.format(formatString, ...))
end

--Terrain
local terrain = getChild(getChildAt(getRootNode(), 0), "terrain")
local terrainSize = getTerrainSize(terrain)


--Load GRLE
local grle = createBitVectorMap("ObjectDensity")
if not loadBitVectorMapFromFile(grle, distributionArea, bitsObjectDistributionGrle) then
    print("Can't load file!")
    return;
end

function createRandomPosition()
    local h1 = math.random(-terrainSize / 2, terrainSize / 2)
    local l1 = math.random(1, 9)
    local h2 = math.random(-terrainSize / 2, terrainSize / 2)
    local l2 = math.random(1, 9)

    local x = h1 + l1 * 0.1
    local z = h2 + l2 * 0.1

    local y = getTerrainHeightAtWorldPos(terrain, x, 0, z)
    return x, y, z
end

local rootNode = getChildAt(getRootNode(), 0)
local parentTg = 0

for i = 0, getNumOfChildren(rootNode) - 1 do
    local correctName = getChildAt(rootNode, i)
    if (getName(correctName) == "objectsToDistribute") then
        parentTg = correctName
        break
    end
end

if (parentTg == 0) then
    print("Error: Template node not found. Node needs to be named 'objectsToDistribute'.")
    return
end

if getNumOfChildren(parentTg) == 0 or getNumOfChildren(parentTg) < (activeTemplate + 1) or activeTemplate < 0 then
    if getNumOfChildren(parentTg) == 1 then
        printf("Error: Could not find any template matching node index %d, the total number of child nodes (possible templates) was %d (index %d)"
            , activeTemplate, getNumOfChildren(parentTg), 0)
        return
        elseif getNumOfChildren(parentTg) == 0 then
        print("No templates found!")
        return
        else
        printf("Error: Could not find any template matching node index %d, the total number of child nodes (possible templates) was %d (index %d-%d)"
            , activeTemplate, getNumOfChildren(parentTg), 0, getNumOfChildren(parentTg)-1)
        return
    end
end

local templateTg = getChildAt(parentTg, activeTemplate)
local numTemplates = (templateTg > 0 and getNumOfChildren(templateTg)) or 0

if numTemplates == 0 then
    print("Error: The selected template contains no objects!")
    return
end

local resultTg = createTransformGroup(resultName)
link(rootNode, resultTg)


local allObjects = {}


function canPlaceObject(x, z)
    for _, object in pairs(allObjects) do
        local dx = math.abs(x - object.x)
        local dz = math.abs(z - object.z)
        if math.sqrt(dx ^ 2 + dz ^ 2) < objectRadius then
            return false
        end
    end
    return true
end

for i = 1, factor do
    local x, y, z = createRandomPosition()
    local value = getBitVectorMapPoint(grle, x + terrainSize / 2, z + terrainSize / 2, 0, bitsObjectDistributionGrle)

    local canSet = true

    if canSet and value == useBit and canPlaceObject(x, z) then
        local templateNum = math.random(0, numTemplates - 1)
        local newObject = clone(getChildAt(templateTg, templateNum), false, true)
        link(resultTg, newObject)

        local rotX = math.random() * 2 * math.pi
        local rotY = math.random() * 2 * math.pi
        local rotZ = math.random() * 2 * math.pi
        local randomScaleSame = math.random(randomScaleMin / 0.01, randomScaleMax / 0.01)
        local scaleX = math.random(randomScaleXMin / 0.01, randomScaleXMax / 0.01)
        local scaleY = math.random(randomScaleYMin / 0.01, randomScaleYMax / 0.01)
        local scaleZ = math.random(randomScaleZMin / 0.01, randomScaleZMax / 0.01)

        setTranslation(newObject, x, y, z)

        if sameScale == true and differentScale == false then
            setScale(newObject, randomScaleSame * 0.01, randomScaleSame * 0.01, randomScaleSame * 0.01)
        elseif differentScale == true and sameScale == false then
            setScale(newObject, scaleX * 0.01, scaleY * 0.01, scaleZ * 0.01)
        elseif differentScale == true and sameScale == true then
            setScale(newObject, 1, 1, 1)
        end

        if randomYRotation == true and randomRotation == false then
            setRotation(newObject, 0, rotY, 0)
        elseif randomYRotation == false and randomRotation == true then
            setRotation(newObject, rotX, rotY, rotZ)
        elseif randomYRotation == true and randomRotation == true then
            setRotation(newObject, rotX, rotY, rotZ)
        elseif randomYRotation == false and randomRotation == false then
            setRotation(newObject, 0, 0, 0)
        end

        table.insert(allObjects, { x = x, z = z })
    end
end
print(#allObjects .. " Objects placed!")
