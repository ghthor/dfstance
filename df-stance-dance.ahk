#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

force_equip_count := 0

stances := Object("Mage", new MageStance())

stance := new GatherStance()

class DFHotkey {
    static equip_twohand    := "{Delete}"
    static equip_onehand    := "{Insert}"
    static equip_board      := "{Home}"
    static equip_bow        := "{End}"
    static equip_staff      := "{PgDn}"
    static equip_gather     := "{PgUp}"
    static rest             := "h"
    static gui_toggle       := "``"
    static alt_attack_toggle := "\"

    static move_back        := "s"

    static col_mage_defense1    := "{Numpad1}"
    static col_mage_defense2    := "{Numpad2}"
    static col_mage_offense1    := "{Numpad3}"
    static col_mage_offense2    := "{Numpad4}"
    static col_mage_utility1    := "{Numpad5}"
    static col_mage_utility2    := "{Numpad6}"

    static col_twohand          := "{Numpad7}"
    static col_onehand          := "{Numpad8}"
}

; This is an interface Defination
class Stance {
    Equip() {
    }

    MouseRight() {
    }

    Mouse4() {
    }

    Mouse5() {
    }
}

class TwoHandStance extends Stance {
    __New() {
        Send, % DFHotkey.col_twohand
    }

    Equip() {
        WinSetTitle, Darkfall Online - Two Hander
        Send, % DFHotkey.equip_twohand
    }

    Mouse4() {
        if (isMouseShown()) {
            return
        }

        Send, % DFHotkey.alt_attack_toggle
    }
}

class OneHandStance extends Stance {
    __New() {
        Send, % DFHotkey.col_onehand
    }

    Equip() {
        WinSetTitle, Darkfall Online - Sword and Board
        Send, % DFHotkey.equip_onehand
        Sleep, 600
        this.EquipBoard()
    }

    EquipBoard() {
        Send, % DFHotkey.equip_board
    }

    Mouse4() {
        if (isMouseShown()) {
            return
        }

        Send, % DFHotkey.alt_attack_toggle
    }
}

class ArcherStance extends Stance {
    __New() {
    }

    Equip() {
        WinSetTitle, Darkfall Online - Archery
        Send, % DFHotkey.equip_bow
    }
}

class ColumnState {
    name := ""

    Apply() {
        Send, % DFHotkey["col_" . this.name]
    }
}

class MageColumnStateToggle {
    name    := ""
    index   := 1

    __New(_name, _index) {
        this.name   := _name
        this.index  := _index
    }

    Apply() {
        Send, % DFHotkey["col_" . this.name . this.index]
    }

    ToggleColumn() {
        if (this.index = 2) {
            this.index := 1
        } else {
            this.index := 2
        }
    }
}

class MageStance extends Stance {

    defenseState := new MageColumnStateToggle("mage_defense", 1)
    offenseState := new MageColumnStateToggle("mage_offense", 1)
    utilityState := new MageColumnStateToggle("mage_utility", 1)
    state := this.defenseState

    __New() {
    }

    Equip() {
        WinSetTitle, Darkfall Online - Mage
        this.state.Apply()
        Send, % DFHotkey.equip_staff
    }

    MouseRight() {
        if (isMouseShown()) {
            return
        }

        if (this.state = this.defenseState) {
            this.state.ToggleColumn()
        } else {
            this.state := this.defenseState
        }
        this.state.Apply()
    }

    Mouse4() {
        if (isMouseShown()) {
            return
        }

        if (this.state = this.offenseState) {
            this.state.ToggleColumn()
        } else {
            this.state := this.offenseState
        }
        this.state.Apply()
    }

    Mouse5() {
        if (isMouseShown()) {
            return
        }

        if (this.state = this.utilityState) {
            this.state.ToggleColumn()
        } else {
            this.state := this.utilityState
        }
        this.state.Apply()
    }
}

class GatherStance extends Stance {
    __New() {
    }

    Equip() {
        WinSetTitle, Darkfall Online - Gathering
        Send, % DFHotkey.equip_gather
    }

    ; Helps with Multiboxing
    Mouse4() {
        if (isMouseShown()) {
            Send, % DFHotkey.gui_toggle
            Sleep, 200
        }

        move_back := DFHotkey.move_back

        Send, {%move_back% down}
        Sleep 200
        Send, {%move_back% up}
        Sleep 500

        Send, % DFHotkey.rest
        Sleep, 100

        Send, % DFHotkey.gui_toggle
    }
}

;;;;;;;;;;;;;;;;;;;;;;
;; Stance Switching
;;;;;;;;;;;;;;;;;;;;;;
; TwoHand
#IfWinActive, Darkfall Online
*$q::
    ; Don't apply stance change if gui is Open
    if (isMouseShown()) {
        Send, q
        return
    }

    if (stance.__class != TwoHandStance.__class) {
        stance := new TwoHandStance()
        stance.Equip()
    } else {
        ForceEquip()
    }
    return


; OneHand
#IfWinActive, Darkfall Online
*~$CapsLock::
    ; Don't apply stance change if gui is Open
    if (isMouseShown()) {
        Send, {Tab}
        return
    }

    if (stance.__class != OneHandStance.__class) {
        stance := new OneHandStance()
        stance.Equip()
    } else {
        stance.EquipBoard()
    }
    return

; Archer
#IfWinActive, Darkfall Online
*$e::
    ; Don't apply stance change if gui is Open
    if (isMouseShown()) {
        Send, e
        return
    }

    if (stance.__class != ArcherStance.__class) {
        stance := new ArcherStance()
        stance.Equip()
    } else {
        ForceEquip()
    }
    return

; Mage
#IfWinActive, Darkfall Online
*$Tab::
    ; Don't apply stance change if gui is Open
    if (isMouseShown()) {
        return
    }

    if (stance.__class != MageStance.__class) {
        stance := stances["Mage"]
        stance.Equip()
    } else {
        ForceEquip()
    }
    return

; Gather
#IfWinActive, Darkfall Online
*$y::
    ; Don't apply stance change if gui is Open
    if (isMouseShown()) {
        Send, y
        return
    }

    if (stance.__class != GatherStance.__class) {
        stance := new GatherStance()
        stance.Equip()
    } else {
        ForceEquip()
    }
    return


#IfWinActive, Darkfall Online
*~RButton::
    stance.MouseRight()
    return
    
#IfWinActive, Darkfall Online
*XButton1::
    stance.Mouse4()
    return

#IfWinActive, Darkfall Online
*MButton::
    stance.Mouse5()
    return

*Pause::
    Suspend
    return


; This allows you to force call Equip() method if the weapon wasn't successfully equipped initially
ForceEquip() {
    global force_equip_count

    SetTimer, force_equip, -400, 1
    force_equip_count += 1
    return

force_equip:
    ; If you press the key 3 times you will force call Equip() method again
    ; If you spam the key 3 times when you initially change stances force_equip_count will be 2, therefor stance.Equip() will only be called once during the initial stance change
    if (force_equip_count >= 3) {
        stance.Equip()
    }
    force_equip_count := 0
    return
}

; Credit to Someone in the DF community, If you created this and you want credit let me know
; This is brilliant! So useful
isMouseShown() {
    StructSize := A_PtrSize + 16
    VarSetCapacity(InfoStruct, StructSize)
    NumPut(StructSize, InfoStruct)
    DllCall("GetCursorInfo", UInt, &InfoStruct)
    Result := NumGet(InfoStruct, 8)

    if Result {
        return 1
    } else {
        return 0
    }
} 

ForceGUIToggleOff() {
    if (isMouseShown()) {
        Send, % DFHotkey.gui_toggle
    }
}
