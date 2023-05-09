
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.
chat_queue := class:
    var TextArray : []?text_block = array{ false, false, false, false, false, false, false, false, false, false, false, false, false }
    var QueueSize : int = 0
    Enqueue( InTextBlock : text_block) : void =
        for (Index -> TextBlck : TextArray):
            # Check if there is no Text Block in the current slot
            if (not TextBlck?):
                if (set TextArray[Index] = option{ InTextBlock }):
                    Print("Enqueed New Chat Device at Position {Index}")
                    set QueueSize += 1
                    return

    # Removes the First Element from the array
    Pop() : text_block =
        var BlockRemoved : text_block = text_block{}

        if (set BlockRemoved = TextArray[0]?, RemainingHudsInQueue := TextArray.RemoveElement[0]):
            set TextArray = RemainingHudsInQueue
            FreeSlot : ?text_block = false
            set TextArray += array{ FreeSlot }
            set QueueSize -= 1
        return BlockRemoved

    GetQueueSize() : int =
        return QueueSize

chat_engine := class:
    ChatQueue : chat_queue = chat_queue{}
    ChatStackWidget : stack_box = stack_box{ Orientation := orientation.Vertical }
    ChatCanvas : canvas = canvas{}

    Init(Players : []player) : void =
        ChatCanvas.AddWidget(canvas_slot{
            Anchors := anchors {Minimum := vector2{ X := 0.7, Y := 0.1}  , Maximum := vector2{ X := 0.7, Y := 0.1}}
            Alignment := vector2{ X := 0.0, Y := 0.0}
            Widget := ChatStackWidget
        })
        for (Player : Players, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(ChatCanvas)

    AddTextChat( NewChatBlock : text_block ) : void =
        ChatQueue.Enqueue( NewChatBlock )
        ChatStackWidget.AddWidget( stack_box_slot{
            Widget := NewChatBlock
            HorizontalAlignment := horizontal_alignment.Fill
        })

    DeleteTextChat() : void =
        ByeByeBlock := ChatQueue.Pop()
        ChatStackWidget.RemoveWidget(ByeByeBlock)

    UpdateChat()<suspends> : void =
        loop:
            Sleep(5.0)
            NumberOfChats := ChatQueue.GetQueueSize()
            if (NumberOfChats > 0):
                DeleteTextChat()

    
    DisplayChat()<suspends> : void =
        {}


# A Verse-authored creative device that can be placed in a level
real_text_chat_device := class(creative_device):

    # ClockThing : custom_clock_device = custom_clock_device{}
    @editable
    Button : button_device = button_device{}

    ChatEngine : chat_engine = chat_engine{}
    
    var Players : []player = array{}
    var PlayersToKeyboard : [player]canvas = map{}
    var PlayersToTextInput : [player]text_block = map{}
    var PlayersToNames : [player]string = map{}

    UITextMessage<localizes>(Value : string) : message = "{Value}"

    LetterButtons : []button_loud = array{}
    EnterButton : button_loud = button_loud{}
    BackSpaceButton : button_loud = button_loud{}
    ExitButton : button_loud = button_loud{}
    ClearTextButton : button_loud = button_loud{}
    SpaceButton : button_loud = button_loud{}

    ColorBlock :color_block = color_block{ DefaultColor := NamedColors.Grey }

    LettersOfTheAlphabet : string = "QWERTYUIOPASDFGHJKLZXCVBNM"

    GetPlayerName(Player : player) : void =
        if (PlayerUI := GetPlayerUI[Player]):
            

    CreateKeyboard( Player : player ) : canvas = 
        KeyboardCanvas : canvas = canvas{}

        var XOffset : float = 0.0
        var YOffset : float = 0.0
        for (Letter : LettersOfTheAlphabet):
            Print("Creating Letter: {Letter}")
            if ("{Letter}" = "A" or "{Letter}" = "Z"):
                set XOffset = 0.0
                set YOffset += 0.06
            LetterButton : button_loud = button_loud{ DefaultText := UITextMessage("{Letter}")}
            LetterButton.OnClick().Subscribe(HandleLetterPressed)
            KeyboardCanvas.AddWidget(canvas_slot{
                Anchors := anchors {Minimum:= vector2{ X := 0.2 + XOffset, Y := 0.4 + YOffset}, Maximum := vector2 { X := 0.2 + XOffset, Y :=  0.4 + YOffset} }
                Widget := LetterButton
            })
            
            set XOffset += 0.041
        #Add Space Button
        SpaceButton.SetText(UITextMessage("[_]"))
        KeyboardCanvas.AddWidget(canvas_slot{
            Anchors := anchors{ Minimum:= vector2{ X := 0.3, Y := 0.62}, Maximum := vector2 { X := 0.45, Y :=  0.62 }}
            Widget := SpaceButton
        })
        # Add Color block (Text input) to Canvas
        KeyboardCanvas.AddWidget(canvas_slot{
            Anchors := anchors{ Minimum:= vector2{ X := 0.2, Y := 0.28}, Maximum := vector2 { X := 0.70, Y :=  0.32 }}
            Widget := ColorBlock
        })

        # Add Text  Input widget to Canvas
        if (TexBlock := PlayersToTextInput[Player]):
            KeyboardCanvas.AddWidget(canvas_slot{
                Anchors := anchors{ Minimum:= vector2{ X := 0.22, Y := 0.3}, Maximum := vector2 { X := 0.22 , Y :=  0.3}}
                Alignment := vector2{ X := 0.0, Y := 0.5}
                Widget := TexBlock
                SizeToContent := true
            })

        

        # Add Backspace Button
        BackSpaceButton.SetText(UITextMessage("<-"))      
        KeyboardCanvas.AddWidget(canvas_slot{
            Anchors := anchors{ Minimum:= vector2{ X := 0.62, Y := 0.4}, Maximum := vector2 { X := 0.7, Y :=  0.4 }}
            Widget := BackSpaceButton
        })

        # Add Enter Button
        EnterButton.SetText(UITextMessage("Enter"))
        KeyboardCanvas.AddWidget(canvas_slot{
            Anchors := anchors{ Minimum:= vector2{ X := 0.62, Y := 0.45}, Maximum := vector2 { X := 0.7, Y :=  0.45 }}
            Widget := EnterButton
        })
        # Add Exit Button
        ExitButton.SetText(UITextMessage("Exit"))
        KeyboardCanvas.AddWidget(canvas_slot{
            Anchors := anchors{ Minimum:= vector2{ X := 0.11, Y := 0.4}, Maximum := vector2 { X := 0.11, Y :=  0.4 }}
            Widget := ExitButton
        })

        #Add Clear Button
        ClearTextButton.SetText(UITextMessage("Clear"))
        KeyboardCanvas.AddWidget(canvas_slot{
            Anchors := anchors{ Minimum:= vector2{ X := 0.11, Y := 0.45}, Maximum := vector2 { X := 0.11, Y :=  0.45 }}
            Widget := ClearTextButton
        })


        # Bind Action Button to Handlers
        SpaceButton.OnClick().Subscribe(HandleLetterPressed)
        BackSpaceButton.OnClick().Subscribe(HandleActionButtonsPressed)
        EnterButton.OnClick().Subscribe(HandleActionButtonsPressed)
        ExitButton.OnClick().Subscribe(HandleActionButtonsPressed)
        ClearTextButton.OnClick().Subscribe(HandleActionButtonsPressed)

        return KeyboardCanvas

    HandleLetterPressed( Widget : widget_message ) : void =
        if (Btn := button_loud[Widget.Source], Player := Widget.Player, PlayerInput := PlayersToTextInput[Player]):
            Text := Btn.GetText()
            Print("Doing the COngo, and your letter is {Text}")
            UpdateTextBlock(PlayerInput, Text)
            
    HandleActionButtonsPressed ( Widget : widget_message ) : void =

        PlayerWhoClicked := Widget.Player

        # Get the button pressed, as well as the player who sent's text input field
        if (BtnLoud := button_loud[Widget.Source], TextInput := PlayersToTextInput[PlayerWhoClicked]):
            ActionButtonText := BtnLoud.GetText()
            # Exit Keyboard UI 
            if (ActionButtonText = "Exit"):
                ExitKeyboard(PlayerWhoClicked)

            # Enter Button Action
            if (ActionButtonText = "Enter"):
                # Send the text message, then clear the input field
                NewMessage := TextInput.GetText()
                # CurrentTime := ClockThing.GetTimeString()
                Print(NewMessage)

                #NewChatBlock := text_block{ DefaultText := UITextMessage("{CurrentTime} : {NewMessage}")}
                NewChatBlock := text_block{ DefaultText := UITextMessage("{NewMessage}")}
                ChatEngine.AddTextChat(NewChatBlock)

                ClearInputField(TextInput)

            if (ActionButtonText = "<-"):
                DeleteCharacter(TextInput)

            if (ActionButtonText = "Clear Text"):
                ClearInputField(TextInput)

    ExitKeyboard( Player : player ) : void =
        if (PlayerUI := GetPlayerUI[Player], PlayerKeyboard := PlayersToKeyboard[Player]):
            PlayerUI.RemoveWidget(PlayerKeyboard)

    DisplayKeybaord( Agent : agent) : void = 
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player], Keyboard := PlayersToKeyboard[Player]):
            PlayerUI.AddWidget(Keyboard, player_ui_slot{InputMode := ui_input_mode.All})

    DeleteCharacter ( TxtBlock : text_block ) : void =
        CurrentText : string = TxtBlock.GetText()
        # Removes last element of the string
        if (NewText := CurrentText.RemoveElement[CurrentText.Length - 1]):
            TxtBlock.SetText(UITextMessage("{NewText}"))

    ClearInputField ( TxtBlock : text_block ) : void =
        TxtBlock.SetText(UITextMessage(""))

    UpdateTextBlock( TxtBlock : text_block, NewLetter : string ) : void = 
        CurrentText : string = TxtBlock.GetText()

        if (CurrentText.Length > 40):
            return

        # Add a space lol
        if (NewLetter = "[_]"):
            TxtBlock.SetText(UITextMessage("{CurrentText} "))
            return 
        TxtBlock.SetText(UITextMessage(CurrentText + NewLetter))


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        

        Button.InteractedWithEvent.Subscribe(DisplayKeybaord)
        set Players = GetPlayspace().GetPlayers()
        ChatEngine.Init(Players)

        for (Player : Players, set PlayersToTextInput[Player] = text_block{ DefaultTextColor := NamedColors.White}):
            Keyboard := CreateKeyboard(Player)
            if (set PlayersToKeyboard[Player] = Keyboard) {}
        sync:
            ChatEngine.UpdateChat()
            Sleep(1.0)
            #ClockThing.ClockTick()
