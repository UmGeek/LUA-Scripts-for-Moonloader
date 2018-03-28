--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	
--|	LEIAME - LEIAME -LEIAME - LEIAME - LEIAME - LEIAME - LEIAME - LEIAME - LEIAME - LEIAME
--|
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|
--|	03/2018
--|	
--|	Autor: UM GEEK
--|	Para: GTA San Andreas
--|	
--|	Para instalar este  script é necessario que seu jogo contenha "MoonLoader.asi" instalado
--|	Para ativar basta esta em um veiculo militar e usar botão [10] do controle ou tecla [K] do teclado
--|	o cheat [spike] ativa a permição para usar os espinhos em qualquer veiculo
--|	
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

script_name("spikers mod")
script_author("Um Geek")
local mad = require("MoonAdditions")
local memory = require("memory")
local vkeys = require("vkeys")
local enable_cheat	= false

-- SETTINGS
local active_button = 10 -- N/NO
local active_key = vkeys.VK_K -- K
local vehicles_model_list = {432,427,596,597,598,599}

function main()
	local LuaThreadA = lua_thread.create(copsUseSpikers)
	while true do
		wait(4)
		if testCheat("spike") then 
			if enable_cheat then
				enable_cheat = false
			else 
				enable_cheat = true
			end
			printHelpString("Spikers enabled ~y~"..tostring(enable_cheat ))
		end		
		if testCheat("wlevel")then alterWantedLevel(PLAYER_HANDLE,3)end
		if isPlayerPlaying(PLAYER_HANDLE) then	
			if isButtonPressed(PLAYER_HANDLE,active_button) or wasKeyPressed(active_key) then
				local vehicle = getCarCharIsUsing(PLAYER_PED)
				if doesVehicleExist(vehicle) then
					local md = getCarModel(vehicle)
					if checkModels(md) or enable_cheat then
						playerActiveTrap(vehicle,0.80)
					end
				end
				while isButtonPressed(PLAYER_HANDLE,active_button) do wait(4) end
			else
				applyToAllChars()
				applyEffectInAllVehicles()
			end
		end
	end
end

----------------------------------------------------------------------------------------
function checkModels(mda)
	local t = #vehicles_model_list
	for i=0,t do 
		local mdb = vehicles_model_list[i]
		if mda == mdb then 
			return true
		end
	end
	return false
end

----------------------------------------------------------------------------------------
function playerActiveTrap(vehicle,size)
	local px,py,pz = getOffsetFromCarInWorldCoords(vehicle,0.0,-3.0,0.0)
	local ag = getCarHeading(vehicle)
	local md = 2899
	if getCarSpeed(vehicle) <= 20.0 then
		local scale = 0.1
		local obj = createAndRetObject(md,px,py,-100.00,ag-90.0)
		setObjectScale(obj,scale) 		
		while scale < size do 
			if doesObjectExist(obj) then 
				setObjectScale(obj,scale) 
			end
			scale = scale + 0.080
			wait(0)
		end
		if doesObjectExist(obj) then
			markObjectAsNoLongerNeeded(obj)
		end
	end
end

----------------------------------------------------------------------------------------
function applyEffectInAllVehicles()
	local posx,posy,posz = getCharCoordinates(PLAYER_PED)
	local AllVehicles = mad.get_all_vehicles(posx,posy,posz,60.0,false)--getAllVehicles()
	for i=0,#AllVehicles do 
		if doesVehicleExist(AllVehicles[i]) then 
			local speed = getCarSpeed(AllVehicles[i])
			if not isCarStopped(AllVehicles[i]) then			
				checkVehicleWheelArea(AllVehicles[i])
			end
		end
	end
end

----------------------------------------------------------------------------------------
function checkVehicleWheelArea(vehicle)
	local posx,posy,posz = getCharCoordinates(PLAYER_PED)
	if locateCar2d(vehicle,posx,posy,50.0,50.0,false) then
		local wheels = {}
		wheels[0] = {name = 'wheel_lf_dummy',id = 0}
		wheels[1] = {name = 'wheel_lb_dummy',id = 1}
		wheels[2] = {name = 'wheel_rf_dummy',id = 2}
		wheels[3] = {name = 'wheel_rb_dummy',id = 3}
		wheels[4] = {name = 'wheel_rear',id = 1}
		wheels[5] = {name = 'wheel_front',id = 0}
		for i=0,#wheels do 
			if doesVehicleExist(vehicle) then
				if not isCarTireBurst(vehicle,wheels[i].id) then
					local result,px,py,pz = vehicleStructCoords(vehicle,wheels[i].name)
					if result then
						local px,py,pz = getOffsetFromCarInWorldCoords(vehicle,px,py,pz )
						local result,obj = findAllRandomObjectsInSphere(px,py,pz,1.40,true)
						if result then
							local objmd = getObjectModel(obj)
							if objmd == 2899 then
								local effect = createFxSystem("shootlight",px,py,pz)
								playFxSystem(effect)
								burstCarTire(vehicle,wheels[i].id)
								wait(100)
								killFxSystemNow(effect)
							end
						end
					end
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------
function createAndRetObject(md,px,py,pz,ag)
	if not hasModelLoaded(md) then 
		requestModel(md)
		loadAllModelsNow()
	end 
	local obj = createObject(md,px,py,pz)
	setObjectHeading(obj,ag)
	markModelAsNoLongerNeeded(md)
	return obj
end

----------------------------------------------------------------------------------------
function applyToAllChars()
	local posx,posy,posz = getCharCoordinates(PLAYER_PED)
	local chars = getAllChars()
	for i=0,#chars do
		local ped = chars[i]
		if doesCharExist(ped) then 
			if not is_CharInVehicle(ped) then
				local px,py,pz = getCharCoordinates(ped)
				local result,obj = findAllRandomObjectsInSphere(px,py,pz,1.40,true)
				if result then 
					local objmd = getObjectModel(obj)
					if objmd == 2899 then
						if not isCharPlayingAnim(ped,'EV_step') then 
							taskPlayAnim(ped,'EV_step','ped',4.0,false,true,true,false,-1)
							taskSay(ped,354)
						end
					end
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------
function is_CharInVehicle(id)
	local veh = getCarCharIsUsing(id)
	if not isPlayerUsingJetpack(PLAYER_HANDLE) then
		if doesVehicleExist(veh) then return true end
	end
	return false
end

----------------------------------------------------------------------------------------
function vehicleStructCoords(car,dummy)
	local x,y,z = 0.0,0.0,0.0
	if doesVehicleExist(car)then
		for _, component in ipairs(mad.get_all_vehicle_components(car)) do
			if component.name == dummy then 
				local ptr = component:get_pointer()
				ptr = ptr + 0x40
				x = memory.getfloat(ptr,false)
				ptr = ptr + 0x4
				y = memory.getfloat(ptr,false)
				ptr = ptr + 0x4	
				z = memory.getfloat(ptr,false)
				return true,x,y,z
			end
		end
	end
	return false,x,y,z
end

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

local global_cop_spike = -1
function copsUseSpikers()
	while true do
		wait(4)
		local playerCar = getCarCharIsUsing(PLAYER_PED)
		if playerCar ~= -1 and readMemory(0xBAA420,1,false) > 1 then
			local posx,posy,posz = getCharCoordinates(PLAYER_PED)
			local AllVehicles = getAllVehicles()
			for i=0,#AllVehicles do
				if checkVehicle(AllVehicles[i])then
					if checkModels(getCarModel(AllVehicles[i]))then
						if locateCar2d(AllVehicles[i],posx,posy,30.0,30.0,false) then
							global_cop_spike = AllVehicles[i]
							for t=0,3 do fixCarTire(global_cop_spike,t) end
							setCanBurstCarTires(global_cop_spike,false)
							local alcance = 1.0
							local spike_count = 0
							while checkVehicle(global_cop_spike) and readMemory(0xBAA420,1,false) > 1 do
								if alcance <= 30.0 then alcance = alcance + 2.25 else alcance = 1.0 end
								local offx,offy,offz = getOffsetFromCarInWorldCoords(playerCar,0.0,alcance,0.0)
								setCarCruiseSpeed(global_cop_spike,30)
								carGotoCoordinates(global_cop_spike,offx,offy,offz)
								local radius_size = 16
								if locateCar2d(global_cop_spike,offx,offy,4.0,4.0,false) then
									playerActiveTrap(global_cop_spike,0.70)
									AllVehicles = {}
									local ped = getDriverOfCar(global_cop_spike)
									if doesCharExist(ped) then
										markCharAsNoLongerNeeded(ped)
									end
									markCarAsNoLongerNeeded(global_cop_spike)
									global_cop_spike = -1
									break
								end
								wait(4)
							end
						end
					end
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------
function checkVehicle(veh)
	local posx,posy,posz = getCharCoordinates(PLAYER_PED)
	if doesVehicleExist(veh) then
		if locateCar2d(veh,posx,posy,30.0,30.0,false) then
			local ped = getDriverOfCar(veh)
			if doesCharExist(ped) and not isCarDead(veh)then
				if not isCharDead(ped)then return true end
			end
		end
	end
	return false
end
-- end
