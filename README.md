PokeBall shop interface for ComputerCraft + Cobblemon using [ButtonAPI](https://github.com/Siarko/ButtonApi).

Crafts balls on demand and sells miscellaneous items too.

Designed to run on an Advanced Turtle and displayed on a 7x3 color monitor, with one barrel/chest for input (materials/payment) and one for output. I like to put the output above the screen with an outward-facing funnel (Create mod) to immediately spit out the purchased items.

Usage:
1. Build a KurtBot stall per the above specs.
2. Place your Advanced Turtle and equip it with a speaker and a workbench.
3. Place a chest directly top of the turtle to be its workChest. This chest needs to be *both* directly top of the turtle *and* connected via modem.
4. Connect your monitor, input barrel, output barrel/chest, workChest, payment-storage chest, and apricorn storage chests (one for each color) to your turtle with wired modems, noting each peripheral's name/number as you enable the modem, eg "minecraft:chest_17".
	-Being immediately adjacent to the turtle also works -- you'll just use "front" or whatever in lieu of a name/number.
5. Update the chest names/numbers in pokeballStore.lua under the "Peripheral Names", "Apricorn chest names", and "Other chest names" headings.
6. PokeBalls for sale can be configured (recipe, description, and text formatting) in pokeballs.txt. Miscellaneous items for sale can likewise be configured (sale quantity, cost item, cost quantity) in sales.txt.
