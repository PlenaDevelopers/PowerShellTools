# PowerTool shared console style.
Set-StrictMode -Version Latest

function Initialize-PowerToolConsole {
    Set-Variable -Name ConfirmPreference -Value 'None' -Scope Global
    Set-Variable -Name WhatIfPreference -Value $false -Scope Global
    Set-Variable -Name ProgressPreference -Value 'SilentlyContinue' -Scope Global

    try {
        if ($Host.Name -match 'ConsoleHost') {
            $desiredWidth = 124
            $raw = $Host.UI.RawUI
            $buffer = $raw.BufferSize
            if ($buffer.Width -lt $desiredWidth) {
                $buffer.Width = $desiredWidth
                $raw.BufferSize = $buffer
            }
            $window = $raw.WindowSize
            $maxWidth = $raw.MaxPhysicalWindowSize.Width
            if ($maxWidth -gt 0 -and $window.Width -lt $desiredWidth) {
                $window.Width = [Math]::Min($desiredWidth, $maxWidth)
                $raw.WindowSize = $window
            }
        }
    }
    catch { }
}

function Get-PowerToolWidth {
    try {
        $width = $Host.UI.RawUI.WindowSize.Width - 6
        if ($width -lt 80) { return 118 }
        return [Math]::Min([Math]::Max($width, 96), 154)
    }
    catch { return 118 }
}

function Write-PowerToolSection {
    param(
        [Parameter(Mandatory)][string]$Title,
        [string]$Color = 'Cyan'
    )
    $width = Get-PowerToolWidth
    $label = " $($Title.ToUpperInvariant()) "
    $side = [Math]::Max(2, [Math]::Floor(($width - $label.Length) / 2))
    $line = ('=' * $side) + $label + ('=' * [Math]::Max(2, $width - $label.Length - $side))
    Write-Host ""
    Write-Host $line -ForegroundColor $Color
}

function Write-PowerToolStatus {
    param(
        [Parameter(Mandatory)][ValidateSet('Info','Success','Warning','Error','Step')][string]$Type,
        [Parameter(Mandatory)][string]$Message
    )
    $icon = switch ($Type) {
        'Info' { 'i' }
        'Success' { 'OK' }
        'Warning' { '!' }
        'Error' { 'X' }
        'Step' { '>' }
    }
    $color = switch ($Type) {
        'Info' { 'Gray' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Step' { 'Cyan' }
    }
    Write-Host ("{0} {1}" -f $icon, $Message) -ForegroundColor $color
}

function Write-PowerToolItem {
    param(
        [Parameter(Mandatory)][string]$Label,
        [AllowEmptyString()][string]$Value = '',
        [string]$Color = 'White'
    )
    Write-Host ("  {0,-22}: {1}" -f $Label, $Value) -ForegroundColor $Color
}
