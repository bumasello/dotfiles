#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; true enquanto o chat do Minecraft está aberto (ver bloco do Minecraft no fim)
mcChat := false

CapsLock::
    if GetKeyState("Shift", "P")
    {
        Send {CapsLock}
    }
    else
    {
        ; o Esc enviado pelo script não dispara o ~Esc lá embaixo, então fecha aqui
        mcChat := false
        Send {Escape}
    }
return

; CapsLock como prefixo pras setas
CapsLock & j::Send {Down}
CapsLock & k::Send {Up}
CapsLock & h::Send {Left}
CapsLock & l::Send {Right}

; Redefinições com CTRL
^p::Send {Up}
^n::Send {Down}

; Alt + Enter -> Abre o Windows Terminal
!Enter::
    Run, wt.exe
return

; Alt + Q -> Fecha a janela ativa
!q::
    WinClose, A
return

; Alt + F -> Maximiza ou Restaura a janela ativa
!f::
    WinGet, WinState, MinMax, A
    if (WinState = 1)
        WinRestore, A
    else
        WinMaximize, A
return

; Minecraft: Z -> survival, X -> creative. Só vale com a janela do jogo em foco.
; Com o chat aberto (T ou /) as teclas digitam normal; Enter ou Esc fecha.
#IfWinActive Minecraft ahk_exe javaw.exe
~t::
~/::
    mcChat := true
return

~Enter::
~NumpadEnter::
~Esc::
    mcChat := false
return

$z::McComando("z", "gamemode survival")
$x::McComando("x", "gamemode creative")
#IfWinActive

McComando(tecla, comando) {
    global mcChat
    if (mcChat) {
        Send %tecla%
        return
    }
    Send /
    Sleep 150  ; espera o chat abrir, senão as primeiras letras se perdem
    SendRaw %comando%
    Send {Enter}
}
