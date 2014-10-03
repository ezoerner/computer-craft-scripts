computer-craft
==============

Scripts to run in Minecraft with the ComputerCraft mod. http://www.computercraft.info
Currently these scripts are all for turtles.

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
**Usage:** torch-tunnel.lua <tunnelLength> <torchInterval>

Same as the stock tunnel, but also places torches every <torchInterval> blocks.
To prepare:
- slot 16: torches
- slot 15: cobblestone
- fuel in any other slot(s)

vertical-mineshaft.lua
----------------------
Based on ["Vertical mineshaft with water drop"](http://www.minecraftwiki.net/wiki/Mining#Vertical_mineshaft_with_water_drop).

Start with turtle at level that will be top of shaft and facing forward to what will become the alcove.

Prepare the turtle with the following inventory. This assumes the shaft is started at about sea level.
- slot 16: 24+ torches
- slot 15: water bucket
- slot 14: water bucket
- slot 13: about 60 ladders (apparently vines don't work)
- slot 12: 1+ cobblestone, used for comparison purposes.
- any slot 11 or less: fuel, only a handful of coal should be needed

branches.lua
------------
Does branch mining.

**Usage:** branches.lua <branchLength> <numBranches> [<branchInterval>]

Digs branches off a 3x2 access shaft presumed to have already been dug.
Each branch is <branchLength> and branches occur every
<branchInterval> blocks (defaults to 3 if not provided, or if specified then must be at least 2).
The program will try to continue until numBranches have been mined.

To prepare:
- slot 16: torches
- slot 15: cobblestone
- fuel in any other slot(s)