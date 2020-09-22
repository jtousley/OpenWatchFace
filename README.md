# OpenWatchFace

Do NOT use Connect IQ or Garmin Express to configure the settings! You must use the Garmin Connect app.

To get the weather data, you will need to make an account with OpenWeatherMaps and add your API key to the device settings.

## Features

City name of location
Date
Time
AM/PM/Seconds
Current temp
Current feels temp
Current weather icon
Today max temp
Today min temp
Tomorrow max temp
Tomorrow min temp
Day after max temp
Day after min temp
--------------------------------------------------
Activities! - Choose 3:
Pulse
Distance
Steps (km, mi, steps)
Floors
Altitude (m, ft)
Calories
Sunrise/Sunset
Sensor pressure ambient* (mBar, Pa, in)
Sensor pressure raw* (mBar, Pa, in)
Sensor pressure mean sea level* (mBar, Pa, in)
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
Images for better description
Support for more devices

Please contact me with any suggestions or problems!


*Sensor Pressure:
1. Ambient Pressure
This returns ambient (local) barometric pressure as measured by the pressure sensor. The data is smoothed by a two-stage filter to reduce noise and instantaneous variation.
2. Raw Ambient Pressure
This returns ambient (local) barometric pressure as measured by the internal pressure sensor. The data is the temperature compensated information read directly from the internal sensor.
3. Sea Level Pressure
This returns barometric pressure calibrated to sea level. Since pressure varies dues to several factors, a GPS-based altitude must first be obtained, then the ambient (local) pressure is measured by the pressure sensor before conversion to a calibrated barometric pressure value.

## Screenshots

--------------------------------------------------
## Changelog
### version 1.0.13:latest
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

