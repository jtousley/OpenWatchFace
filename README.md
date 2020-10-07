IMPORTANT! : To get the weather data, you will need to make an account with OpenWeatherMaps and add your API key to the device settings.

## Features

City name for location
Weather alert for location, when applicable
Date (WDM, WMD, DMW, DMW)
Time (12, 24)
AM/PM/Seconds/Week number
Current temp (F, C)
Current feels temp (F, C)
Current weather icon
Today weather icon*
Today max temp (F, C)
Today min temp (F, C)
Tomorrow weather icon*
Tomorrow max temp (F, C)
Tomorrow min temp (F, C)
(218x218 devices do not get this):
Day after weather icon*
Day after max temp (F, C)
Day after min temp (F, C)
--------------------------------------------------
Activities! - Choose 3:
Pulse
Distance (km, mi, steps)
Steps (km, mi, steps)
Floors
Altitude (m, ft)
Calories (kcal)
Next Sunrise/Sunset
Sensor pressure ambient** (mBar, Pa, in)
Sensor pressure raw** (mBar, Pa, in)
Sensor pressure mean sea level** (mBar, Pa, in)
Last update time
--------------------------------------------------
Weather! - Choose 3:
Humidity (%)
Dew point (C, F)
Reported pressure (mBar, Pa, in)
Wind speed (km/h, knots, m/s, mph)
Wind direction (degrees)
UV index
Today precipitation (%)
Tomorrow precipitation (%)
Day after precipitation (%)
Smart weather (see note)
--------------------------------------------------

Coming soon:
You tell me

Please contact me with any suggestions or problems!


*These icons support intensity values for certain types of weather:
'' = none/light intensity, '.' = medium intensity, '..' = high intensity, '...' = extreme intensity, '~' = "ragged"

**Sensor Pressure:
1. Ambient Pressure
This returns ambient (local) barometric pressure as measured by the pressure sensor. The data is smoothed by a two-stage filter to reduce noise and instantaneous variation.
2. Raw Ambient Pressure
This returns ambient (local) barometric pressure as measured by the internal pressure sensor. The data is the temperature compensated information read directly from the internal sensor.
3. Sea Level Pressure
This returns barometric pressure calibrated to sea level. Since pressure varies dues to several factors, a GPS-based altitude must first be obtained, then the ambient (local) pressure is measured by the pressure sensor before conversion to a calibrated barometric pressure value.

***Smart weather
Displays the following data, when available:
1. Rainfall amount (mm/in)
2. Snowfall amount (mm/in)
3. Wind gust (km/h, knots, m/s, mph)
4. Humidty percentage, if greater than 50
5. UV index

--------------------------------------------------
## Changelog
### version 1.2.8:latest

1.2.8

Add week number
Add do not disturb color
Allow hiding activity/weather options
Fix seconds and AM/PM field for 218x218 devices

1.2.7

Add last update time option
Remove pascals for pressure

Add color options for activity fields

Formatting for 218x218 devices
Better displaying of city names and weather advisories

1.2.6

Add most international characters (ASCII)
Unavailable characters will be '_'


1.2.5

Fix city names
Match date descriptions with functionality

1.2.4

Provide weather option: smart weather
Provide weather alerts
Weather stale color is now alert color and used for:
        Stale weather
        Weather alerts (displayed instead of location, when applicable)
        Low battery

Add support for:
Approach S62
Vivoactive 3M
Vivoactive 3M LTE
Vivoactive 4
Vivoactive 4S
legacysagarey
legacysagadarthvader
legacyherofirstavenger
legacyherocaptainmarvel

1.2.3

Add support for vivoactive4

1.2.2

Assistance for users with intermittent steps

1.2.1

Fix steps for fr245m

1.2.0

Fix packaging problems with Eclipse

1.1.0

Add support for fr245m
Fix precipitation (again)

1.0.14

Better precipitation handling

1.0.13

Better lunar handling

1.0.12

Allow user to specify weather update frequency (to nearest 5 minutes)
Allow white background

1.0.11

Secondary color for icon when weather data is stale
Allow user to display all types of pressure at once

1.0.10

Keep current data on error

1.0.9

Cannot force temporal events

1.0.8

Add icon color option
Add sensor pressure options
Adjust formatting

