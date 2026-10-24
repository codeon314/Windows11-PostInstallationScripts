# 1. Base Dark Mode & kill transparency (Transparency introduces a gray glass filter)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value 0

# 2. Force Windows to use our custom accent colors on the Taskbar & Start Menu
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'ColorPrevalence' -Value 1

# Create paths if they somehow don't exist
$accentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
$dwmPath = 'HKCU:\Software\Microsoft\Windows\DWM'
if (-not (Test-Path $accentPath)) { New-Item -Path $accentPath -Force | Out-Null }
if (-not (Test-Path $dwmPath)) { New-Item -Path $dwmPath -Force | Out-Null }

# 3. Set DWM and Menu colors to 100% Opaque Black (0xFF000000)
Set-ItemProperty -Path $accentPath -Name 'AccentColorMenu' -Value 0xFF000000 -Type DWord
Set-ItemProperty -Path $dwmPath -Name 'AccentColor' -Value 0xFF000000 -Type DWord

# 4. OVERRIDE THE ACCENT PALETTE (The Secret Sauce)
# This 32-byte array maps out exactly how Windows colors UI elements.
# We set toggles/buttons to neutral grays so they remain visible, 
# and hardcode the Start Menu (Bytes 16-19) and Taskbar (Bytes 20-27) to Pure Black.
[byte[]]$pitchBlackPalette = @(
    0xB0, 0xB2, 0xB4, 0xFF, # [0-3]   Hover states (Light gray)
    0xCC, 0xCE, 0xD0, 0xFF, # [4-7]   Active Toggles/Buttons (Lighter gray)
    0x00, 0x00, 0x00, 0xFF, # [8-11]  Active Titlebars [Pure Black]
    0x90, 0x92, 0x94, 0xFF, # [12-15] Settings App Icons (Mid gray)
    0x00, 0x00, 0x00, 0xFF, # [16-19] Start Menu & Action Center Background [Pure Black]
    0x00, 0x00, 0x00, 0xFF, # [20-23] Taskbar Foreground [Pure Black]
    0x00, 0x00, 0x00, 0xFF, # [24-27] Taskbar Background [Pure Black]
    0x00, 0x00, 0x00, 0xFF  # [28-31] Unused
)
Set-ItemProperty -Path $accentPath -Name 'AccentPalette' -Value $pitchBlackPalette -Type Binary

# 5. Safely restart Explorer to force Windows to read the new palette
Stop-Process -Name explorer -Force
