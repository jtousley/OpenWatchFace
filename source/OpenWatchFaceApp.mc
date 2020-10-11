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

using Toybox.Application as App;
using Toybox.Background as Background;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.StringUtil;

( : background) class OpenWatchFaceApp extends App.AppBase {
 protected
  var _watchFaceView;
 protected
  var _settingsCache;
  static protected var _singleton;
 protected
  var _lastLocation = [];
 protected
  var _appid = null;
  var _received = null;

  function initialize() {
    AppBase.initialize();
    _singleton = self;
  }

  function setSettings(settings) { _settingsCache = settings; }

  static public function getOpenWatchFaceApp() { return _singleton; }

  ( : debug) function printMessage(msg) { Sys.println(msg); }

  ( : production) function printMessage(msg) {}

  // Return the initial view of your application here
  //
  function getInitialView() {
    _watchFaceView = new WatchFaceView();

    baseInitApp();

    InitBackgroundEvents();

    return [ _watchFaceView, new PowerBudgetDelegate() ];
  }

  // New app settings have been received so trigger a UI update
  //
  function onSettingsChanged() {
    baseInitApp();
    InitBackgroundEvents();
    _watchFaceView.InvalidateLayout();
    Toybox.WatchUi.requestUpdate();
  }

  function onBackgroundData(data) {
    // Sys.println("onBackgroundData");

    if (data != null && data has
        : size && data.size() == Enumerations.WVAL_SIZE) {
      if (data[Enumerations.WVAL_ERROR] instanceof
          Number && data[Enumerations.WVAL_ERROR] == 200) {
        // printMessage("Got new weather data");
        setWeatherData(data);
      } else {
        _settingsCache.weather._errorCode = data[Enumerations.WVAL_ERROR];
      }
    }
  }

  function setWeatherData(data) {
    // Sys.println("Data valid : " + data.toString());
    if (data[Enumerations.WVAL_CITY_NAME] instanceof String) {
      data[Enumerations.WVAL_CITY_NAME] =
          makeCityNameInternational(data[Enumerations.WVAL_CITY_NAME]);
    }
    _settingsCache.UpdateWeather(data);
    _settingsCache.InitializeWeather();
    // lastEventTime
    var now = Time.now().value();
    Setting.SetLastEventTime(now);
  }

  function getServiceDelegate() { return [new BackgroundServiceDelegate()]; }

  function InitBackgroundEvents() {
    var FIVE_MINUTES = new Toybox.Time.Duration(5 * 60);

    var lastTime = Background.getLastTemporalEventTime();
    if (lastTime != null) {
      var nextTime = lastTime.add(FIVE_MINUTES);
      Background.registerForTemporalEvent(nextTime);
    } else {
      Background.registerForTemporalEvent(Time.now());
    }
  }

  function baseInitApp() {
    // Set base configuraton for displayed fiels
    //
    Setting.SetPulseField(4);
    // Setting.SetIsShowExchangeRate(false);
    for (var i = 0; i < 3; i++) {
      if (Setting.GetField(i) == 0) {  // DisplayPulse is 0
        Setting.SetPulseField(i);
      }
    }

    _settingsCache.initialize();

    // if DarkSky API key wrong switch back to OpenWeather
    //
    // if (Setting.GetWeatherApiKey().length() != 32) {
    //   Setting.SetWeatherProvider(0);
    // }

    // update weather
    //
    // var token = Setting.GetOpenWeatherToken() +
    // Setting.GetWeatherProvider(); if
    // (!token.equals(Setting.GetWeatherRefreshToken())) {
    //   Setting.SetWeatherRefreshToken(token);
    // }
  }

  function makeCityNameInternational(city) {
    // Sys.println("city : " + city);

    var cityArray = city.toCharArray();
    // var byteArray = StringUtil.convertEncodedString(city, options);
    var internationalName = new[cityArray.size()];
    for (var i = 0; i < cityArray.size(); i++) {
      var num = cityArray[i].toNumber();
      if (num > 255) {
        num = 95;  // Underscore '_'
      }
      internationalName[i] = num.toChar();
    }
    // Sys.println("array : " + cityArray);
    // Sys.println("bytes : " + internationalName);
    // Sys.println("Name : " + StringUtil.charArrayToString(internationalName));
    // Sys.println("Int name : " +
    return StringUtil.charArrayToString(internationalName);
  }
}