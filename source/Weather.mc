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

class Weather {
  // CURRENT VALUES
 public
  var _tempCelcius = 0;
 public
  var _feelsTempCelcius = 0;
 public
  var _baroPressureBars = 0;
 public
  var _humidityPercentage = 0;
 public
  var _windSpeedMeterSeconds = 0;
 public
  var _windDirection = 0;
 public
  var _uvIndex = 0;
 public
  var _dewPoint = 0;
 public
  var _weatherDateTime = 0;
 public
  var _city = "UNK";

  // DAILY VALUES
  // Astral events
 public
  var _sunriseTime = 0;
 public
  var _sunsetTime = 0;
  // Min/Max Temperatures
 public
  var _minTempCelcius = 0;
 public
  var _maxTempCelcius = 0;
 public
  var _nextMinTempCelcius = 0;
 public
  var _nextMaxTempCelcius = 0;
 public
  var _nextNextMinTempCelcius = 0;
 public
  var _nextNextMaxTempCelcius = 0;

  // Etc Weather

  // Cloud percentage
 public
  var _todayCloudPercent = 0;
 public
  var _nextCloudPercent = 0;
 public
  var _nextNextCloudPercent = 0;

  // Precipitation probability
 public
  var _todayPrecipitationPercent = 0;
 public
  var _nextPrecipitationPercent = 0;
 public
  var _nextNextPrecipitationPercent = 0;

  // Weather IDs
 public
  var _currentId = 0;
 public
  var _todayPrimaryId = 0;
 public
  var _nextPrimaryId = 0;
 public
  var _nextNextPrimaryId = 0;

  // static public var _weatherIcons;

  function initialize() {
    // _weatherIcons = ["A", "B"];
  }

 public
  static function convertOpenWeatherIdToIcon(id) {
    var icon = Enumerations.REFRESH;  // Some normal weather
    var intensity = Enumerations.INTENSITY_LIGHT;
    var ragged = Enumerations.INTENSITY_NOT_RAGGED;

    if (id == null) {
      Sys.println("ID null");
      return [ icon, intensity, ragged ];
    }

    switch (id) {
      // TSTORMS
      case 200:
        // Thunderstorm	thunderstorm with light rain	 11d
        icon = Enumerations.WEATHER_TSTORM_RAIN;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 201:
        // Thunderstorm	thunderstorm with rain	 11d
        icon = Enumerations.WEATHER_TSTORM_RAIN;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 202:
        // Thunderstorm	thunderstorm with heavy rain	 11d
        icon = Enumerations.WEATHER_TSTORM_RAIN;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 210:
        // Thunderstorm	light thunderstorm	 11d
        icon = Enumerations.WEATHER_TSTORM;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 211:
        // Thunderstorm	thunderstorm	 11d
        icon = Enumerations.WEATHER_TSTORM;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 212:
        // Thunderstorm	heavy thunderstorm	 11d
        intensity = Enumerations.INTENSITY_HARD;
        icon = Enumerations.WEATHER_TSTORM;
        break;
      case 221:
        // Thunderstorm	ragged thunderstorm	 11d
        icon = Enumerations.WEATHER_TSTORM;
        ragged = Enumerations.INTENSITY_RAGGED;
        break;
      case 230:
        // Thunderstorm	thunderstorm with light drizzle	 11d
        icon = Enumerations.WEATHER_TSTORM_DRIZZLE;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 231:
        // Thunderstorm	thunderstorm with drizzle	 11d
        icon = Enumerations.WEATHER_TSTORM_DRIZZLE;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 232:
        // Thunderstorm	thunderstorm with heavy drizzle	 11d
        icon = Enumerations.WEATHER_TSTORM_DRIZZLE;
        intensity = Enumerations.INTENSITY_HARD;
        break;

        // DRIZZLE
      case 300:
        // Drizzle	light intensity drizzle	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 301:
        // Drizzle	drizzle	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 302:
        // Drizzle	heavy intensity drizzle	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 310:
        // Drizzle	light intensity drizzle rain	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 311:
        // Drizzle	drizzle rain	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 312:
        // Drizzle	heavy intensity drizzle rain	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 313:
        // Drizzle	shower rain and drizzle	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 314:
        // Drizzle	heavy shower rain and drizzle	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_EXTREME;
      case 321:
        // Drizzle	shower drizzle	 09d
        icon = Enumerations.WEATHER_DRIZZLE;
        intensity = Enumerations.INTENSITY_HARD;
        break;

        // RAIN
      case 500:
        // Rain	light rain	 10d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 501:
        // Rain	moderate rain	 10d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 502:
        // Rain	heavy intensity rain	 10d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 503:
        // Rain	very heavy rain	 10d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_EXTREME;
        break;
      case 504:
        // Rain	extreme rain	 10d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_EXTREME;
        break;
      case 511:
        // Rain	freezing rain	 13d
        icon = Enumerations.WEATHER_RAIN_FREEZING;
      case 520:
        // Rain	light intensity shower rain	 09d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 521:
        // Rain	shower rain	 09d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 522:
        // Rain	heavy intensity shower rain	 09d
        icon = Enumerations.WEATHER_RAIN;
        intensity = Enumerations.INTENSITY_EXTREME;
        break;
      case 531:
        // Rain	ragged shower rain	 09d
        icon = Enumerations.WEATHER_RAIN;
        ragged = Enumerations.INTENSITY_RAGGED;
        break;

        // SNOW
      case 600:
        // Snow	light snow	 13d
        icon = Enumerations.WEATHER_SNOW;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 601:
        // Snow	Snow	 13d
        icon = Enumerations.WEATHER_SNOW;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 602:
        // Snow	Heavy snow	 13d
        icon = Enumerations.WEATHER_SNOW;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 611:
        // Snow	Sleet	 13d
        icon = Enumerations.WEATHER_SNOW_SLEET;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 612:
        // Snow	Light shower sleet	 13d
        icon = Enumerations.WEATHER_SNOW_SLEET;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 613:
        // Snow	Shower sleet	 13d
        icon = Enumerations.WEATHER_SNOW_SLEET;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 615:
        // Snow	Light rain and snow	 13d
        icon = Enumerations.WEATHER_SNOW_RAIN;
        // intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 616:
        // Snow	Rain and snow	 13d
        icon = Enumerations.WEATHER_SNOW_RAIN;
        // intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 620:
        // Snow	Light shower snow	 13d
        icon = Enumerations.WEATHER_SNOW;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 621:
        // Snow	Shower snow	 13d
        icon = Enumerations.WEATHER_SNOW;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 622:
        // Snow	Heavy shower snow	 13d
        icon = Enumerations.WEATHER_SNOW;
        intensity = Enumerations.INTENSITY_EXTREME;
        break;

        // ETC
      case 701:
        // Mist	mist	 50d
        icon = Enumerations.WEATHER_MIST;
        break;
      case 711:
        // Smoke	Smoke	 50d
      case 721:
        // Haze	Haze	 50d
        icon = Enumerations.WEATHER_HAZE;
        break;
      case 731:
        // Dust	sand/ dust whirls	 50d
        icon = Enumerations.WEATHER_SAND;
        break;
      case 741:
        // Fog	fog	 50d
        icon = Enumerations.WEATHER_FOG;
        break;
      case 751:
        // Sand	sand	 50d
        icon = Enumerations.WEATHER_SAND;
        break;
      case 761:
        // Dust	dust	 50d
        icon = Enumerations.WEATHER_DUST;
        break;
      case 762:
        // Ash	volcanic ash	 50d
        icon = Enumerations.WEATHER_VOLCANO;
        break;
      case 771:
        // Squall	squalls	 50d
        icon = Enumerations.WEATHER_HURRICANE;
        break;
      case 781:
        // Tornado	tornado	 50d
        icon = Enumerations.WEATHER_TORNADO;
        break;

      case 800:
        // Clear	clear sky	 01d
        icon = Enumerations.WEATHER_SUNNY;
        break;
      case 801:
        // Clouds	few clouds: 11-25%	 02d
        icon = Enumerations.WEATHER_PARTLY_CLOUDY;
        intensity = Enumerations.INTENSITY_LIGHT;
        break;
      case 802:
        // Clouds	scattered clouds: 25-50%	 03d
        icon = Enumerations.WEATHER_PARTLY_CLOUDY;
        intensity = Enumerations.INTENSITY_MEDIUM;
        break;
      case 803:
        // Clouds	broken clouds: 51-84%	 04d
        icon = Enumerations.WEATHER_PARTLY_CLOUDY;
        intensity = Enumerations.INTENSITY_HARD;
        break;
      case 804:
        // Clouds	overcast clouds: 85-100%	 04d
        icon = Enumerations.WEATHER_CLOUDY;
        intensity = Enumerations.INTENSITY_EXTREME;
        break;
      default:
        break;
    }

    return [ icon, intensity, ragged ];
  }
}  // Weather
