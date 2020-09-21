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

using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.Time as Time;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.
//
( : background) class BackgroundServiceDelegate extends Sys.ServiceDelegate {
 protected
  var _received = null;
  var _lastLocation = [];
  var _lastLocationData = null;
  var _locationKey = null;
  var _appid = null;

  function initialize() { Sys.ServiceDelegate.initialize(); }

  function onTemporalEvent() {
    var doUpdate = false;
    try {
      var now = new Time.Moment(Time.now().value());
      var lastEventTime = Setting.GetLastEventTime();
      var lastWeather = Setting.GetWeatherStorage();
      if (lastEventTime == null || lastWeather == null ||
          (lastWeather has
           : size && lastWeather.size() == 0)) {
        doUpdate = true;
      } else {
        var ONE_HOUR = new Time.Duration(60 * 60);
        var lastEvent = new Time.Moment(lastEventTime);
        var nextUpdate = lastEvent.add(ONE_HOUR);
        if (nextUpdate.lessThan(now)) {
          Sys.println("Update time : " + nextUpdate.value());
          Sys.println("Now : " + now.value());
          doUpdate = true;
        } else {
          Sys.println("Not enough time elapsed");
        }
      }
      lastEventTime = null;
      lastWeather = null;

    } catch (ex) {
      if (ex has : getErrorMessage) {
        Sys.println(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        Sys.println(ex.printStackTrace());
      }
    }
    _received = {};
    if (doUpdate) {
      _received["isErr"] = true;
      RequestUpdate();
    }
  }

  function RequestAccuWeatherLocation() {
    var apiParam =
        Lang.format("apikey=$1$", [Setting.GetAccuWeatherToken()
                                      // Setting.GetOpenWeatherToken()
    ]);
    var url = Lang.format(
        "https://dataservice.accuweather.com/locations/v1/cities/geoposition/" +
            "search?$3$&q=$1$%2C%20$2$",
        [ _lastLocation[0], _lastLocation[1], apiParam ]);
    Sys.println("URL : " + url);
    var options = {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      };

    Comm.makeWebRequest(url, {}, options, method( : RequestAccuWeatherData));
  }

  function RequestAccuWeatherData(responseCode, data) {
    if (responseCode == 200) {
      if (data != null && data has : hasKey && data.hasKey("Key")) {
        _locationKey = data.get("Key");
        _lastLocationData = data;
      }

      if (_locationKey != null) {
        var apiParam =
            Lang.format("apikey=$1$", [Setting.GetAccuWeatherToken()
                                          // Setting.GetOpenWeatherToken()
        ]);
        var url = Lang.format(
            "https://dataservice.accuweather.com/currentconditions/v1/" +
                "$1$?$2$&details=true",
            [ _locationKey, apiParam ]);
        Sys.println("URL2 : " + url);
        var options = {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      };

        Comm.makeWebRequest(url, {}, options,
                            method(
                                : OnReceiveOpenWeatherUpdate));
      }
    } else {
      // _received.put("isErr", true);
      _received["isErr"] = true;
    }
  }

  function RequestOpenWeather() {
    var url = "https://api.openweathermap.org/data/2.5/weather";

    Sys.println("Location : " + _lastLocation[0] + ", " + _lastLocation[1]);

    Comm.makeWebRequest(url, 
      // PARAMS
      {     "lat" => _lastLocation[0],
            "lon" => _lastLocation[1],
            "units" => "metric",
            "cnt" => 1,
            "appid" =>  _appid
      },
      // OPTIONS
      {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      },
      method( : OnReceiveOpenLocationUpdate));
  }

  function RequestOpenWeatherData() {
    var url = "https://api.openweathermap.org/data/2.5/onecall";
    Sys.println("Requesting data");

    Comm.makeWebRequest(url, 
    // PARAMS
    {     "lat" => _lastLocation[0],
          "lon" => _lastLocation[1],
          "exclude" => "minutely,hourly",
          "cnt" => 3,
          "units" => "metric",
          "appid" =>  _appid
    },
    // OPTIONS
     {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      },
       method( : OnReceiveOpenWeatherUpdate));
  }

  function RequestUpdate() {
    // Sys.println("RequestUpdate - Memory: " + Sys.getSystemStats().usedMemory
    // +
    //             "/" + Sys.getSystemStats().totalMemory + ":" +
    //             Sys.getSystemStats().freeMemory);
    var data = {};
    try {
      // var weatherProviders = ["OpenWeather", "DarkSky"];
      // var weatherApiKey = Setting.GetWeatherApiKey();
      // var weatherProvider = Setting.GetWeatherProvider();
      var location = Setting.GetLastKnownLocation();
      _appid = Setting.GetOpenWeatherToken();
      Sys.println("Appid : " + _appid);
      if (location == null) {
        Sys.println("Could not get location");
      } else if (_appid == null || _appid == "") {
        Sys.println("Invalid key");
      } else if (false) {  // Accuweather
        if (location != _lastLocation) {
          _lastLocation = location;
          RequestAccuWeatherLocation();
        } else {
          RequestAccuWeatherData(200, _lastLocationData);
        }
      } else {
        _lastLocation = location;
        // RequestOpenWeatherLocation();
        // RequestOpenWeatherData();
        RequestOpenWeather();
      }
    } catch (ex) {
      if (ex has : getErrorMessage) {
        Sys.println(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        Sys.println(ex.printStackTrace());
      }
    }
  }

  function OnReceiveOpenLocationUpdate(responseCode, data) {
    Sys.println("OnReceiveOpenLocationUpdate - Memory: " +
                Sys.getSystemStats().usedMemory + "/" +
                Sys.getSystemStats().totalMemory + ":" +
                Sys.getSystemStats().freeMemory);
    try {
      if (responseCode != 200) {
        _received["isErr"] = true;
        Sys.println("API calls exceeded : " + responseCode);
        if (data != null) {
          Sys.println("Data : " + data);
        } else {
          Sys.println("null");
        }
      } else {
        if (data == null) {
          Sys.println("Failed to get response from weather service");
        }
        _received["city"] = data["name"];
      }
    } catch (ex) {
      _received["isErr"] = true;
      if (ex has : getErrorMessage) {
        Sys.println(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        Sys.println(ex.printStackTrace());
      }
    }
    RequestOpenWeatherData();
  }

  function OnReceiveOpenWeatherUpdate(responseCode, data) {
    // Sys.println("OnReceiveOpenWeatherUpdate");
    try {
      if (responseCode != 200) {
        _received["isErr"] = true;
        Sys.println("API calls exceeded : " + responseCode);
        if (data != null) {
          Sys.println("Data : " + data);
        } else {
          Sys.println("null");
        }
      } else {
        ParseReceivedData(data);
        data = null;
      }
    } catch (ex) {
      _received["isErr"] = true;
      if (ex has : getErrorMessage) {
        Sys.println(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        Sys.println(ex.printStackTrace());
      }
    }
    try {
      Background.exit(_received);
    } catch (ex) {
      if (ex has : getErrorMessage) {
        Sys.println(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        Sys.println(ex.printStackTrace());
      }
    }
    _received = null;
  }

  function ParseReceivedData(data) {
    _received["isErr"] = false;
    try {
      if (data != null) {
        if (data.hasKey("isErr")) {
          Sys.println("onBackgroundData: Error");
          Setting.SetConError(true);
        } else {
          // Sys.println("Data: " + data.toString());

          _received["curr_temp"] = ((data has
                                     : hasKey) &&
                                            (data["current"] != null) &&
                                            (data["current"]["temp"] != null)
                                        ? data["current"]["temp"]
                                        : 0);

          _received["feels_temp"] =
              ((data has
                : hasKey) &&
                       (data["current"] != null) &&
                       (data["current"]["feels_like"] != null)
                   ? data["current"]["feels_like"]
                   : 0);

          _received["pressure"] = ((data has
                                    : hasKey) &&
                                           (data["current"] != null) &&
                                           (data["current"]["pressure"] != null)
                                       ? data["current"]["pressure"]
                                       : 0);

          _received["humidity"] = ((data has
                                    : hasKey) &&
                                           (data["current"] != null) &&
                                           (data["current"]["humidity"] != null)
                                       ? data["current"]["humidity"]
                                       : 0);

          _received["wind_speed"] =
              ((data has
                : hasKey) &&
                       (data["current"] != null) &&
                       (data["current"]["wind_speed"] != null)
                   ? data["current"]["wind_speed"]
                   : 0);

          _received["wind_deg"] = ((data has
                                    : hasKey) &&
                                           (data["current"] != null) &&
                                           (data["current"]["wind_deg"] != null)
                                       ? data["current"]["wind_deg"]
                                       : 0);

          _received["uvi"] = ((data has
                               : hasKey) &&
                                      (data["current"] != null) &&
                                      (data["current"]["uvi"] != null)
                                  ? data["current"]["uvi"]
                                  : 0);

          _received["sunrise"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["sunrise"] != null)
                   ? data["daily"][0]["sunrise"]
                   : 0);

          _received["sunset"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["sunset"] != null)
                   ? data["daily"][0]["sunset"]
                   : 0);

          _received["dew_point"] =
              ((data has
                : hasKey) &&
                       (data["current"] != null) &&
                       (data["current"]["dew_point"] != null)
                   ? data["current"]["dew_point"]
                   : 0);

          _received["current_id"] =
              ((data has
                : hasKey) &&
                       (data["current"] != null) &&
                       (data["current"]["weather"] != null) &&
                       (data["current"]["weather"].size() > 0) &&
                       (data["current"]["weather"][0]["id"] != null)
                   ? data["current"]["weather"][0]["id"].toNumber()
                   : 0);

          _received["dt"] = ((data has
                              : hasKey) &&
                                     (data["current"] != null) &&
                                     (data["current"]["dt"] != null)
                                 ? data["current"]["dt"]
                                 : 0);

          _received["today_min"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["temp"] != null) &&
                       (data["daily"][0]["temp"]["min"] != null)
                   ? data["daily"][0]["temp"]["min"]
                   : 0);

          _received["today_max"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["temp"] != null) &&
                       (data["daily"][0]["temp"]["max"] != null)
                   ? data["daily"][0]["temp"]["max"]
                   : 0);

          _received["today_id"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["weather"] != null) &&
                       (data["daily"][0]["weather"].size() > 0) &&
                       (data["daily"][0]["weather"][0]["id"] != null)
                   ? data["daily"][0]["weather"][0]["id"].toNumber()
                   : 0);

          _received["today_clouds"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["clouds"] != null)
                   ? data["daily"][0]["clouds"]
                   : 0);

          _received["today_pop"] =  // probability of precipitation
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 0) &&
                       (data["daily"][0]["pop"] != null)
                   ? data["daily"][0]["pop"]
                   : 0);

          _received["next_min"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) &&
                       (data["daily"].size() > 1 &&
                        data["daily"][1]["temp"] != null &&
                        data["daily"][1]["temp"]["min"] != null)
                   ? data["daily"][1]["temp"]["min"]
                   : 0);

          _received["next_max"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) &&
                       (data["daily"].size() > 1 &&
                        data["daily"][1]["temp"] != null &&
                        data["daily"][1]["temp"]["max"] != null)
                   ? data["daily"][1]["temp"]["max"]
                   : 0);

          _received["next_id"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 1) &&
                       (data["daily"][1]["weather"] != null) &&
                       (data["daily"][1]["weather"].size() > 0) &&
                       (data["daily"][1]["weather"][0]["id"] != null)
                   ? data["daily"][1]["weather"][0]["id"].toNumber()
                   : 0);

          _received["next_clouds"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 1) &&
                       (data["daily"][1]["clouds"] != null)
                   ? data["daily"][1]["clouds"]
                   : 0);

          _received["next_pop"] =  // probability of precipitation
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 1) &&
                       (data["daily"][1]["pop"] != null)
                   ? data["daily"][1]["pop"]
                   : 0);

          _received["nextSunrise"] =  // tomorrow sunrise
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 1) &&
                       (data["daily"][1]["sunrise"] != null)
                   ? data["daily"][1]["sunrise"]
                   : 0);

          // NEXT NEXT DAY

          _received["nextNext_min"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 2) &&
                       (data["daily"][2]["temp"] != null) &&
                       (data["daily"][2]["temp"]["min"] != null)
                   ? data["daily"][2]["temp"]["min"]
                   : 0);

          _received["nextNext_max"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 2) &&
                       (data["daily"][2]["temp"] != null) &&
                       (data["daily"][2]["temp"]["max"] != null)
                   ? data["daily"][2]["temp"]["max"]
                   : 0);

          _received["nextNext_id"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 2) &&
                       (data["daily"][2]["weather"] != null) &&
                       (data["daily"][2]["weather"].size() > 0) &&
                       (data["daily"][2]["weather"][0]["id"] != null)
                   ? data["daily"][2]["weather"][0]["id"].toNumber()
                   : 0);

          _received["nextNext_clouds"] =
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 2) &&
                       (data["daily"][2]["clouds"] != null)
                   ? data["daily"][2]["clouds"]
                   : 0);

          _received["nextNext_pop"] =  // probability of precipitation
              ((data has
                : hasKey) &&
                       (data["daily"] != null) && (data["daily"].size() > 2) &&
                       (data["daily"][2]["pop"] != null)
                   ? data["daily"][2]["pop"]
                   : 0);
        }
      }
    } catch (ex) {
      _received["isErr"] = true;
      if (ex has : getErrorMessage) {
        Sys.println(ex.getErrorMessage());
      }
      if (ex has : printStackTrace) {
        Sys.println(ex.printStackTrace());
      }
    }
  }
}