-- Author: PixelFarm
-- Name:objectGenerator - Node setup
-- Description: Creates two template groups for the objectGenerator script
-- Icon:
-- Hide: no

local rootNode = getChildAt(getRootNode(), 0)
local objectTg = createTransformGroup("objectsToDistribute")
link(rootNode, objectTg)

local template0 = createTransformGroup("Template 0")
local template1 = createTransformGroup("Template 1")

link(objectTg, template0)
link(objectTg, template1)

print("Nodes have been set up. You can now add objects to the templates!")
