# GE_ObjectGenerator

This script adds the possibility of generating objects in an area that is defined with a bitmap (infolayer) in Giants Editor. The inbuilt function of mesh painting in GE is not sufficient for all cases of use, since it often places objects too close to each other and it lacks some quality-of-life features such as easy iterations with an erase function etc. 

# How do I prepare my FS22 map for this script?
Start off by downloading the objectGenerator.png file provided on GitHub. Place this somewhere in your map folder, preferably in the …/data folder where other bitmap image files are found. 

Proceed with adding a new fileId to your map.i3d by opening it in any text editor of choice:

    <File fileId="99999" filename="data/objectGenerator.png"/>

Continue by finding the infoLayer section of the map.i3d and create a new infoLayer by pasting the following lines into this section. For advanced users, the “Option value” structure is used to allow for painting in more than 1 channel in case you want to use different channels for different mixes of objects for example. Simply add another option value and change the “useBit” value in the lua script to control what channel is used. 

    <InfoLayer name="objectGenerator" fileId="99999" numChannels="8" runtime="true">
      <Group name="Objects" firstChannel="0" numChannels="8" >
        <Option value="1" name="Object1"/>
      </Group>
    </InfoLayer>

# Using the script in Giants Editor
When this is done you can save and open GE and check for errors. Everything should load just fine. Now you can proceed to paint an area in the infolayer paint mode. Simple enable the paint mode, choose objectGenerator and your desired option (only 1 for basic users). When you are done painting, save the map to generate the GRLE file. 

Unless you have already placed the objectGenerator.lua file in your scripts folder. You are now to create a new script. Simply press Scripts  Create New Script and give it a name. Copy and paste the lua script from GitHub. Proceed with editing the filepath at the top of the script. This must match the path to your objectGenerator.png. 

Before running the script, you need to define what objects are to be placed by the script. This needs to follow a very specific structure in GE to work. For this we have created a template transform group that you can use. Run the objectGenerator - Node setup.lua to set up the nodes automatically or download the templateTG.i3d from GitHub and import it to your map! 

**It is very important that you use this exact structure and that the objectsToDistribute transform group is not embedded within any other transform group!**

You can now place trees, rocks or whatever you want to randomly distribute within the template transform groups like this:

![image](https://user-images.githubusercontent.com/102419040/189506966-7c6e7ba7-75fa-4499-a8ed-43e566865ab9.png)

The script only uses **one template at the time** and objects will be distributed in proportion to their abundance within the template group. This means that if you have 10 trees of which 4 are large, 3 are medium and 3 are small then roughly 40% of the trees will be large, 30% will be medium and 30% will be small. This way you can control the looks of the resulting distribution. 

When you have placed all objects that you want to distribute in the template transforms, it is time to run the script. Within the script there is a lot of settings that you can change to alter the behavior of the script. Every setting is fairly well described with comments within the script and you have to try different settings to find what suits your case. It is possible to change between random scales in different ways and random rotation on different axis. 

Have fun with the script, I hope it helps! 
