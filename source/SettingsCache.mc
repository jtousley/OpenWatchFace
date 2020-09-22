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

class SettingsCache {
  function initialize() {
    field3 = Setting.GetField(0);
    field4 = Setting.GetField(1);
    field5 = Setting.GetField(2);
    weatherField0 = Setting.GetWField(0);
    weatherField1 = Setting.GetWField(1);
    weatherField2 = Setting.GetWField(2);
    connError = Setting.GetConError();
    lastKnownLocation = Setting.GetLastKnownLocation();
    // weatherProvider = Setting.GetWeatherProvider();
    // weatherApiKey = Setting.GetOpenWeatherToken();
    weatherTempSystem = Setting.GetTempSystem();
    weatherWindSystem = Setting.GetWindSystem();
    // extraTimeZone = Setting.GetExtraTimeZone();
    // exchangeRate = Setting.GetExchangeRate();
    // targetCurrency = Setting.GetTargetCurrency();
    distanceSystem = Setting.GetDistSystem();
    altimeterSystem = Setting.GetAltimeterSystem();
    barometricSystem = Setting.GetBarometricSystem();
    // showMessage = Setting.GetShowMessage();
    // showAlarm = Setting.GetShowAlarm();
    dateOrder = Setting.GetDateOrder();
    // isShowMoon = Setting.GetShowMoon();
    InitializeWeather();
  }

 public
  function InitializeWeather() {
    var weatherArray = Setting.GetWeatherStorage();
    weather = new Weather();
    if (weatherArray != null && weatherArray has
        : size && weatherArray.size() == Enumerations.WVAL_SIZE) {
      InterpretWeatherData(weatherArray);
    }
  }

 public
  function UpdateWeather(data) { Setting.SetWeatherStorage(data); }

 protected
  function InterpretWeatherData(weatherArray) {
    weather._city = Setting.GetWeatherCityStorage();
    weather._tempCelcius = weatherArray[Enumerations.WVAL_CURR_TEMP];
    weather._feelsTempCelcius = weatherArray[Enumerations.WVAL_FEEL_TEMP];
    weather._baroPressureBars = weatherArray[Enumerations.WVAL_PRESS];
    weather._humidityPercentage = weatherArray[Enumerations.WVAL_HUM];
    weather._windSpeedMeterSeconds = weatherArray[Enumerations.WVAL_WIND_S];
    weather._windDirection = weatherArray[Enumerations.WVAL_WIND_D];
    weather._uvIndex = weatherArray[Enumerations.WVAL_UV];
    weather._sunriseTime = weatherArray[Enumerations.WVAL_SUNRISE];
    weather._sunsetTime = weatherArray[Enumerations.WVAL_SUNSET];
    weather._nextSunriseTime = weatherArray[Enumerations.WVAL_N_SUNRISE];
    weather._dewPoint = weatherArray[Enumerations.WVAL_DEW];
    weather._currentId = weatherArray[Enumerations.WVAL_CURR_ID];
    weather._weatherDateTime = weatherArray[Enumerations.WVAL_DT];
    weather._minTempCelcius = weatherArray[Enumerations.WVAL_T_MIN];
    weather._maxTempCelcius = weatherArray[Enumerations.WVAL_T_MAX];
    weather._todayPrimaryId = weatherArray[Enumerations.WVAL_T_ID];
    weather._todayCloudPercent = weatherArray[Enumerations.WVAL_T_CLOUD];
    weather._todayPrecipitationPercent = weatherArray[Enumerations.WVAL_T_POP];
    weather._nextMinTempCelcius = weatherArray[Enumerations.WVAL_N_MIN];
    weather._nextMaxTempCelcius = weatherArray[Enumerations.WVAL_N_MAX];
    weather._nextPrimaryId = weatherArray[Enumerations.WVAL_N_ID];
    weather._nextCloudPercent = weatherArray[Enumerations.WVAL_N_CLOUD];
    weather._nextPrecipitationPercent = weatherArray[Enumerations.WVAL_N_POP];
    weather._nextNextMinTempCelcius = weatherArray[Enumerations.WVAL_NN_MIN];
    weather._nextNextMaxTempCelcius = weatherArray[Enumerations.WVAL_NN_MAX];
    weather._nextNextPrimaryId = weatherArray[Enumerations.WVAL_NN_ID];
    weather._nextNextCloudPercent = weatherArray[Enumerations.WVAL_NN_CLOUD];
    weather._nextNextPrecipitationPercent =
        weatherArray[Enumerations.WVAL_NN_POP];
  }

 public
  var field3;
 public
  var field4;
 public
  var field5;
 public
  var weatherField0;
 public
  var weatherField1;
 public
  var weatherField2;
 public
  var connError;
 public
  var weather;
 public
  var lastKnownLocation;
  //  public
  //   var weatherProvider;
  //  public
  //   var weatherApiKey;
 public
  var weatherTempSystem;
 public
  var weatherWindSystem;
  //  public
  //   var extraTimeZone;
  //  public
  //   var exchangeRate;
  //  public
  //   var targetCurrency;
 public
  var distanceSystem;
 public
  var altimeterSystem;
 public
  var barometricSystem;
 public
  var dateOrder;
}