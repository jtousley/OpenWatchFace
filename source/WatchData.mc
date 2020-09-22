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

using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;
using Toybox.Math as Math;

class WatchData {
  static function GetMoonPhase(timeNow) {
    var JD = timeNow.value().toDouble() / Gregorian.SECONDS_PER_DAY.toDouble() +
             2440587.500d;
    var IP = Normalize((JD.toDouble() - 2451550.1d) / 29.530588853d);
    var Age = IP * 29.53d;

    Sys.println("Age : " + Age);
    var phase = 0;
    if (Age < 1.84566) {
      phase = Enumerations.NEW_MOON;
    } else if (Age < 6.38264) {
      phase = Enumerations.EVENING_CRESCENT;
    } else if (Age < 8.38264) {
      phase = Enumerations.FIRST_QUARTER;
    } else if (Age < 13.76529) {
      phase = Enumerations.WAXING_GIBBOUS;
    } else if (Age < 15.76529) {
      phase = Enumerations.FULL_MOON;
    } else if (Age < 21.14794) {
      phase = Enumerations.WANING_GIBBOUS;
    } else if (Age < 23.14794077932) {
      phase = Enumerations.LAST_QUARTER;
    } else if (Age < 28.53058) {
      phase = Enumerations.MORNING_CRESCENT;
    } else {
      phase = Enumerations.NEW_MOON;
    }  // A new moon";

    IP = IP * 2d * Math.PI;  // Convert phase to radians

    // calculate moon's distance
    //
    var DP = 2d * Math.PI * Normalize((JD - 2451562.2d) / 27.55454988d);

    // calculate moon's ecliptic longitude
    //
    var RP = Normalize((JD - 2451555.8d) / 27.321582241d);
    var LO = 360d * RP + 6.3d * Math.sin(DP) + 1.3d * Math.sin(2d * IP - DP) +
             0.7d * Math.sin(2d * IP);

    var zodiac = 0;
    if (LO < 33.18) {
      zodiac = 0;
    }  // Pisces
    else if (LO < 51.16) {
      zodiac = 1;
    }  // Aries"
    else if (LO < 93.44) {
      zodiac = 2;
    }  // Taurus"
    else if (LO < 119.48) {
      zodiac = 3;
    }  // Gemini"
    else if (LO < 135.30) {
      zodiac = 4;
    }  // Cancer"
    else if (LO < 173.34) {
      zodiac = 5;
    }  // Leo"
    else if (LO < 224.17) {
      zodiac = 6;
    }  // Virgo"
    else if (LO < 242.57) {
      zodiac = 7;
    }  // Libra"
    else if (LO < 271.26) {
      zodiac = 8;
    }  // Scorpio"
    else if (LO < 302.49) {
      zodiac = 9;
    }  // Sagittarius"
    else if (LO < 311.72) {
      zodiac = 10;
    }  // Capricorn"
    else if (LO < 348.58) {
      zodiac = 11;
    }  // Aquarius"
    else {
      zodiac = 0;
    }  //  Pisces"

    return [ phase, zodiac ];
  }

  static function Normalize(value) {
    var nValue = value - Math.floor(value);
    if (nValue < 0) {
      nValue = nValue + 1;
    }
    return nValue;
  }
}
