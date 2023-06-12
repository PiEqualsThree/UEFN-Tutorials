
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
custom_model_device := class(creative_device):

    @editable
    FreddyProp : creative_prop = creative_prop{}
    @editable
    Mutator : mutator_zone_device = mutator_zone_device{}
    @editable
    RunningCinematic : cinematic_sequence_device = cinematic_sequence_device{}

    var IsCinematicPlaying : logic = false

    UpdateModel ( Agent : agent )<suspends> : void =
        if (FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.Hide()
            
            branch:
                loop:
                    Sleep(0.0)
                    PlayerPos := FortCharacter.GetTransform().Translation
                    FreddyPos := FreddyProp.GetTransform().Translation

                    DistanceFromPlayer := Distance(PlayerPos, FreddyPos)
                    
                    DirectionFreddyToPlayer := PlayerPos - FreddyPos

                    Angle := ArcTan(DirectionFreddyToPlayer.X, DirectionFreddyToPlayer.Y) - 3.14 / 2.0

                    NewRotation := MakeRotation( vector3{ X := 0.0, Y := 0.0, Z := -1.0} , Angle) 

                    FreddyProp.MoveTo(PlayerPos, NewRotation, 0.15)
            
            loop:
                Sleep(0.0)
                IsSprintingTuple := FortCharacter.SprintedEvent().Await()
                if (IsSprintingTuple(1)?):
                    RunningCinematic.Play()
                else:
                    RunningCinematic.Stop()

    HandleAgentTrigger ( Agent : agent ) : void =
        spawn:
            UpdateModel(Agent)
    HandlePlayerSprint( Agent : agent ) : void =
        {}
    OnBegin<override>()<suspends>:void=
        Mutator.AgentEntersEvent.Subscribe(HandleAgentTrigger)
        
