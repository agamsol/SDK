chcp 65001
$assets = New-DSAsset -LargeImageKey avatar -LargeImageText "Summoners Rift" -SmallImageKey icon -SmallImageText "Lvl 7"
$timestamp = New-DSTimestamp -Start (Get-Date).AddMinutes(-3) -End (Get-Date).AddMinutes(3)
$button = New-DSButton -Label "Potato$([char]::ConvertFromUtf32(0x1f954))" -Url https://github.com/potatoqualitee/discordrpc
$party = New-DSParty -Size 10 -Privacy Public -Max 100
$presence = New-DSRichPresence -Asset $assets -State "presence.ps1" -Details "Some details" -Timestamp $timestamp -Buttons $button -Party $party
$logger = New-DSLogger -Type ConsoleLogger -Level Info
$client = New-DSClient -ApplicationID 8245936638831214948 -Presence $presence -Logger $logger
pause