
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
exploding_vehicle_speed_device := class(creative_device):

    @editable
    Car : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}
    @editable
    Bomb : explosive_device = explosive_device{}
    @editable
    DummyProp : creative_prop = creative_prop{}

    var LastPosition : vector3 = vector3{}
    var CurrentPosition : vector3 = vector3{}
    var Speed : float = 0.0
    var VehicleIsAlive : logic = true


    YaBetterStartDriving ( Agent : agent ) : void =
        Print("You better start driving!")
        set VehicleIsAlive = true
        spawn:
            BlowUPIfBelowSpeed(Agent)
            
    BombFollowPlayer(FortCharacter : fort_character ) : void =
        if (DummyProp.TeleportTo[FortCharacter.GetTransform().Translation, rotation{}]) {}

    

    BlowUPIfBelowSpeed( Agent : agent)<suspends> : void =
        Sleep(5.0)
        loop:
            if (VehicleIsAlive = false):    
                break
            if ( FortCharacter := Agent.GetFortCharacter[]):
                set Speed = GetSpeed(FortCharacter)
                BombFollowPlayer(FortCharacter)
                Print("You are going at {Speed} Km / Hour")
                if (Speed < 40.0):
                    Bomb.Explode(Agent)
                    Print("You went kaboom!")
                    set VehicleIsAlive = false

    GetSpeed( FortCharacter : fort_character )<suspends> : float =
        set LastPosition = CurrentPosition
        Sleep(0.2)
        set CurrentPosition = FortCharacter.GetTransform().Translation

        PlayerDistance := DistanceXY(CurrentPosition, LastPosition)

        SpeedKMH := 3.6 * ((PlayerDistance / 0.2) / 100.0)

        return SpeedKMH

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        Car.AgentEntersVehicleEvent.Subscribe(YaBetterStartDriving)