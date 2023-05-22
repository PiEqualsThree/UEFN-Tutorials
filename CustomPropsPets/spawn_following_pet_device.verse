
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
spawn_pet_device := class(creative_device):
    var Players : []player = array{}
    @editable
    SpawnEgg : signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    DebbyAsset : creative_prop_asset = DefaultCreativePropAsset
    
    SpawnDebby( Agent : agent ) : void =
        if (FortCharacter := Agent.GetFortCharacter[]):
            PlayerPos := FortCharacter.GetTransform().Translation
            PlayerForward := FortCharacter.GetViewRotation().GetLocalForward() * 300.0
            DebbySpawnPos := PlayerPos + PlayerForward
            
            Result := SpawnProp(DebbyAsset, DebbySpawnPos, rotation{})
            if (SpawnedProp := Result(0)?):
                spawn:
                    PetFollowsPlayer(FortCharacter, SpawnedProp)
                    
    PetFollowsPlayer( FortniteCharacter : fort_character, CreativeProp : creative_prop)<suspends> : void =
        loop:
            Sleep(0.0)
            PlayerPos := FortniteCharacter.GetTransform().Translation
            DebbyPos := CreativeProp.GetTransform().Translation

            DistanceFromPlayer := Distance(PlayerPos, DebbyPos)
            Time := DistanceFromPlayer / 900.0
            CreativeProp.MoveTo(PlayerPos, rotation{}, Time)

    OnBegin<override>()<suspends>:void=
        set Players = GetPlayspace().GetPlayers()
        SpawnEgg.PrimarySignalEvent.Subscribe(SpawnDebby)
        SpawnEgg.SecondarySignalEvent.Subscribe(SpawnDebby)
