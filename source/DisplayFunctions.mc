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

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Activity as Activity;

class DisplayFunctions {
 protected
  var _heartRate = 0;
 protected
  var _heartRateText = "-- ";
 protected
  var _gTimeNow;
 protected
  var _settings;
 protected
  var _isInit = false;

 protected
  var _methods = [
    //
    :DisplayPulse
    , :DisplayDistance
    , :DisplaySteps
    , :DisplayFloors
    , :DisplayAltitude
    , :DisplayCalories
    , :DisplaySunEvent
    , :DisplaySensorPressure
    ];

 protected
  var _weatherFuncs = [//
                         :DisplayHumidity
                        , :DisplayDewPoint
                        , :DisplayWeatherPressure
                        , :DisplayWind
                        , :DisplayWindDirection
                        , :DisplayUVI
                        , :DisplayTodayPrecipitation
                        , :DisplayNextPrecipitation
                        , :DisplayNextNextPrecipitation];

  function setTime(time) { _gTimeNow = time; }

  function setSettings(settings) {
    if (settings == null) {
      throw new Lang.InvalidValueException("settings is null");
    }
    _settings = settings;
  }

  function DisplayTopLine(layout) {
    var data = [ "", "", "" ];

    var moonData = WatchData.GetMoonPhase(Time.now());
    data[0] = moonData[0];

    // layout["col"] = _settings.connError ? [3] : [0];
    var deviceSettings = Sys.getDeviceSettings();
    data[1] = (deviceSettings != null && deviceSettings.phoneConnected)
                  ? Enumerations.BLUETOOTH_CONNECTED
                  : Enumerations.BLUETOOTH_NOT_CONNECTED;

    if (deviceSettings != null && deviceSettings has : doNotDisturb) {
      layout["col"][2] = deviceSettings.doNotDisturb
                             ? Enumerations.ColorPaleYellow
                             : Enumerations.ColorLightGray;
      data[2] = Enumerations.DO_NOT_DISTURB;
    }

    return data;
  }

  function DisplayBottomLine(layout) {
    var data = [ "", "", "", "", "", "" ];
    var ds = Sys.getDeviceSettings();

    if (ds != null && ds has : alarmCount && ds.alarmCount != null) {
      data[0] = (ds.alarmCount > 0) ? Enumerations.ALARM_RINGING
                                    : Enumerations.ALARM_NOT_RINGING;
      data[1] = ds.alarmCount.format("%d");
    }

    if (ds != null && ds has
        : notificationCount && ds.notificationCount != null) {
      data[2] = Enumerations.NOTIFICATIONS;
      data[3] = ds.notificationCount.format("%d");
    }

    return data;
  }

  function LoadField3(layout) {
    if (_settings.field3 < _methods.size() && _settings.field3 >= 0 &&
        self has _methods[_settings.field3]) {
      return method(_methods[_settings.field3]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function LoadField4(layout) {
    if (_settings.field4 < _methods.size() && _settings.field4 >= 0 &&
        self has _methods[_settings.field4]) {
      return method(_methods[_settings.field4]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function LoadField5(layout) {
    if (_settings.field5 < _methods.size() && _settings.field5 >= 0 &&
        self has _methods[_settings.field5]) {
      return method(_methods[_settings.field5]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayDate(layout) {
    var day = _gTimeNow.day.format("%02d").toString();
    var month = _gTimeNow.month.toString();
    var week = _gTimeNow.day_of_week.toUpper().toString();
    if (week.length() > 3) {
      week = week.substring(0, 3);
    }
    var data = "";
    var order = _settings.dateOrder;
    if (order == 0) {  // WDM
      data = (week + " " + day + " " + month);
    } else if (order == 1) {  // WMD
      data = (week + " " + month + " " + day);
    } else if (order == 2) {  // DMW
      data = (day + " " + month + " " + week);
    } else if (order == 3) {  // MDW
      data = (month + " " + day + " " + week);
    }
    _isInit = true;

    return [data];
  }

  ///
  /// returns [Hour, Min]
  ///
  function DisplayTime(layout) {
    var deviceSettings = Sys.getDeviceSettings();
    layout["col"][0] = Setting.GetHourColor();
    layout["col"][2] = Setting.GetMinuteColor();
    var hour = (deviceSettings != null && deviceSettings.is24Hour)
                   ? _gTimeNow.hour.format("%02d")
                   : (_gTimeNow.hour % 12 == 0 ? 12 : _gTimeNow.hour % 12)
                         .format("%02d");
    var minute = _gTimeNow.min.format("%02d");
    return [ hour, ":", minute ];
  }

  ///
  /// returns [pm|am]
  ///
  function DisplayPmAm(layout) {
    if (Setting.GetIsShowAmPm()) {
      return [_gTimeNow.hour > 11 ? "pm" : "am"];
    } else {
      return [""];
    }
  }

  ///
  /// returns [seconds]
  ///
  function DisplaySeconds(layout) {
    if (Setting.GetIsShowSeconds()) {
      return [Sys.getClockTime().sec.format("%02d")];
    } else {
      return [""];
    }
  }

  ///
  /// returns temperature
  ///
  function DisplayCurrentTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._tempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
    // }
  }

  function DisplayFeelsTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._feelsTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayTodayMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._maxTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayTodayMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._minTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayNextMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextMaxTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayNextMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextMinTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayNextNextMaxTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextNextMaxTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayNextNextMinTemp(layout) {
    var weather = _settings.weather;

    var temperature = weather._nextNextMinTempCelcius;
    if (_settings.weatherTempSystem ==
        Enumerations.TEMPERATURE_FAHRENHEIT) {  // F
      temperature = temperature * 1.8 + 32;
    }
    temperature = temperature.format("%d");

    return [temperature];
  }

  function DisplayWeatherOption1(layout) {
    if (_settings.weatherField0 < _weatherFuncs.size() &&
        _settings.weatherField0 >= 0 &&
        self has _weatherFuncs[_settings.weatherField0]) {
      return method(_weatherFuncs[_settings.weatherField0]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayWeatherOption2(layout) {
    if (_settings.weatherField1 < _weatherFuncs.size() &&
        _settings.weatherField1 >= 0 &&
        self has _weatherFuncs[_settings.weatherField1]) {
      return method(_weatherFuncs[_settings.weatherField1]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayWeatherOption3(layout) {
    if (_settings.weatherField2 < _weatherFuncs.size() &&
        _settings.weatherField2 >= 0 &&
        self has _weatherFuncs[_settings.weatherField2]) {
      return method(_weatherFuncs[_settings.weatherField2]).invoke(layout);
    } else {
      return [ "", "" ];
    }
  }

  function DisplayTodayWeatherIcon(layout) {
    var weather = _settings.weather;
    var data = Weather.convertOpenWeatherIdToIcon(weather._todayPrimaryId);

    return data;
  }
  function DisplayNextWeatherIcon(layout) {
    var weather = _settings.weather;
    var data = Weather.convertOpenWeatherIdToIcon(weather._nextPrimaryId);

    return data;
  }
  function DisplayNextNextWeatherIcon(layout) {
    var weather = _settings.weather;
    var data = Weather.convertOpenWeatherIdToIcon(weather._nextNextPrimaryId);

    return data;
  }
  function DisplayCurrWeatherIcon(layout) {
    var weather = _settings.weather;
    var data = Weather.convertOpenWeatherIdToIcon(weather._currentId);
    var icon = data[0];
    // var intensity = data[1];

    return [icon];
  }

  function DisplayWind(layout) {
    var weather = _settings.weather;

    var windTable = [ 3.6, 1.94384, 1, 2.23694 ];

    var windMultiplier = windTable[_settings.weatherWindSystem];
    var windSpeed = weather._windSpeedMeterSeconds * windMultiplier;
    var formattedWindSpeed = windSpeed.format("%2.1f");

    return [ Enumerations.WEATHER_WIND, formattedWindSpeed ];
  }

  function DisplaySunEvent(layout) {
    var weather = _settings.weather;

    if (weather._weatherDateTime == 0) {
      return [ Enumerations.REFRESH, "--:--" ];
    }

    var sunrise = weather._sunriseTime;
    var sunset = weather._sunsetTime;
    var nextSunrise = weather._nextSunriseTime;
    var currTimeOffset = Sys.getClockTime().timeZoneOffset;
    if (Time.now().value() < sunrise) {  // next is sunrise
      var equalizedSunrise = new Time.Moment(sunrise + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedSunrise, Time.FORMAT_SHORT);
      return [
        Enumerations.SUNRISE, info.hour.format("%02u").toString() + ":" +
                                  info.min.format("%02u").toString()
      ];
    } else if (Time.now().value() < sunset) {  // next is sunset
      var equalizedSunset = new Time.Moment(sunset + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedSunset, Time.FORMAT_SHORT);
      return [
        Enumerations.SUNSET, info.hour.format("%02u").toString() + ":" +
                                 info.min.format("%02u").toString()
      ];
    } else {  // tomorrow sunrise
      var equalizedSunrise = new Time.Moment(nextSunrise + currTimeOffset);
      var info = Gregorian.utcInfo(equalizedSunrise, Time.FORMAT_SHORT);
      return [
        Enumerations.SUNRISE, info.hour.format("%02u").toString() + ":" +
                                  info.min.format("%02u").toString()
      ];
    }
  }

  // Display activity (distance)
  //
  function DisplayDistance(layout) {
    var info = ActivityMonitor.getInfo();
    var distance =
        (info != null && info.distance != null) ? info.distance.toFloat() : 0;
    var steps = (info != null && info.steps != null) ? info.steps : 0;
    var distanceValues = [
      (distance / 100000).format("%2.1f"),
      (distance / 160934.4).format("%2.1f"), steps.format("%d")
    ];
    // var distanceTitles = [ "km", "mi", "st." ];

    return [
      // distanceTitles[_settings.distanceSystem],
      Enumerations.DISTANCE, distanceValues[_settings.distanceSystem]

    ];
  }

  // Display the number of floors climbed for the current day.
  //
  function DisplayFloors(layout) {
    var info = ActivityMonitor.getInfo();
    if (info != null && info has
        : floorsClimbed && info.floorsClimbed != null) {
      return [ Enumerations.FLOORS, info.floorsClimbed.format("%d") ];
    } else {
      return [ Enumerations.FLOORS, "n/a" ];
    }
  }

  function DisplaySteps(layout) {
    var info = ActivityMonitor.getInfo();
    var steps = "n/a";
    if (info != null && info has
        : floorsClimbed && info has
        : steps && info.floorsClimbed != null && info.steps != null) {
      steps = info.steps;
      if (steps > 9999) {
        steps = (steps / 1000.0).format("%d") + "k";  // x.yk
      }
    }
    return [ Enumerations.STEPS, steps ];
  }

  // display current pulse
  //
  function DisplayPulse(layout) {
    var isUpdate = false;
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : currentHeartRate && info.currentHeartRate != null &&
              _heartRate != info.currentHeartRate) {
      _heartRate = info.currentHeartRate;
      _heartRateText = _heartRate.toString();
      isUpdate = true;
    }

    return [ Enumerations.PULSE, _heartRateText, isUpdate ];
  }

  function DisplayAltitude(layout) {
    var altitude = null;
    var info = Activity.getActivityInfo();
    if (info != null && info has : altitude && info.altitude != null) {
      altitude = info.altitude * (_settings.altimeterSystem == 0 ? 1 : 3.28084);
    }

    return [
      Enumerations.ALTITUDE, (altitude != null) ? altitude.format("%d") : "---"

    ];
  }

  // Display the number of floors climbed for the current day.
  //
  function DisplayCalories(layout) {
    var info = ActivityMonitor.getInfo();
    var calories = "n/a";
    if (info != null && info.calories != null) {
      calories = info.calories.format("%d");
    }

    return [ Enumerations.CALORIES, calories ];
  }

  // Display the calculated barometric pressure
  //
  function DisplaySensorPressure(layout) {
    var convTable = [ 0.01, 1, 0.0002953 ];  // pascals to
    var pressure = "---";
    var info = Activity.getActivityInfo();

    if (info != null && info has
        : ambientPressure && info.ambientPressure != null && info has
        : rawAmbientPressure && info.rawAmbientPressure != null && info has
        : meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
      var pressureTypes = [
        info.ambientPressure, info.rawAmbientPressure, info.meanSeaLevelPressure
      ];
      pressure = pressureTypes[_settings.sensorPressureType] *
                 convTable[_settings.barometricSystem];
      if (_settings.barometricSystem == Enumerations.PRESSURE_MILLIBAR) {
        pressure = pressure.format("%d");
      } else if (_settings.barometricSystem == Enumerations.PRESSURE_PASCAL) {
        pressure = pressure.format("%2.1f");
      } else if (_settings.barometricSystem == Enumerations.PRESSURE_INCHES) {
        pressure = pressure.format("%2.1f");
      }
    }

    return [ Enumerations.PRESSURE, pressure ];
  }

  // Display current city name based on known GPS location
  //
  function DisplayLocation(layout) {
    var city = _settings.weather._city;
    var MAX_CITY_LENGTH = 11;

    if (city.length() > MAX_CITY_LENGTH) {
      city = city.substring(0, MAX_CITY_LENGTH - 1);
      city = city + "~";
    }

    return [city];
  }

  // Display current humidity
  //
  function DisplayHumidity(layout) {
    var weather = _settings.weather;
    var val = weather._humidityPercentage + "%";

    return [ Enumerations.HUMIDITY, val ];
  }

  // Display current dew point
  //
  function DisplayDewPoint(layout) {
    var weather = _settings.weather;
    var val = weather._dewPoint;

    return [ Enumerations.DEW_POINT, val.format("%2.1f") ];
  }

  // Display current pressure
  //
  function DisplayWeatherPressure(layout) {
    var weather = _settings.weather;
    var convTable = [ 1, 100, 0.02953 ];  // millibars to
    var val = weather._baroPressureBars * convTable[_settings.barometricSystem];

    if (_settings.barometricSystem == Enumerations.PRESSURE_MILLIBAR) {
      val = val.format("%d");
    } else if (_settings.barometricSystem == Enumerations.PRESSURE_PASCAL) {
      val = val.format("%2.1f");
    } else if (_settings.barometricSystem == Enumerations.PRESSURE_INCHES) {
      val = val.format("%2.1f");
    }

    return [ Enumerations.PRESSURE, val ];
  }

  // Display wind direction
  //
  function DisplayWindDirection(layout) {
    var weather = _settings.weather;
    var val = weather._windDirection;

    return [ Enumerations.DIRECTION, val ];
  }
  // Display current UV index
  //
  function DisplayUVI(layout) {
    var weather = _settings.weather;
    var val = weather._uvIndex.format("%2.1f");

    return [ Enumerations.UV_INDEX, val ];
  }
  // Display today's precipitation probability
  //
  function DisplayTodayPrecipitation(layout) {
    var weather = _settings.weather;
    var val = weather._todayPrecipitationPercent + "%";

    return [ Enumerations.PRECIPITATION, val ];
  }

  // Display the next day's precipitation probability
  //
  function DisplayNextPrecipitation(layout) {
    var weather = _settings.weather;
    var val = weather._nextPrecipitationPercent + "%";

    return [ Enumerations.PRECIPITATION, val ];
  }

  // Display the day after next's precipitation probability
  //
  function DisplayNextNextPrecipitation(layout) {
    var weather = _settings.weather;
    var val = weather._nextNextPrecipitationPercent + "%";

    return [ Enumerations.PRECIPITATION, val ];
  }
  // Display battery and connection status
  //
  function DisplayWatchStatus(layout) {
    var stats = Sys.getSystemStats();
    var batteryLevel = (stats != null) ? (stats.battery).toNumber() : 0;

    // set red color if battery level too low
    //
    // layout["col"] = batteryLevel <= 20 ? [3] : [0];

    return [ Enumerations.ELECTRICITY, batteryLevel.format("%d") ];
  }
}