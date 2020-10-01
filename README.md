# OpenWatchFace

Do NOT use Connect IQ or Garmin Express to configure the settings! You must use the Garmin Connect app.

To get the weather data, you will need to make an account with OpenWeatherMaps and add your API key to the device settings.

## Features

City name of location
Date (WDM, WMD, DMW, DMW)
Time (12, 24)
AM/PM/Seconds
Current temp (F, C)
Current feels temp (F, C)
Current weather icon
Today weather icon*
Today max temp (F, C)
Today min temp (F, C)
Tomorrow weather icon*
Tomorrow max temp (F, C)
Tomorrow min temp (F, C)
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
--------------------------------------------------
Coming soon:
Support for more devices

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


--------------------------------------------------
## Changelog
### version 1.2.2:latest

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

