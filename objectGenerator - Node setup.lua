-- Author: PixelFarm
-- Name:objectGenerator - Node setup
-- Description: Creates two template groups for the objectGenerator script
-- Icon:
-- Hide: no

local rootNode = getChildAt(getRootNode(), 0)
local resultTg = createTransformGroup("objectsToDistribute")
link(rootNode, resultTg)

local template0 = createTransformGroup("Template 0")
local template1 = createTransformGroup("Template 1")

link(resultTg, template0)
link(resultTg, template1)

print("Nodes have been set up. You can now add objects to the templates!")