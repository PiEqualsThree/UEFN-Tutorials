using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

aimbot_device := class(creative_device):

    @editable
    GuardSpawner : guard_spawner_device = guard_spawner_device{}
    var Targets : []fort_character = array{}
    var IsCrouched : logic = false

    (FortCharacter : fort_character).FindNearestTarget()<transacts><decides> : fort_character =
        var MaybeTarget : ?fort_character = false
        var NearestLocation : float = 1000000.0
        for (Target : Targets):
            if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FortCharacter.GetTransform().Translation) < NearestLocation):
                set MaybeTarget = option{Target}
                set NearestLocation = DistancePlayerToTarget

        return MaybeTarget?

    (FortCharacter : fort_character).FaceTarget(Target : fort_character)<suspends> : void =
        TargetLocation := Target.GetTransform().Translation + Target.GetTransform().Rotation.GetLocalUp() * -25.0
        PlayerLocation := FortCharacter.GetTransform().Translation

        if (LookDirection := (TargetLocation - PlayerLocation + FortCharacter.GetViewRotation().GetLocalUp() * 25.0).MakeUnitVector[]):

            Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
            NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, 0.0, 0.0)
            if (FortCharacter.TeleportTo[PlayerLocation, NewRotation]):
                #Print("BBB")

    HandleGuardSpawned(Agent : agent) : void =
        if (FortCharacter := Agent.GetFortCharacter[]):
            set Targets += array{FortCharacter}

    HandleGuardEliminated(Result : device_ai_interaction_result) : void =
        if:
            EliminatedGuard := Result.Target?
            FortGuard := EliminatedGuard.GetFortCharacter[]
            IndexInArray := Targets.Find[FortGuard]
            set Targets = Targets.RemoveElement[IndexInArray]
        then:
            #Print("Removed eliminated guard from array!")

    OnBegin<override>()<suspends> : void =
        GuardSpawner.SpawnedEvent.Subscribe(HandleGuardSpawned)
        GuardSpawner.EliminatedEvent.Subscribe(HandleGuardEliminated)
        
        if (FortCharacter := GetPlayspace().GetPlayers()[0].GetFortCharacter[]):
            branch:
                Result := FortCharacter.CrouchedEvent().Await()
                set IsCrouched = Result(1)

            loop:
                # Player has crouched!
                if (not IsCrouched?, Target := FortCharacter.FindNearestTarget[], Targets.Length > 0):
                    #Print("Player has crouched and has a target!")
                    race:
                        block:
                            loop:
                                if (not Target.IsActive[]):
                                    break
                                Sleep(0.0)
                                FortCharacter.FaceTarget(Target)
                        block:
                            FortCharacter.CrouchedEvent().Await()
                            set IsCrouched = false
                            #Print("Player has uncrouched!")
                else:
                    Sleep(0.2)

