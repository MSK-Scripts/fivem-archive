## Description
* You can now have more pistols or rifles than only one!
* Seperate Ammunition with each weapon

**IMPORTANT**
* This is only tested with ESX 1.6.0, 1.7.5, 1.9.3 and above
* With ESX 1.10.2 the default resmon is 0.01 ms. With this changes, the resmon will increase to 0.03ms.
* You can't have 2 Pistols, that doesn't work! But you can have 1 Pistol and 1 Combatpistol with different Ammunation.

**Nice to know**
* With this Snippet, I fixed LegacyFuel *(Petrolcan Issue)* for ESX! 
* You can download it here: [LegacyFuel by InZidiuZ edited by Musiker15](https://github.com/Musiker15/Snippets/tree/main/LegacyFuel)

## Installation
### Serverside
* Open the `player.lua` and then go to `es_extended/server/classes/player.lua` 
* Search for the 3 functions inside the ESX file and replace them.

### Clientside - ESX 1.6.0 & ESX 1.7.5
* Open the `main_for_esx_1.6.0_and_1.7.5.lua` and then go to `es_extended/client/main.lua` and search for `function StartServerSyncLoops()`
* Replace this function with the function inside the `main_for_esx_1.6.0_and_1.7.5.lua` file.

### Clientside - ESX 1.9.3 & ESX 1.9.4 and above
* Open the `main_for_esx_1.9.3_and_above.lua` and then go to `es_extended/client/main.lua` and search for `function StartServerSyncLoops()`
* Replace this function with the function inside the `main_for_esx_1.9.3_and_above.lua` file.