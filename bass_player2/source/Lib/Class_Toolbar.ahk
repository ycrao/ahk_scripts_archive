;=======================================================================================
;
;                    Class Toolbar
;
; Author:            Pulover [Rodolfo U. Batista]
;                    rodolfoub@gmail.com
; AHK version:       1.1.11.00
; Release date:      29 June 2013
;
;                    Class for AutoHotkey Toolbar custom controls
;=======================================================================================
;
; This class provides intuitive methods to work with toolbar controls created via
;    Gui, Add, Custom, ClassToolbarWindow32.
;
;=======================================================================================
;
; Methods:
;    AutoSize()
;    Add([Options, Label1[=Text]:Icon, Label2[=Text]:Icon, Label3[=Text]:Icon...])
;    Insert(Position [, Options, Label1[=Text]:Icon, Label2[=Text]:Icon...])
;    Delete(Button)
;    Move([X, Y])
;    ModifyButton(Button, State [, Set])
;    ModifyButtonInfo(Button, Parameter, Value)
;    MoveButton(Button, Target)
;    SetButtonSize(W, H)
;    SetImageList(hImageList)
;    SetHotItem(Button)
;    SetRows([Rows, AddMore])
;    SetMaxTextRows([MaxRows])
;    SetIndent(Value)
;    SetListGap(Value)
;    SetPadding(X, Y)
;    SetExStyle(Options)
;    ToggleStyle(Options)
;    Get([BtnCount, HotItem, TextRows, Rows, BtnWidth, BtnHeight, Style, ExStyle])
;    GetButton(Button)
;    GetCount()
;    GetButtonPos(Button [, OutX, OutY, OutW, OutH])
;    Customize()
;    Save()
;    Reset()
;    SetDefault([Options, Label1[=Text]:Icon, Label2[=Text]:Icon, Label3[=Text]:Icon...])
;    OnMessage(CommandID)
;    OnNotify(Param [, MenuXPos, MenuYPos, Label, ID, AllowCustom])
;
;=======================================================================================
Class Toolbar extends Toolbar.Private
{
;=======================================================================================
;    Method:             AutoSize
;    Description:        Auto-sizes toolbar.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    AutoSize()
    {
        PostMessage, this.TB_AUTOSIZE, 0, 0,, % "ahk_id " this.tbHwnd
        return ErrorLevel ? False : True
    }
;=======================================================================================
;    Method:             Add
;    Description:        Add button(s) to the end the toolbar. The Buttons parameters
;                            sets target Label, text caption and icon index for each
;                            button.
;                        To add a separator call this method without parameters.
;                        Prepend any non letter or digit symbol, such as "-" or "*"
;                            to the label to add a hidden button. Hidden buttons won't
;                            be visible when Gui is shown but will still be available
;                            in the customize window. E.g.: "-Label=New:1", "*Label:2".
;                        You include specific states and styles for a button appending
;                            them inside parenthesis after the icon. E.g.:
;                            "Label=Text:3(Enabled Dropdown)".
;    Parameters:
;        Options:        Enter zero or more words, separated by space or tab, from the
;                            following list to set buttons' initial states and styles:
;                            Checked, Ellipses, Enabled, Hidden, Indeterminate, Marked,
;                            Pressed, Wrap, Button, Sep, Check, Group, CheckGroup,
;                            Dropdown, AutoSize, NoPrefix, ShowText, WholeDropdown.
;                        You can also set the minimum and maximum button width,
;                            for example W20-100 would set min to 20 and max to 100.
;                        This option affects all buttons in the toolbar when added or
;                            inserted but does not prevent modifying button sizes.
;                        If this parameter is blank it defaults to "Enabled", otherwise
;                            you must set this parameter to enable buttons.
;                        You may pass integer values that correspond to (a combination of)
;                            button styles. You cannot set states this way (it will always
;                            be set to "Enabled").
;        Buttons:        Buttons can be added in the following format: Label=Text:1,
;                            where "Label" is the target label to execute when the
;                            button is pressed, "Text" is caption to be displayed
;                            with the button or as a Tooltip if the toolbar has the
;                            TBSTYLE_TOOLTIPS style (this parameter can be omitted) and
;                            "1" can be any numeric value that represents the icon index
;                            in the ImageList (0 means no icon).
;                        To add a separator between buttons specify "" or equivalent.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Add(Options="Enabled", Buttons*)
    {
        If !Buttons.MaxIndex()
        {
            Struct := this.BtnSep(TBBUTTON), this.DefaultBtnInfo.Insert(Struct)
            SendMessage, this.TB_ADDBUTTONS, 1, &TBBUTTON,, % "ahk_id " this.tbHwnd
            If (ErrorLevel = "FAIL")
                return False
        }
        Else If (Options = "")
            Options := "Enabled"
        For each, Button in Buttons
        {
            If (RegExMatch(Button, "^(\W?)(\w+)[=\s]?(.*)?:(\d+)\(?(.*?)?\)?$", Key))
            {
                idCommand := this.StringToNumber(Key2)
            ,   iString := Key3, iBitmap := Key4
            ,   this.Labels[idCommand] := Key2
            ,   Struct := this.DefineBtnStruct(TBBUTTON, iBitmap, idCommand, iString, Key5 ? Key5 : Options)
            ,   this.DefaultBtnInfo.Insert(Struct)
                If (Key1)
                    continue
                SendMessage, this.TB_ADDBUTTONS, 1, &TBBUTTON,, % "ahk_id " this.tbHwnd
                If (ErrorLevel = "FAIL")
                    return False
            }
            Else
            {
                Struct := this.BtnSep(TBBUTTON), this.DefaultBtnInfo.Insert(Struct)
                SendMessage, this.TB_ADDBUTTONS, 1, &TBBUTTON,, % "ahk_id " this.tbHwnd
                If (ErrorLevel = "FAIL")
                    return False
            }
        }
        this.AutoSize()
        return True
    }
;=======================================================================================
;    Method:             Insert
;    Description:        Insert button(s) in specified postion.
;                        To insert a separator call this method without parameters.
;    Parameters:
;        Position:       1-based index of button position to insert the new buttons.
;        Options:        Same as Add().
;        Buttons:        Same as Add().
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Insert(Position, Options="Enabled", Buttons*)
    {
        If !Buttons.MaxIndex()
        {
            this.BtnSep(TBBUTTON)
            SendMessage, this.TB_INSERTBUTTON, Position-1, &TBBUTTON,, % "ahk_id " this.tbHwnd
            If (ErrorLevel = "FAIL")
                return False
        }
        Else If (Options = "")
            Options := "Enabled"
        For i, Button in Buttons
        {
            If (RegExMatch(Button, "(\W?)(\w+)[=\s]?(.*)?:(\d+)\(?(.*?)?\)?$", Key))
            {
                idCommand := this.StringToNumber(Key2)
            ,   iString := Key3, iBitmap := Key4
            ,   this.Labels[idCommand] := Key2
            ,   this.DefineBtnStruct(TBBUTTON, iBitmap, idCommand, iString, Key5 ? Key5 : Options)
                If (Key1)
                    continue
                SendMessage, this.TB_INSERTBUTTON, (Position-1)+(i-1), &TBBUTTON,, % "ahk_id " this.tbHwnd
                If (ErrorLevel = "FAIL")
                    return False
            }
            Else
            {
                this.BtnSep(TBBUTTON)
                SendMessage, this.TB_INSERTBUTTON, (Position-1)+(i-1), &TBBUTTON,, % "ahk_id " this.tbHwnd
                If (ErrorLevel = "FAIL")
                    return False
            }
        }
        return True
    }
;=======================================================================================
;    Method:             Delete
;    Description:        Delete one or all buttons.
;    Parameters:
;        Button:         1-based index of the button. If omitted deletes all buttons.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Delete(Button="")
    {
        If !Button
        {
            Loop, % this.GetCount()
                this.Delete(1)
        }
        Else
            SendMessage, this.TB_DELETEBUTTON, Button-1, 0,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             Move
;    Description:        Moves toolbar (required for correct positioning in Gui).
;    Parameters:
;        X:              X position in gui.
;        Y:              Y position in gui.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Move(X="", Y="")
    {
        Loop, 10
            ControlMove,, %X%, %Y%,,, % "ahk_id " this.tbHwnd
        return ErrorLevel ? False : True
    }
;=======================================================================================
;    Method:             ModifyButton
;    Description:        Sets button states.
;    Parameters:
;        Button:         1-based index of the button.
;        State:          Enter one word from the follwing list to change a button's
;                            state: Check, Enable, Hide, Mark, Press.
;        Set:            Enter TRUE or FALSE to set the state on/off.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    ModifyButton(Button, State, Set=True)
    {
        If State not in CHECK,ENABLE,HIDE,MARK,PRESS
            return False
        Message := this[ "TB_" State "BUTTON"]
    ,   this.GetButton(Button, BtnID)
        SendMessage, Message, BtnID, Set,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             ModifyButtonInfo
;    Description:        Sets button parameters such as Icon and CommandID.
;    Parameters:
;        Button:         1-based index of the button.
;        Property:       Enter one word from the following list to select the Property
;                            to be set:
;                            Command, Image, Size, State, Style, Text.
;        Value:          The value to be set in the selected Property.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    ModifyButtonInfo(Button, Property, Value)
    {
        this.DefineBtnInfoStruct(TBBUTTONINFO, Property, Value)
    ,   this.GetButton(Button, BtnID)
        SendMessage, this.TB_SETBUTTONINFO, BtnID, &TBBUTTONINFO,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             MoveButton
;    Description:        Moves a toolbar button (change order).
;    Parameters:
;        Button:         1-based index of the button to be moved.
;        Target:         1-based index of the new position.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    MoveButton(Button, Target)
    {
        SendMessage, this.TB_MOVEBUTTON, Button-1, Target-1,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetButtonSize
;    Description:        Sets the size of buttons on a toolbar. Affects current buttons.
;    Parameters:
;        W:              Width of buttons, in pixels
;        H:              Height of buttons, in pixels
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetButtonSize(W, H)
    {
        Long := this.MakeLong(W, H)
        SendMessage, this.TB_SETBUTTONSIZE, 0, Long,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetImageList
;    Description:        Sets an ImageList.
;    Parameters:
;        hImageList:     ImageList ID
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetImageList(hImageList)
    {
        SendMessage, this.TB_SETIMAGELIST, 0, hImageList,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetHotItem
;    Description:        Sets the hot item on a toolbar.
;    Parameters:
;        Button:         1-based index of the button.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetHotItem(Button)
    {
        SendMessage, this.TB_SETHOTITEM, Button-1, 0,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetRows
;    Description:        Sets the number of rows for a toolbar.
;    Parameters:
;        Rows:           Number of rows to set. If omitted defaults to 0.
;        AddMore:        Indicates whether to create more rows than requested when the
;                            system cannot create the number of rows specified.
;                            If TRUE, the system creates more rows. If FALSE, the system
;                            creates fewer rows.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetRows(Rows=0, AddMore=False)
    {
        Long := this.MakeLong(Rows, AddMore)
        SendMessage, this.TB_SETROWS, Long,,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetMaxTextRows
;    Description:        Sets maximum number of text rows for button captions.
;    Parameters:
;        MaxRows:        Maximum number of text rows. If omitted defaults to 0.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetMaxTextRows(MaxRows=0)
    {
        SendMessage, this.TB_SETMAXTEXTROWS, MaxRows, 0,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetIndent
;    Description:        Sets the indentation for the first button on a toolbar.
;    Parameters:
;        Value:          Value specifying the indentation, in pixels.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetIndent(Value)
    {
        SendMessage, this.TB_SETINDENT, Value, 0,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetListGap
;    Description:        Sets the distance between icons and text on a toolbar.
;    Parameters:
;        Value:          The gap, in pixels, between buttons on the toolbar.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetListGap(Value)
    {
        SendMessage, this.TB_SETLISTGAP, Value, 0,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetPadding
;    Description:        Sets the padding for icons a toolbar. 
;    Parameters:
;        X:              Horizontal padding, in pixels
;        Y:              Vertical padding, in pixels
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetPadding(X, Y)
    {
        Long := this.MakeLong(X, Y)
        SendMessage, this.TB_SETPADDING, 0, Long,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetExStyle
;    Description:        Sets toolbar's extended style.
;    Parameters:
;        Options:        Enter zero or more words, separated by space or tab, from the
;                            following list to set toolbar's extended styles:
;                            Doublebuffer, DrawDDArrows, HideClippedButtons,
;                            MixedButtons.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetExStyle(Options)
    {
        Loop, Parse, Options, %A_Space%%A_Tab%
        {
            If (this[ "TBSTYLE_EX_" A_LoopField] )
                TBSTYLE_EX_ += this[ "TBSTYLE_EX_" A_LoopField ]
        }
        SendMessage, this.TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_,, % "ahk_id " this.tbHwnd
    }
;=======================================================================================
;    Method:             ToggleStyle
;    Description:        Toggles toolbar's style or extended style.
;    Parameters:
;        Options:        Enter zero or more words, separated by space or tab, from the
;                            following list to toggle toolbar's styles:
;                            AltDrag, CustomErase, Flat, List, RegisterDrop, Tooltips,
;                            Transparent, Wrapable, Adjustable, Border, ThickFrame,
;                            TabStop.
;    Return:             TRUE if a valid style is passed, FALSE otherwise.
;=======================================================================================
    ToggleStyle(Options)
    {
        Loop, Parse, Options, %A_Space%%A_Tab%
        {
            If (this[ "TBSTYLE_" A_LoopField] )
                TBSTYLE += this[ "TBSTYLE_" A_LoopField ]
        }
        ; TB_SETSTYLE moves the toolbar away from its position for some reason.
        ; SendMessage, this.TB_SETSTYLE, 0, TBSTYLE,, % "ahk_id " this.tbHwnd
        If (TBSTYLE <> "")
        {
            WinSet, Style, ^%TBSTYLE%, % "ahk_id " this.tbHwnd
            return True
        }
        Else
            return False
    }
;=======================================================================================
;    Method:             Get
;    Description:        Retrieves information from the toolbar.
;    Parameters:
;        HotItem:        OutputVar to store the 1-based index of current HotItem.
;        TextRows:       OutputVar to store the number of text rows
;        Rows:           OutputVar to store the number of rows for vertical toolbars.
;        BtnWidth:       OutputVar to store the buttons' width in pixels.
;        BtnHeight:      OutputVar to store the buttons' heigth in pixels.
;        Style:          OutputVar to store the current styles numeric value.
;        ExStyle:        OutputVar to store the current extended styles numeric value.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Get(ByRef HotItem="", ByRef TextRows="", ByRef Rows=""
    ,   ByRef BtnWidth="", ByRef BtnHeight="", ByRef Style="", ByRef ExStyle="")
    {
        SendMessage, this.TB_GETHOTITEM, 0, 0,, % "ahk_id " this.tbHwnd
            HotItem := (ErrorLevel = 4294967295) ? 0 : ErrorLevel+1
        SendMessage, this.TB_GETTEXTROWS, 0, 0,, % "ahk_id " this.tbHwnd
            TextRows := ErrorLevel
        SendMessage, this.TB_GETROWS, 0, 0,, % "ahk_id " this.tbHwnd
            Rows := ErrorLevel
        SendMessage, this.TB_GETBUTTONSIZE, 0, 0,, % "ahk_id " this.tbHwnd
            this.MakeShort(ErrorLevel, BtnWidth, BtnHeight)
        SendMessage, this.TB_GETSTYLE, 0, 0,, % "ahk_id " this.tbHwnd
            Style := ErrorLevel
        SendMessage, this.TB_GETEXTENDEDSTYLE, 0, 0,, % "ahk_id " this.tbHwnd
            ExStyle := ErrorLevel
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             GetButton
;    Description:        Retrieves information from the toolbar buttons.
;    Parameters:
;        Button:         1-based index of the button.
;        ID:             OutputVar to store the button's command ID.
;        Text:           OutputVar to store the button's text caption.
;        State:          OutputVar to store the button's state numeric value.
;        Style:          OutputVar to store the button's style numeric value.
;        Icon:           OutputVar to store the button's icon index.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    GetButton(Button, ByRef ID="", ByRef Text="", ByRef State="", ByRef Style="", ByRef Icon="")
    {
        VarSetCapacity(BtnVar, 8 + (A_PtrSize * 3), 0)
        SendMessage, this.TB_GETBUTTON, Button-1, &BtnVar,, % "ahk_id " this.tbHwnd
        ID := NumGet(&BtnVar+0, 4, "Int"), Icon := NumGet(&BtnVar+0, 0, "Int")+1
    ,   State := NumGet(&BtnVar+0, 8, "Char"), Style := NumGet(&BtnVar+0, 9, "Char")
        SendMessage, this.TB_GETBUTTONTEXT, ID, 0,, % "ahk_id " this.tbHwnd
        VarSetCapacity(Buffer, ErrorLevel * (A_IsUnicode ? 2 : 1), 0)
        SendMessage, this.TB_GETBUTTONTEXT, ID, &Buffer,, % "ahk_id " this.tbHwnd
        Text := StrGet(&Buffer)
        return (ErrorLevel = "FAIL") ? False : True
        ; Alternative way to retrieve the button state.
        ; SendMessage, this.TB_GETSTATE, ID, 0,, % "ahk_id " this.tbHwnd
        ; State := ErrorLevel
    }
;=======================================================================================
;    Method:             GetCount
;    Description:        Retrieves the total number of buttons.
;    Return:             The total number of buttons in the toolbar.
;=======================================================================================
    GetCount()
    {
        SendMessage, this.TB_BUTTONCOUNT, 0, 0,, % "ahk_id " this.tbHwnd
        return ErrorLevel
    }
;=======================================================================================
;    Method:             GetButtonPos
;    Description:        Retrieves position and size of a specific button, relative to
;                            the toolbar control.
;    Parameters:
;        Button:         1-based index of the button.
;        OutX:           OutputVar to store the button's horizontal position.
;        OutY:           OutputVar to store the button's vertical position.
;        OutW:           OutputVar to store the button's width.
;        OutH:           OutputVar to store the button's height.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    GetButtonPos(Button, ByRef OutX="", ByRef OutY="", ByRef OutW="", ByRef OutH="")
    {
        this.GetButton(Button, BtnID), VarSetCapacity(RECT, 16, 0)
        SendMessage, this.TB_GETRECT, BtnID, &RECT,, % "ahk_id " this.tbHwnd
        OutX := NumGet(&RECT, 0, "Int"), OutY := NumGet(&RECT, 4, "Int")
    ,   OutW := NumGet(&RECT, 8, "Int") - OutX, OutH := NumGet(&RECT, 12, "Int") - OutY
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             Customize
;    Description:        Displays the Customize Toolbar dialog box.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Customize()
    {
        SendMessage, this.TB_CUSTOMIZE, 0, 0,, % "ahk_id " this.tbHwnd
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             Save()
;    Description:        Returns a text string with current buttons and order in Add and
;                            Insert methods compatible format (this includes button's
;                            styles but not states). Duplicate labels are ignored.
;    ArrayOut:           Set to TRUE to return the string in an Array. To save arrays
;                            as text you need extract the values. Arrays can be passed
;                            to Add or Insert as a variadic parameters, for example:
;                            TB.Add("", ArrayOfButtons*).
;    HidMark:            Changes the default symbol to prepend to hidden buttons.
;    Return:             A text string with current buttons information to be saved.
;=======================================================================================
    Save(ArrayOut=False, HidMark="-")
    {
        BtnArray := [], IncLabels := ":"
        Loop, % this.GetCount()
        {
            this.GetButton(A_Index, ID, Text, "", Style, Icon)
        ,    Label := this.Labels[ID], IncLabels .= Label ":"
        ,    cString := (Label ? (Label (Text ? "=" Text : "")
                    .    ":" Icon (Style ? "(" Style ")" : "")) : "") ", "
        ,    BtnString .= cString
            If (ArrayOut)
                BtnArray.Insert(cString)
        }
        For i, Button in this.DefaultBtnInfo
        {
            If !InStr(IncLabels, ":" (Label := this.Labels[Button.ID]) ":")
            {
                oString := Label (Button.Text ? "=" Button.Text : "")
                        .    ":" Button.Icon+1 (Button.Style ? "(" Button.Style ")" : "")
                BtnString .= HidMark oString ", "
                If (ArrayOut)
                    BtnArray.Insert(HidMark oString)
            }
        }
        return ArrayOut ? BtnArray : RTrim(BtnString, ", ")
    }
;=======================================================================================
;    Method:             Reset
;    Description:        Restores all toolbar's buttons to default layout.
;                        Default layout is set by the buttons added. This can be changed
;                            calling the SetDefault method.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Reset()
    {
        Loop, % this.GetCount()
            this.Delete(1)
        For each, Button in this.DefaultBtnInfo
        {
            VarSetCapacity(TBBUTTON, 8 + (A_PtrSize * 3), 0)
        ,   NumPut(Button.Icon, TBBUTTON, 0, "Int")
        ,   NumPut(Button.ID, TBBUTTON, 4, "Int")
        ,   NumPut(Button.State, TBBUTTON, 8, "Char")
        ,   NumPut(Button.Style, TBBUTTON, 9, "Char")
        ,   NumPut(Button.Index, TBBUTTON, 8 + (A_PtrSize * 2), "Int")
            SendMessage, this.TB_ADDBUTTONS, 1, &TBBUTTON,, % "ahk_id " this.tbHwnd
        }
        return (ErrorLevel = "FAIL") ? False : True
    }
;=======================================================================================
;    Method:             SetDefault
;    Description:        Sets the internal default layout to be used when customizing or
;                        when the Reset method is called.
;    Parameters:
;        Options:        Same as Add().
;        Buttons:        Same as Add().
;    Return:             Always TRUE.
;=======================================================================================
    SetDefault(Options="Enabled", Buttons*)
    {
        this.DefaultBtnInfo := []
        If !Buttons.MaxIndex()
            this.DefaultBtnInfo.Insert({Icon: -1, ID: "", State: "", Style: this.BTNS_SEP, Index: "", Text: ""})
        If (Options = "")
            Options := "Enabled"
        For each, Button in Buttons
        {
            If (RegExMatch(Button, "^(\W?)(\w+)[=\s]?(.*)?:(\d+)\(?(.*?)?\)?$", Key))
            {
                idCommand := this.StringToNumber(Key2)
            ,   iString := Key3, iBitmap := Key4
            ,   this.Labels[idCommand] := Key2
            ,   Struct := this.DefineBtnStruct(TBBUTTON, iBitmap, idCommand, iString, Key5 ? Key5 : Options)
            ,   this.DefaultBtnInfo.Insert(Struct)
            }
            Else
                Struct := this.BtnSep(TBBUTTON), this.DefaultBtnInfo.Insert(Struct)
        }
        return True
    }
;=======================================================================================
;    Method:             OnMessage
;    Description:        Run label associated with button's Command identifier.
;                        This method should be called from a function monitoring the
;                            WM_COMMAND message. Pass the wParam as the CommandID.
;    Parameters:
;        CommandID:      Command ID associated with the button. This is send via
;                            WM_COMMAND message, you must pass the wParam from
;                            inside a function that monitors this message.
;    Return:             TRUE if target label exists, FALSE otherwise.
;=======================================================================================
    OnMessage(CommandID)
    {
        If (IsLabel(this.Labels[CommandID]))
        {
            GoSub, % this.Labels[CommandID]
            return True
        }
        Else
            return False
    }
;=======================================================================================
;    Method:             OnNotify
;    Description:        Handles toolbar notifications.
;                        This method should be called from a function monitoring the
;                            WM_NOTIFY message. Pass the lParam as the Param.
;                            The returned value should be used as return value for
;                            the monitoring function as well.
;    Parameters:
;        Param:          The lParam from WM_NOTIFY message.
;        MenuXPos:       OutputVar to store the horizontal position for a menu.
;        MenuYPos:       OutputVar to store the vertical position for a menu.
;        Label:          OutputVar to store the label name associated with the button.
;        ID:             OutputVar to store the button's Command ID.
;        AllowCustom:    Set to FALSE to prevent customization of toolbars.
;        AllowReset:     Set to FALSE to prevent Reset button from restoring original buttons.
;        HideHelp:       Set to FALSE to show the Help button in the customize dialog.
;    Return:             The required return value for the function monitoring
;                            the the WM_NOTIFY message.
;=======================================================================================
    OnNotify(ByRef Param, ByRef MenuXPos="", ByRef MenuYPos="", ByRef Label="", ByRef ID=""
    ,    AllowCustom=True, AllowReset=True, HideHelp=True)
    {
        nCode  := NumGet(Param + (A_PtrSize * 2), 0, "Int"), tbHwnd := NumGet(Param + 0, 0, "UPtr")
        If (tbHwnd <> this.tbHwnd)
            return ""
        If (nCode = this.TBN_DROPDOWN)
        {
            ID  := NumGet(Param + (A_PtrSize * 3), 0, "Int"), Label := this.Labels[ID]
        ,   VarSetCapacity(RECT, 16, 0)
            SendMessage, this.TB_GETRECT, ID, &RECT,, % "ahk_id " this.tbHwnd
            ControlGetPos, TBX, TBY,,,, % "ahk_id " this.tbHwnd
            MenuXPos := TBX + NumGet(&RECT, 0, "Int"), MenuYPos := TBY + NumGet(&RECT, 12, "Int")
            return False
        }
        Else
            Label := "", ID := ""
        If (nCode = this.TBN_QUERYINSERT)
            return AllowCustom
        If (nCode = this.TBN_QUERYDELETE)
            return AllowCustom
        If (nCode = this.TBN_GETBUTTONINFO)
        {
            iItem := NumGet(Param + (A_PtrSize * 3), 0, "Int")
            If (iItem = this.DefaultBtnInfo.MaxIndex())
                return False
            For each, Member in this.DefaultBtnInfo[iItem+1]
                %each% := Member
            SendMessage, this.TB_GETBUTTONTEXT, ID, 0,, % "ahk_id " this.tbHwnd
            VarSetCapacity(cText, ErrorLevel * (A_IsUnicode ? 2 : 1), 0)
            SendMessage, this.TB_GETBUTTONTEXT, ID, &cText,, % "ahk_id " this.tbHwnd
            tSize := StrLen(cText), iString := StrGet(&cText)
            If (iString <> "")
            {
                VarSetCapacity(BTNSTR, (StrPut(iString) * (A_IsUnicode ? 2 : 1), 0))
            ,   StrPut(iString, &BTNSTR, StrPut(iString) * 2)
                SendMessage, this.TB_ADDSTRING, 0, &BTNSTR,, % "ahk_id " this.tbHwnd
                Index := ErrorLevel, this.DefaultBtnInfo[iItem+1]["Index"] := Index
            ,    this.DefaultBtnInfo[iItem+1]["Text"] := iString
            }
            NumPut(Icon, Param + (A_PtrSize * 4), 0, "Int") ; iBitmap
        ,   NumPut(ID, Param + (A_PtrSize * 4), 4, "Int") ; idCommand
        ,   NumPut(State, Param + (A_PtrSize * 4), 8, "Char") ; tbState
        ,   NumPut(Style, Param + (A_PtrSize * 4), 9, "Char") ; tbStyle
        ,   NumPut(Index, Param + (A_PtrSize * 4), 8 + (A_PtrSize * 2), "Int") ; iString
            return True
        }
        If (nCode = this.TBN_RESET)
        {
            If (AllowReset)
            {
                this.Reset()
                return 2
            }
        }
        If (nCode = this.TBN_ENDADJUST)
            return True
        If (nCode = this.TBN_INITCUSTOMIZE)
            return HideHelp
        return ""
    }
    Class Private
    {
;=======================================================================================
;    Private Properties
;=======================================================================================
        ; Messages
        Static TB_ADDBUTTONS            := 0x0414
        Static TB_ADDSTRING             := A_IsUnicode ? 0x044D : 0x041C
        Static TB_AUTOSIZE              := 0x0421
        Static TB_BUTTONCOUNT           := 0x0418
        Static TB_CHECKBUTTON           := 0x0402
        Static TB_CUSTOMIZE             := 0x041B
        Static TB_DELETEBUTTON          := 0x0416
        Static TB_ENABLEBUTTON          := 0x0401
        Static TB_GETBUTTON             := 0x0417
        Static TB_GETBUTTONSIZE         := 0x043A
        Static TB_GETBUTTONTEXT         := A_IsUnicode ? 0x044B : 0x042D
        Static TB_GETEXTENDEDSTYLE      := 0x0455
        Static TB_GETHOTITEM            := 0x0447
        Static TB_GETIMAGELIST          := 0x0431
        Static TB_GETIMAGELISTCOUNT     := 0x0462
        Static TB_GETPADDING            := 0x0456
        Static TB_GETRECT               := 0x0433
        Static TB_GETROWS               := 0x0428
        Static TB_GETSTATE              := 0x0412
        Static TB_GETSTYLE              := 0x0439
        Static TB_GETSTRING             := A_IsUnicode ? :0x045B 0x045C
        Static TB_GETTEXTROWS           := 0x043D
        Static TB_HIDEBUTTON            := 0x0404
        Static TB_INDETERMINATE         := 0x0405
        Static TB_INSERTBUTTON          := A_IsUnicode ? 0x0443 : 0x0415
        Static TB_MARKBUTTON            := 0x0406
        Static TB_MOVEBUTTON            := 0x0452
        Static TB_PRESSBUTTON           := 0x0403
        Static TB_SETBUTTONINFO         := A_IsUnicode ? 0x0440 : 0x0442
        Static TB_SETBUTTONSIZE         := 0x041F
        Static TB_SETBUTTONWIDTH        := 0x043B
        Static TB_SETEXTENDEDSTYLE      := 0x0454
        Static TB_SETHOTITEM            := 0x0448
        Static TB_SETHOTITEM2           := 0x045E
        Static TB_SETIMAGELIST          := 0x0430
        Static TB_SETINDENT             := 0x042F
        Static TB_SETLISTGAP            := 0x0460
        Static TB_SETMAXTEXTROWS        := 0x043C
        Static TB_SETPADDING            := 0x0457
        Static TB_SETROWS               := 0x0427
        Static TB_SETSTATE              := 0x0411
        Static TB_SETSTYLE              := 0x0438
        ; Styles
        Static TBSTYLE_ALTDRAG      := 0x0400
        Static TBSTYLE_CUSTOMERASE  := 0x2000
        Static TBSTYLE_FLAT         := 0x0800
        Static TBSTYLE_LIST         := 0x1000
        Static TBSTYLE_REGISTERDROP := 0x4000
        Static TBSTYLE_TOOLTIPS     := 0x0100
        Static TBSTYLE_TRANSPARENT  := 0x8000
        Static TBSTYLE_WRAPABLE     := 0x0200
        Static TBSTYLE_ADJUSTABLE   := 0x20
        Static TBSTYLE_BORDER       := 0x800000
        Static TBSTYLE_THICKFRAME   := 0x40000
        Static TBSTYLE_TABSTOP      := 0x10000
        ; ExStyles
        Static TBSTYLE_EX_DOUBLEBUFFER       := 0x80 ; // Double Buffer the toolbar
        Static TBSTYLE_EX_DRAWDDARROWS       := 0x01
        Static TBSTYLE_EX_HIDECLIPPEDBUTTONS := 0x10 ; // don't show partially obscured buttons
        Static TBSTYLE_EX_MIXEDBUTTONS       := 0x08
        Static TBSTYLE_EX_MULTICOLUMN        := 0x02 ; // Intended for internal use; not recommended for use in applications.
        Static TBSTYLE_EX_VERTICAL           := 0x04 ; // Intended for internal use; not recommended for use in applications.
        ; Button states
        Static TBSTATE_CHECKED       := 0x01
        Static TBSTATE_ELLIPSES      := 0x40
        Static TBSTATE_ENABLED       := 0x04
        Static TBSTATE_HIDDEN        := 0x08
        Static TBSTATE_INDETERMINATE := 0x10
        Static TBSTATE_MARKED        := 0x80
        Static TBSTATE_PRESSED       := 0x02
        Static TBSTATE_WRAP          := 0x20
        ; Button styles
        Static BTNS_BUTTON        := 0x00 ; TBSTYLE_BUTTON
        Static BTNS_SEP           := 0x01 ; TBSTYLE_SEP
        Static BTNS_CHECK         := 0x02 ; TBSTYLE_CHECK
        Static BTNS_GROUP         := 0x04 ; TBSTYLE_GROUP
        Static BTNS_CHECKGROUP    := 0x06 ; TBSTYLE_CHECKGROUP  // (TBSTYLE_GROUP | TBSTYLE_CHECK)
        Static BTNS_DROPDOWN      := 0x08 ; TBSTYLE_DROPDOWN
        Static BTNS_AUTOSIZE      := 0x10 ; TBSTYLE_AUTOSIZE    // automatically calculate the cx of the button
        Static BTNS_NOPREFIX      := 0x20 ; TBSTYLE_NOPREFIX    // this button should not have accel prefix
        Static BTNS_SHOWTEXT      := 0x40 ; // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set
        Static BTNS_WHOLEDROPDOWN := 0x80 ; // draw drop-down arrow, but without split arrow section
        ; TB_GETBITMAPFLAGS
        Static TBBF_LARGE   := 0x00000001
        Static TBIF_BYINDEX := 0x80000000 ; // this specifies that the wparam in Get/SetButtonInfo is an index, not id
        Static TBIF_COMMAND := 0x00000020
        Static TBIF_IMAGE   := 0x00000001
        Static TBIF_LPARAM  := 0x00000010
        Static TBIF_SIZE    := 0x00000040
        Static TBIF_STATE   := 0x00000004
        Static TBIF_STYLE   := 0x00000008
        Static TBIF_TEXT    := 0x00000002
        ; Notifications
        Static TBN_BEGINADJUST     := -703
        Static TBN_BEGINDRAG       := -701
        Static TBN_CUSTHELP        := -709
        Static TBN_DELETINGBUTTON  := -715
        Static TBN_DRAGOUT         := -714
        Static TBN_DRAGOVER        := -727
        Static TBN_DROPDOWN        := -710
        Static TBN_DUPACCELERATOR  := -725
        Static TBN_ENDADJUST       := -704
        Static TBN_ENDDRAG         := -702
        Static TBN_GETBUTTONINFO   := A_IsUnicode ? -720 : -700
        Static TBN_GETDISPINFO     := A_IsUnicode ? -717 : -716
        Static TBN_GETINFOTIPA     := -718
        Static TBN_GETINFOTIPW     := -719
        Static TBN_GETOBJECT       := -712
        Static TBN_HOTITEMCHANGE   := -713
        Static TBN_INITCUSTOMIZE   := -723
        Static TBN_MAPACCELERATOR  := -728
        Static TBN_QUERYDELETE     := -707
        Static TBN_QUERYINSERT     := -706
        Static TBN_RESET           := -705
        Static TBN_RESTORE         := -721
        Static TBN_SAVE            := -722
        Static TBN_TOOLBARCHANGE   := -708
        Static TBN_WRAPACCELERATOR := -726
        Static TBN_WRAPHOTITEM     := -724
;=======================================================================================
;    Meta-Functions
;
;    Properties:
;        tbHwnd:        Toolbar's Hwnd.
;        DefaultBtnInfo:    Stores information about button's original structures.
;=======================================================================================
        __New(hToolbar)
        {
            this.tbHwnd := hToolbar
        ,   this.DefaultBtnInfo := []
        }

        __Delete()
        {
            this.Remove("", Chr(255))
        ,   this.SetCapacity(0)
        ,   this.base := ""
        }
;=======================================================================================
;    Private Methods
;=======================================================================================
;    Method:             BtnSep
;    Description:        Creates a TBBUTTON structure for a separator.
;    Return:             An array with the button structure values.
;=======================================================================================
        BtnSep(ByRef BtnVar)
        {
            VarSetCapacity(BtnVar, 8 + (A_PtrSize * 3), 0)
        ,   NumPut(this.BTNS_SEP, BtnVar, 9, "Char") ; fsStyle
        return {Icon: -1, ID: "", State: "", Style: this.BTNS_SEP, Index: "", Text: ""}
        }
;=======================================================================================
;    Method:             DefineBtnStruct
;    Description:        Creates a TBBUTTON structure.
;    Return:             An array with the button structure values.
;=======================================================================================
        DefineBtnStruct(ByRef BtnVar, iBitmap=0, idCommand=0, iString="", Options="")
        {
            If Options is Integer
                tbStyle := Options, tbState := this.TBSTATE_ENABLED
            Else
            {
                Loop, Parse, Options, %A_Space%%A_Tab%
                {
                    If (this[ "TBSTATE_" A_LoopField ])
                        tbState += this[ "TBSTATE_" A_LoopField ]
                    Else If (this[ "BTNS_" A_LoopField] )
                        tbStyle += this[ "BTNS_" A_LoopField ]
                    Else If (RegExMatch(A_LoopField, "i)W(\d+)-(\d+)", MW))
                    {
                        Long := this.MakeLong(MW1, MW2)
                        SendMessage, this.TB_SETBUTTONWIDTH, 0, Long,, % "ahk_id " this.tbHwnd
                    }
                }
            }
            If (iString <> "")
            {
                VarSetCapacity(BTNSTR, (StrPut(iString) * (A_IsUnicode ? 2 : 1), 0))
            ,   StrPut(iString, &BTNSTR, StrPut(iString) * 2)
                SendMessage, this.TB_ADDSTRING, 0, &BTNSTR,, % "ahk_id " this.tbHwnd
                StrIdx := ErrorLevel
            }
            Else
                StrIdx := -1
            VarSetCapacity(BtnVar, 8 + (A_PtrSize * 3), 0)
        ,   NumPut(iBitmap-1, BtnVar, 0, "Int")
        ,   NumPut(idCommand, BtnVar, 4, "Int")
        ,   NumPut(tbState, BtnVar, 8, "Char")
        ,   NumPut(tbStyle, BtnVar, 9, "Char")
        ,   NumPut(StrIdx, BtnVar, 8 + (A_PtrSize * 2), "Int")
            return {Icon: iBitmap-1, ID: idCommand, State: tbState
                    , Style: tbStyle, Index: StrIdx, Text: iString}
        }
;=======================================================================================
;    Method:             DefineBtnInfoStruct
;    Description:        Creates a TBBUTTONINFO structure for a specific member.
;=======================================================================================
        DefineBtnInfoStruct(ByRef BtnVar, Member, ByRef Value)
        {
            Static cbSize := (16 + A_PtrSize) + (A_PtrSize * 3)
            
            VarSetCapacity(BtnVar, cbSize, 0)
        ,   NumPut(cbSize, BtnVar, 0, "UInt")
            If (this[ "TBIF_" Member] )
                dwMask := this[ "TBIF_" Member ]
            ,   NumPut(dwMask, BtnVar, 4, "UInt")
            If (dwMask = this.TBIF_COMMAND)
                NumPut(Value, BtnVar, 8, "Int") ; idCommand
            Else If (dwMask = this.TBIF_IMAGE)
                Value := Value-1
            ,   NumPut(Value, BtnVar, 12, "Int") ; iImage
            Else If (dwMask = this.TBIF_STATE)
                Value := (this[ "TBSTATE_" Value ]) ? this[ "TBSTATE_" Value ] : Value
            ,   NumPut(Value, BtnVar, 16, "Char") ; fsState
            Else If (dwMask = this.TBIF_STYLE)
                Value := (this[ "BTNS_" Value ]) ? this[ "BTNS_" Value ] : Value
            ,   NumPut(Value, BtnVar, 17, "Char") ; fsStyle
            Else If (dwMask = this.TBIF_SIZE)
                NumPut(Value, BtnVar, 18, "Short") ; cx
            Else If (dwMask = this.TBIF_TEXT)
                NumPut(&Value, BtnVar, 16 + (A_PtrSize * 2), "UPtr") ; pszText
        }
;=======================================================================================
;    Method:             StringToNumber
;    Description:        Returns a number based on a string to be used as Command ID.
;=======================================================================================
        StringToNumber(String)
        {
            Loop, Parse, String
                Number += Asc(A_LoopField) + Number + SubStr(Number, -1)
            return SubStr(Number, 1, 5)
        }
;=======================================================================================
;    Method:             MakeLong
;    Description:        Creates a LongWord from a LoWord and a HiWord.
;=======================================================================================
        MakeLong(LoWord, HiWord)
        {
            return (HiWord << 16) | (LoWord & 0xffff)
        }
;=======================================================================================
;    Method:             MakeLong
;    Description:        Extracts LoWord and HiWord from a LongWord.
;=======================================================================================
        MakeShort(Long, ByRef LoWord, ByRef HiWord)
        {
            LoWord := Long & 0xffff
        ,    HiWord := Long >> 16
        }
    }
}