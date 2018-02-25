script_name("soltar reboques")
script_author("Um Geek")
script_description("aperte Y para soltar reboques")

local BUTTON_COMMAND = 11 -- Y/YES

function main()
	while true do
		wait(40)
		if isPlayerControlOn(PLAYER_HANDLE) then
			local vehicle = getCarCharIsUsing(PLAYER_PED)
			if doesVehicleExist(vehicle) then
				if isThisModelACar(getCarModel(vehicle)) then
					if buttonCommand(BUTTON_COMMAND) then -- button YES/Y
						local trailer = get_TrailerInCar(vehicle)
						if doesVehicleExist(trailer) then 
							detachTrailerFromCab(trailer, vehicle)
							--printStringNow("Trailer liberado!", 1500)
						end
					end
				end
			end
		end
	end
end

function get_TrailerInCar(int_car)
	if doesVehicleExist(int_car) then 
		local intVarA = getCarPointer(int_car)
		intVarA = intVarA + 1224
		intVarA = readMemory(intVarA, 4, false)
		intVarA = getVehiclePointerHandle(intVarA)
		if doesVehicleExist(intVarA) then 
			return intVarA
		end
	end
	return -1
end

function buttonCommand(int_button)
	if isButtonPressed(PLAYER_HANDLE, int_button) then 
		while isButtonPressed(int_button) do wait(5) end
		return true
	end
	return false
end