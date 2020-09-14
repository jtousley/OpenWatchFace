/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;
using Toybox.Math as Math;

class Enumerations {
  static enum {
    FONT_TINY = 0,
    FONT_SMALL = 1,
    FONT_MED = 2,
    FONT_LARGE = 3,
    FONT_SM_ICON = 4,
    FONT_LG_ICON = 5
  }
  
  static enum {
    TEMPERATURE_CELCIUS = 0,
    TEMPERATURE_FAHRENHEIT = 1
  }

  static enum {
    INTENSITY_LIGHT = "",
    INTENSITY_MEDIUM = ".",
    INTENSITY_HARD = "..",
    INTENSITY_EXTREME = "...",
  }

  static enum {
    INTENSITY_NOT_RAGGED = "",
    INTENSITY_RAGGED = "~"
  }

  static enum {
    NEW_MOON = 0,
    EVENING_CRESCENT = 1,
    FIRST_QUARTER = 2,
    WAXING_GIBBOUS = 3,
    FULL_MOON = 4,
    WANING_GIBBOUS = 5,
    LAST_QUARTER = 6,
    MORNING_CRESCENT = 7,
    WEATHER_SUNNY = "A",
    WEATHER_PARTLY_CLOUDY = "B",
    WEATHER_CLOUDY = "C",
    WEATHER_RAIN = "D",
    WEATHER_DRIZZLE_RAIN = "D",
    WEATHER_SNOW_RAIN = "E",
    WEATHER_SNOW = "F",
    WEATHER_DRIZZLE = "G",
    WEATHER_TSTORM = "H",
    WEATHER_TSTORM_RAIN = "I",
    WEATHER_TSTORM_DRIZZLE = "I",
    WEATHER_WIND = "J",
    WEATHER_RAIN_FREEZING = "K",
    WEATHER_SLEET = "L",
    WEATHER_SNOW_SLEET = "L",
    WEATHER_HAZE = "M",
    WEATHER_DUST = "N",
    WEATHER_FOG = "O",
    WEATHER_MIST = "P",
    // WEATHER_SAND = "Q",
    WEATHER_SAND = "N",
    WEATHER_HURRICANE = "R",
    WEATHER_TORNADO = "S",
    WEATHER_VOLCANO = "T",
    BLUETOOTH_CONNECTED = "U",
    BLUETOOTH_NOT_CONNECTED = "V",
    REFRESH = "W",
    ELECTRICITY = "X",
    STEPS = "Y",
    PULSE = "Z",
    ALARM_NOT_RINGING = "a",
    ALARM_RINGING = "b",
    PRESSURE = "c",
    PRECIPITATION = "d",
    NOTIFICATIONS = "e",
    DISTANCE = "f",
    DO_NOT_DISTURB = "g",
    SUNSET = "h",
    SUNRISE = "i",
    HUMIDITY = "j",
    CALORIES = "k",
    DEW_POINT = "l",
    UV_INDEX = "m",
    FLOORS = "n",
    ALTITUDE = "o",
    DIRECTION = "s"
  }

  static enum {
    ColorBlack = 0,
    ColorDarkGray = 1,
    ColorLightGray = 2,
    ColorWhite = 3,
    ColorBlue = 4,
    ColorRed = 5,
    ColorLimeGreen = 6,
    ColorLime = 7,
    ColorYellowGreen = 8,
    ColorPaleGreen = 9,
    ColorPaleBlue = 10,
    ColorPink = 11,
    ColorAqua = 12,
    ColorYellow = 13,
    ColorPaleYellow = 14,
    ColorYellowRed = 15,
    ColorOrange = 16
  }

  static enum {
    WVAL_CURR_TEMP = 0,
    WVAL_FEEL_TEMP = 1,
    WVAL_PRESS = 2,
    WVAL_HUM = 3,
    WVAL_WIND_S = 4,
    WVAL_WIND_D = 5,
    WVAL_UV = 6,
    WVAL_SUNRISE = 7,
    WVAL_SUNSET = 8,
    WVAL_DEW = 9,
    WVAL_CURR_ID = 10,
    WVAL_DT = 11,
    WVAL_T_MIN = 12,
    WVAL_T_MAX = 13,
    WVAL_T_ID = 14,
    WVAL_T_CLOUD = 15,
    WVAL_T_POP = 16,
    WVAL_N_MIN = 17,
    WVAL_N_MAX = 18,
    WVAL_N_ID = 19,
    WVAL_N_CLOUD = 20,
    WVAL_N_POP = 21,
    WVAL_NN_MIN = 22,
    WVAL_NN_MAX = 23,
    WVAL_NN_ID = 24,
    WVAL_NN_CLOUD = 25,
    WVAL_NN_POP = 26,
    WVAL_SIZE = 27
  }

  static enum {
    LAYOUT_TIME = 0,
    LAYOUT_DATE = 1,
    LAYOUT_TOP = 2,
    LAYOUT_SEC = 3,
    LAYOUT_AMPM = 4,
    LAYOUT_CURR_TEMP = 5,
    LAYOUT_FEELS_TEMP = 6,
    LAYOUT_T_MAX = 7,
    LAYOUT_T_MIN = 8,
    LAYOUT_N_MAX = 9,
    LAYOUT_N_MIN = 10,
    LAYOUT_NN_MAX = 11,
    LAYOUT_NN_MIN = 12,
    LAYOUT_WOPT_1 = 13,
    LAYOUT_WOPT_2 = 14,
    LAYOUT_WOPT_3 = 15,
    LAYOUT_T_WICON = 16,
    LAYOUT_CURR_WICON = 17,
    LAYOUT_N_WICON = 18,
    LAYOUT_NN_WICON = 19,
    LAYOUT_CITY = 20,
    LAYOUT_FIELD_3 = 21,
    LAYOUT_FIELD_4 = 22,
    LAYOUT_FIELD_5 = 23,
    LAYOUT_BATTERY = 24,
    LAYOUT_BOTTOM = 25,
    LAYOUT_SIZE = 26
  }

}  // class Enumerations
