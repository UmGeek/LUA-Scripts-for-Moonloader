script_name("soltar reboques")
script_author("Um Geek")
script_description("aperte Y para soltar reboques")

local BUTTON_COMMAND = 11 -- Y/YES

function main()
	while true do
		wait(40)
		if isPlayerControlOn(PLAYER_HANDLE) then
			local vehicle = getCarCharIsUsing(PLAYER_PED)
			if doesVehicleExist(vehicle) and isButtonPressed(PLAYER_HANDLE, BUTTON_COMMAND) then
				detachTrailerFromCab(getVehiclePointerHandle(readMemory(getCarPointer(vehicle) + 1224, 4, false)), vehicle)
			end
		end
	end
end
