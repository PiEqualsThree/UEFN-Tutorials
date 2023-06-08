
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
    RunningSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable
    IdleSequence : cinematic_sequence_device = cinematic_sequence_device{}
    
    DistanceAllowedNearPlayer : float = 600.0
    var IsAlreadyPlayingRunning : logic = false
    var IsAlreadyPlayingIdle : logic = false
 
    @editable
    SpawnEgg : signal_remote_manager_device = signal_remote_manager_device{}

    # @editable
    # DebbyAsset : creative_prop_asset = DefaultCreativePropAsset
    @editable
    FreddyProp : creative_prop = creative_prop{}
    
    # SpawnDebby( Agent : agent ) : void =
    #     if (FortCharacter := Agent.GetFortCharacter[]):
    #         PlayerPos := FortCharacter.GetTransform().Translation
    #         PlayerForward := FortCharacter.GetViewRotation().GetLocalForward() * 300.0
    #         DebbySpawnPos := PlayerPos + PlayerForward
            
    #         Result := SpawnProp(DebbyAsset, DebbySpawnPos, rotation{})
    #         if (SpawnedProp := Result(0)?):
    #             spawn:
    #                 PetFollowsPlayer(FortCharacter, SpawnedProp)
    StartFollowingPlayer( Agnet : agent ) : void =
        if ( Fort := Agnet.GetFortCharacter[]):
            RunningSequence.Play()
            set IsAlreadyPlayingRunning = true
            spawn:
                PetFollowsPlayer(Fort, FreddyProp)      

    PetFollowsPlayer( FortniteCharacter : fort_character, CreativeProp : creative_prop)<suspends> : void =
        loop:
            Sleep(0.0)
            PlayerPos := FortniteCharacter.GetTransform().Translation
            DebbyPos := CreativeProp.GetTransform().Translation
            DistanceFromPlayer := Distance(PlayerPos, DebbyPos)
            PlayerRight := FortniteCharacter.GetTransform().Rotation.GetLocalRight()

            DirectionFreddyToPlayer := PlayerPos - DebbyPos

            Angle := ArcTan(DirectionFreddyToPlayer.X, DirectionFreddyToPlayer.Y) - 3.14 / 2.0

            NewRotation := MakeRotation( vector3{ X := 0.0, Y := 0.0, Z := -1.0} , Angle) 
            NoJumpPlayerPos := vector3{ X := PlayerPos.X + PlayerRight.X * DistanceAllowedNearPlayer * 0.65, Y := PlayerPos.Y + PlayerRight.Y * DistanceAllowedNearPlayer * 0.65, Z := 80.0}

            if (DistanceFromPlayer > DistanceAllowedNearPlayer):
                Time := DistanceFromPlayer / 450.0
                CreativeProp.MoveTo(NoJumpPlayerPos, NewRotation, Time)
                if (not IsAlreadyPlayingRunning?):
                    IdleSequence.Stop()
                    RunningSequence.Play()
                    set IsAlreadyPlayingRunning = true
                    set IsAlreadyPlayingIdle = false
            else:
                if (not IsAlreadyPlayingIdle?):
                    RunningSequence.Stop()
                    IdleSequence.Play()
                    set IsAlreadyPlayingIdle = true
                    set IsAlreadyPlayingRunning = false
            
                
    OnBegin<override>()<suspends>:void=
        set Players = GetPlayspace().GetPlayers()
        
        SpawnEgg.PrimarySignalEvent.Subscribe(StartFollowingPlayer)
        SpawnEgg.SecondarySignalEvent.Subscribe(StartFollowingPlayer)
