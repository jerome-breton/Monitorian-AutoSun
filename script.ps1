#####################
# Launch Monitorian #
#####################

# Command line interface will be stuck if app is not already running
$running = Get-Process MonitorianPlus -ErrorAction SilentlyContinue
if (!$running) {
  Write-Host "Starting Monitorian: " -NoNewline -ForegroundColor DarkGreen
  Start-Process Monitorian
  Sleep 10
  Write-Host "Ok"
}

#################
# Read settings #
#################

$settings = Get-Content -Path $PSScriptRoot\settings.json | ConvertFrom-Json
$api = "https://api.sunrise-sunset.org/json?lat=$($settings.lat)&lng=$($settings.lon)&formatted=0"

#####################
# Prepare datetimes #
#####################

# Current date
$now = Get-Date 

# Call Sunrise/Sunset API
$sun = Invoke-RestMethod -Uri $api
$sun = $sun.results

# Get noon
$noon = (Get-Date $sun.solar_noon)

# Get sunrise
switch($settings.sunrise_type){
    "absolute"      { $begin = $sun.sunrise }
    "civil"         { $begin = $sun.civil_twilight_begin }
    "nautical"      { $begin = $sun.nautical_twilight_begin }
    "astronomical"  { $begin = $sun.astronomical_twilight_begin }
    default         { $begin = $sun.civil_twilight_begin }
}
$begin = (Get-Date $begin)

# Get sunset
switch($settings.sunset_type){
    "absolute"      { $end = $sun.sunset }
    "civil"         { $end = $sun.civil_twilight_end }
    "nautical"      { $end = $sun.nautical_twilight_end }
    "astronomical"  { $end = $sun.astronomical_twilight_end }
    default         { $end = $sun.civil_twilight_end }
}
$end = (Get-Date $end)

# Output date times
Write-Host "Now:        "   -NoNewline -ForegroundColor DarkGreen
Write-Host "$now"                  -ForegroundColor Blue

Write-Host "Sunset:     "   -NoNewline -ForegroundColor DarkGreen
Write-Host "$begin"                -ForegroundColor Blue

Write-Host "Noon:       "   -NoNewline -ForegroundColor DarkGreen
Write-Host "$noon"                 -ForegroundColor Blue

Write-Host "Sunrise:    "   -NoNewline -ForegroundColor DarkGreen
Write-Host "$end"                      -ForegroundColor Blue

###############################
# Calculate global brightness #
###############################

if(($now -lt $begin) -or ($now -gt $end)) 
{
  # Before sunrise or after sunset
  $light = 0
}elseIf($now -lt $noon)
{
  # Sunrise -> sinewave begining at $begin:0 and PI/2 is $noon:100
  $light = [Math]::Sin(([Math]::pi / 2) * ($now - $begin).TotalSeconds / ($noon - $begin).TotalSeconds)
}elseIf($now -ge $noon)
{
  # Sunset -> cosine begining at $noon:100 and PI/2 is $end:0
  $light = [Math]::Cos(([Math]::pi / 2) * ($now - $noon).TotalSeconds / ($end - $noon).TotalSeconds)
}

# Output brightness
Write-Host "Brightness: "                -NoNewline -ForegroundColor DarkGreen
Write-Host "$([Math]::Round(100 * $light))%"            -ForegroundColor Blue

###############################
# Apply brightness to screens #
###############################

$settings.screens | ForEach-Object {
    # Calculate brightness for this screen
    $screenLight = [Math]::Round($_.min + ($_.max - $_.min) * $light)
    
    # Apply it
    $result = (Monitorian /set $_.id $screenLight)
    
    #Output apply result
    Write-Host $_.id.replace('DISPLAY\','') -NoNewline -ForegroundColor Yellow
    Write-Host ":	"                       -NoNewline -ForegroundColor Yellow
    Write-Host "$screenLight%	"           -NoNewline -ForegroundColor Blue
    if ($result -eq "Monitor is not found.") {
        Write-Host " $result" -ForegroundColor Red
    } else {
        Write-Host $result.replace($_.id,'') -ForegroundColor Cyan
    }
}