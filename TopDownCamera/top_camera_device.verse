using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }

using { /Verse.org/Simulation }

using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
top_camera_device := class(creative_device):

    @editable
    CameraContainer : creative_prop = creative_prop{}

    var Players : []player = array{}

    MoveCamera()<suspends> : void =
        if (Player := Players[0], FortCharacter := Player.GetFortCharacter[]):
            PlayerPosition := FortCharacter.GetTransform().Translation
            CameraPosition := CameraContainer.GetTransform().Translation

            DirectionCameraToPlayer := PlayerPosition - CameraPosition

            Angle := ArcTan(DirectionCameraToPlayer.X, DirectionCameraToPlayer.Y) - 3.14 / 2.0

            NewRotation := MakeRotation( vector3{ X := 0.0, Y := 0.0, Z := -1.0} , Angle)

            Result := CameraContainer.MoveTo(PlayerPosition, NewRotation, 0.4)
            if ( Result = move_to_result.DestinationReached):
                MoveCamera()

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        set Players = GetPlayspace().GetPlayers()
        MoveCamera()
