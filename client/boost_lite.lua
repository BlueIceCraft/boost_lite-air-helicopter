land_vehicles = {}
air_vehicles= {}
function AddVehicle(id)
	land_vehicles[id] = true
end
AddVehicle(3)
AddVehicle(14)
AddVehicle(37)
AddVehicle(57)
AddVehicle(62)
AddVehicle(64)
AddVehicle(65)
AddVehicle(67)




local timer = Timer()
local nos_enabled = true

function InputEvent( args )
	if window_open then
		return false
	end

	if not nos_enabled then return true end

	if LocalPlayer:InVehicle() and 
		LocalPlayer:GetState() == PlayerState.InVehicle and 
		IsValid(LocalPlayer:GetVehicle()) and
		timer:GetSeconds() > 0.2 and 
		LocalPlayer:GetWorld() == DefaultWorld and
		land_vehicles[LocalPlayer:GetVehicle():GetModelId()] then
		
		if Game:GetSetting( GameSetting.GamepadInUse ) == 1 then
			if args.input == Action.VehicleFireLeft then
				Network:Send("Boost", true)
				timer:Restart()
			end
		else
			if Key:IsDown(81) then
				Network:Send("Boost", true)
				timer:Restart()
			end
		end

	end
end

function RenderEvent()
	if not nos_enabled then return end
	if LocalPlayer:InVehicle() and LocalPlayer:GetState() ~= PlayerState.InVehicle then return end
	if not IsValid(LocalPlayer:GetVehicle()) then return end
	if land_vehicles[LocalPlayer:GetVehicle():GetModelId()] == nil then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	local boost_text = "Boost(Air) Lite - /boost to toggle"
	local boost_size = Render:GetTextSize( boost_text )

	local boost_pos = Vector2( 
		(Render.Width - boost_size.x)/2, 
		Render.Height - boost_size.y )

	Render:DrawText( boost_pos, boost_text, Color( 255, 255, 255 ) )
end

function LocalPlayerChat( args )
	if args.text == "/boost" then
		SetWindowOpen( not GetWindowOpen() )
	end
end

function CreateSettings()
    window_open = false

    window = Window.Create()
    window:SetSize( Vector2( 300, 100 ) )
    window:SetPosition( (Render.Size - window:GetSize())/2 )

    window:SetTitle( "Boost Settings" )
    window:SetVisible( window_open )
    window:Subscribe( "WindowClosed", function() SetWindowOpen( false ) end )

    local enabled_checkbox = LabeledCheckBox.Create( window )
    enabled_checkbox:SetSize( Vector2( 300, 20 ) )
    enabled_checkbox:SetDock( GwenPosition.Top )
    enabled_checkbox:GetLabel():SetText( "Enabled" )
    enabled_checkbox:GetCheckBox():SetChecked( nos_enabled )
    enabled_checkbox:GetCheckBox():Subscribe( "CheckChanged", 
        function() nos_enabled = enabled_checkbox:GetCheckBox():GetChecked() end )
end

function GetWindowOpen()
    return window_open
end

function SetWindowOpen( state )
    window_open = state
    window:SetVisible( window_open )
    Mouse:SetVisible( window_open )
end

function ModulesLoad()
	Events:FireRegisteredEvent( "HelpAddItem",
        {
            name = "Boost",
            text = 
                "The boost lets you increase the speed of your car/boat.\n\n" ..
                "To use it, tap Shift on a keyboard, or the LB button " ..
                "on controllers.\n\n" ..
                "To disable the script, type /boost into chat."
        } )
end

function ModuleUnload()
    Events:FireRegisteredEvent( "HelpRemoveItem",
        {
            name = "Boost"
        } )
end

CreateSettings()

Events:Subscribe("LocalPlayerChat", LocalPlayerChat)
Events:Subscribe("Render", RenderEvent)
Events:Subscribe("LocalPlayerInput", InputEvent)
Events:Subscribe("ModulesLoad", ModulesLoad)
Events:Subscribe("ModuleUnload", ModuleUnload)