
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
life_steal_device := class(creative_device):

    HealAttacker( Result : damage_result) : void =
        Amount := Result.Amount
        if (Instigator := Result.Instigator?, Agent := Instigator.GetInstigatorAgent[], FortCharacter := Agent.GetFortCharacter[]):
            HealAmount := Amount * 0.14
            FortCharacter.Heal(HealAmount)
            Print("Healed for Amount")
    HandlePlayerJoin ( Player : player ) : void =
        if (FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(HealAttacker)
            
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(HealAttacker)
        GetPlayspace().PlayerAddedEvent().Subscribe(HandlePlayerJoin)
        
