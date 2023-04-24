
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
remote_signal_dostuff_device := class(creative_device):

    @editable
    SignalRemoteGrey : signal_remote_manager_device = signal_remote_manager_device{}


    HandlePrimaryButton( P : agent) : void =
        if (F := P.GetFortCharacter[]):
            F.Hide()

    HandleSecondaryButton( P : agent) : void =
        if (f := P.GetFortCharacter[]):
            f.Show()

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        SignalRemoteGrey.PrimarySignalEvent.Subscribe(HandlePrimaryButton)
        SignalRemoteGrey.SecondarySignalEvent.Subscribe(HandleSecondaryButton)

        # TODO: Replace this with your code
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")
