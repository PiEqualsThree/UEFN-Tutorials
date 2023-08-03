
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
# A Verse-authored creative device that can be placed in a level
custom_vehicle_device := class(creative_device):

    @editable
    HotDog : creative_prop = creative_prop{}
    @editable
    UFO : vehicle_spawner_ufo_device = vehicle_spawner_ufo_device {}

    var PlayerList : []player = array{}

    var IsUFOPiloted : logic = false
    var SleepTime : float = 5.0
    
    HandleEnterUFO(Agent : agent) : void =
        set IsUFOPiloted = true
        set SleepTime = 0.01

    HandleExitUFO( Agent : agent ) : void =
        set IsUFOPiloted = false
        set SleepTime = 5.0

    DoHotDogFollowUFO()<suspends> : void =
        loop:
            Sleep(SleepTime)
            if (IsUFOPiloted?):
                if (FortCharacter := PlayerList[0].GetFortCharacter[] ):
                    PlayerPosition : vector3 = FortCharacter.GetTransform().Translation
                    PlayerDirectionFace : rotation = FortCharacter.GetViewRotation()
                    PlayerFrontVector : vector3 = PlayerDirectionFace.GetLocalForward()

                    if (HotDog.TeleportTo[PlayerPosition + 500.0 * PlayerFrontVector, PlayerDirectionFace]) {}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        set PlayerList = GetPlayspace().GetPlayers()

        UFO.AgentEntersVehicleEvent.Subscribe(HandleEnterUFO)
        UFO.AgentExitsVehicleEvent.Subscribe(HandleExitUFO)
        DoHotDogFollowUFO()
