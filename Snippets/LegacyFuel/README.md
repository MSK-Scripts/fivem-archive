### About
This is [LegacyFuel by InZidiuZ](https://github.com/InZidiuZ/LegacyFuel) edited for ESX to solve the ESX Petrolcan Issue.

You'll need our [Weapon_Category_Ammunition_FIX](https://github.com/Musiker15/Snippets/tree/main/ESX_Weapon_Category_Ammunition_FIX) to make it work! If you don't use our fix it won't work!

### Exports
There are currently two (client-sided) exports available, which should help you control the fuel level for vehicles whenever needed.
```lua
SetFuel(vehicle --[[ Vehicle ]], value --[[ Number: (0-100) ]])
GetFuel(vehicle --[[ Vehicle ]]) -- Returns the vehicle's fuel level.
```

**Example usage:**
```lua
function SpawnVehicle(modelHash)
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, true, false)

    exports["LegacyFuel"]:SetFuel(vehicle, 100)
end

function StoreVehicleInGarage(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local fuelLevel = exports["LegacyFuel"]:GetFuel(vehicle)

    TriggerServerEvent('vehiclesStored', plate, fuelLevel)
end
```

## Credits
* @InZidiuZ - [LegacyFuel by InZidiuZ](https://github.com/InZidiuZ/LegacyFuel)