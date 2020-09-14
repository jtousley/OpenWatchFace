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
using Toybox.WatchUi as Ui;
using Toybox.Background as Background;
using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Lang as Lang;
using Toybox.Time as Time;

( : background) class OpenWatchFaceApp extends App.AppBase {
 protected
  var _watchFaceView;
 protected
  var _settingsCache;
  static protected var _singleton;

  function initialize() {
    AppBase.initialize();
    _singleton = self;
  }

  function setSettings(settings) { _settingsCache = settings; }

  static public function getOpenWatchFaceApp() { return _singleton; }

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
    Ui.requestUpdate();
  }

  function onBackgroundData(data) {
    Sys.println("onBackgroundData");
    try {
      if (data != null && data has : toString) {
        var weatherArray = convertReceivedData(data);
        data = null;
        _settingsCache.UpdateWeather(weatherArray);
        _settingsCache.InitializeWeather();

        // lastEventTime
        Setting.SetLastEventTime(Time.now().value());

        Ui.requestUpdate();  // ->onUpdate()
      }
    } catch (ex) {
      Sys.println(ex.getErrorMessage());
      Sys.println(ex.printStackTrace());
    }
  }

  function getServiceDelegate() { return [new BackgroundServiceDelegate()]; }

  function InitBackgroundEvents() {
    Setting.SetConError(false);
    // var time = System.getClockTime();
    // Sys.println(Lang.format("callback happened $1$:$2$:$3$", [time.hour,
    // time.min, time.sec]));

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
    // var token = Setting.GetOpenWeatherToken() + Setting.GetWeatherProvider();
    // if (!token.equals(Setting.GetWeatherRefreshToken())) {
    //   Setting.SetWeatherRefreshToken(token);
    // }
  }

  function convertReceivedData(data) {
    // Sys.println("on bg data : " + data.toString());

    var weatherArray = [];

    // if (data has : hasKey && data["event_null"] != null) {
    //   Setting.SetTextColor(data["event_null"]);
    // }

    if (data has : hasKey && data["city"] != null) {
      Setting.SetWeatherCityStorage(data["city"]);
    }

    if (data has : hasKey && data["curr_temp"] != null) {
      weatherArray.add(data["curr_temp"]);
    }

    if (data has : hasKey && data["feels_temp"] != null) {
      weatherArray.add(data["feels_temp"]);
    }

    if (data has : hasKey && data["pressure"] != null) {
      weatherArray.add(data["pressure"]);
    }

    if (data has : hasKey && data["humidity"] != null) {
      weatherArray.add(data["humidity"]);
    }

    if (data has : hasKey && data["wind_speed"] != null) {
      weatherArray.add(data["wind_speed"]);
    }

    if (data has : hasKey && data["wind_deg"] != null) {
      weatherArray.add(data["wind_deg"]);
    }

    if (data has : hasKey && data["uvi"] != null) {
      weatherArray.add(data["uvi"]);
    }

    if (data has : hasKey && data["sunrise"] != null) {
      weatherArray.add(data["sunrise"]);
    }

    if (data has : hasKey && data["sunset"] != null) {
      weatherArray.add(data["sunset"]);
    }

    if (data has : hasKey && data["dew_point"] != null) {
      weatherArray.add(data["dew_point"]);
    }

    if (data has : hasKey && data["current_id"] != null) {
      weatherArray.add(data["current_id"]);
    }

    if (data has : hasKey && data["dt"] != null) {
      weatherArray.add(data["dt"]);
    }

    // TODAY

    if (data has : hasKey && data["today_min"] != null) {
      weatherArray.add(data["today_min"]);
    }

    if (data has : hasKey && data["today_max"] != null) {
      weatherArray.add(data["today_max"]);
    }

    if (data has : hasKey && data["today_id"] != null) {
      weatherArray.add(data["today_id"]);
    }

    if (data has : hasKey && data["today_clouds"] != null) {
      weatherArray.add(data["today_clouds"]);
    }

    if (data has : hasKey && data["today_clouds"] != null) {
      weatherArray.add(data["today_pop"]);
    }

    // NEXT DAY

    if (data has : hasKey && data["next_min"] != null) {
      weatherArray.add(data["next_min"]);
    }

    if (data has : hasKey && data["next_max"] != null) {
      weatherArray.add(data["next_max"]);
    }

    if (data has : hasKey && data["next_id"] != null) {
      weatherArray.add(data["next_id"]);
    }

    if (data has : hasKey && data["next_clouds"] != null) {
      weatherArray.add(data["next_clouds"]);
    }

    if (data has : hasKey && data["next_pop"] != null) {
      weatherArray.add(data["next_pop"]);
    }

    // NEXT NEXT DAY

    if (data has : hasKey && data["nextNext_min"] != null) {
      weatherArray.add(data["nextNext_min"]);
    }

    if (data has : hasKey && data["nextNext_max"] != null) {
      weatherArray.add(data["nextNext_max"]);
    }

    if (data has : hasKey && data["nextNext_id"] != null) {
      weatherArray.add(data["nextNext_id"]);
    }

    if (data has : hasKey && data["nextNext_clouds"] != null) {
      weatherArray.add(data["nextNext_clouds"]);
    }

    if (data has : hasKey && data["nextNext_pop"] != null) {
      weatherArray.add(data["nextNext_pop"]);
    }

    return weatherArray;
  }
}