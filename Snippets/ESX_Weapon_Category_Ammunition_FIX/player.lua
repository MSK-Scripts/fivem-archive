function self.addWeaponAmmo(weaponName, ammoCount)
    local _, weapon = self.getWeapon(weaponName)

    if weapon then
        weapon.ammo = weapon.ammo + ammoCount
        SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
        self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo) -- Added by Musiker15
    end
end

function self.removeWeaponAmmo(weaponName, ammoCount)
    local _, weapon = self.getWeapon(weaponName)

    if weapon then
        weapon.ammo = weapon.ammo - ammoCount
        self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo) -- Added by Musiker15
    end
end

function self.updateWeaponAmmo(weaponName, ammoCount)
    local _, weapon = self.getWeapon(weaponName)

    if weapon then
        weapon.ammo = ammoCount
        self.triggerEvent('esx:setWeaponAmmo', weaponName, weapon.ammo) -- Added by Musiker15
    end
end