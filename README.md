computer-craft
==============

Scripts to run in Minecraft with the ComputerCraft mod. http://www.computercraft.info

common.lua
----------
Common functions used in other scripts

build.lua
---------
Builds a rectangular structure

dive-excavate.lua
-----------------
The same as the stock excavate, but the turtle goes down until it hits an obstacle. Useful for continuing
an excavation that was previously aborted for some reason.

stairbuilder.lua
----------------
builds a stairway around the perimeter of an existing excavation site.

torch-tunnel.lua
----------------
Same as the stock tunnel, but also places torches every 5 blocks.

vertical-mineshaft.lua
----------------------
Based on ["Vertical mineshaft with water drop"](http://www.minecraftwiki.net/wiki/Mining#Vertical_mineshaft_with_water_drop).

Start with turtle at level that will be top of shaft and facing forward to what will be the alcove

Prepare the turtle with the following inventory:
- slot 16: 24+ torches
- slot 15: water bucket
- slot 14: water bucket
- slot 13: water bucket
- slot 12: 64 ladders or vines
- slot 11: 1+ cobblestone, used for comparison
- slot 10: fuel (how many coal are needed?)
