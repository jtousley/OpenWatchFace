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

using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;

class WatchFaceView extends Toybox.WatchUi.WatchFace {
 protected
  var _layouts = [];
 protected
  var _fonts = [
    WatchUi.loadResource(Rez.Fonts.latoBlack_tiny),
    WatchUi.loadResource(Rez.Fonts.latoBlack_small),
    WatchUi.loadResource(Rez.Fonts.latoBlack_medium),
    WatchUi.loadResource(Rez.Fonts.latoBlack_large),
    WatchUi.loadResource(Rez.Fonts.small_icons),
    WatchUi.loadResource(Rez.Fonts.large_icons)
  ];

 protected
  var _funcs = [:DisplayLocation               // = 0
                , :DisplayDate                 // = 1
                , :DisplayTime                 // = 2
                , :DisplayPmAm                 // = 3 // TODO: Remove
                , :DisplaySeconds              // = 4
                , :DisplayCurrentTemp          // = 5
                , :DisplayFeelsTemp            // = 6
                , :DisplayTodayMaxTemp         // = 7
                , :DisplayTodayMinTemp         // = 8
                , :DisplayNextMaxTemp          // = 9
                , :DisplayNextMinTemp          // = 10
                , :DisplayNextNextMaxTemp      // = 11
                , :DisplayNextNextMinTemp      // = 12
                , :DisplayThirdMaxTemp         // = 13
                , :DisplayThirdMinTemp         // = 14
                , :DisplayWeatherOption1       // = 15
                , :DisplayWeatherOption2       // = 16
                , :DisplayWeatherOption3       // = 17
                , :DisplayTodayWeatherIcon     // = 18
                , :DisplayNextWeatherIcon      // = 19
                , :DisplayNextNextWeatherIcon  // = 20
                , :DisplayThirdWeatherIcon     // = 21 // TODO: Remove
                , :DisplayCurrWeatherIcon      // = 22
                , :LoadField3                  // = 23
                , :LoadField4                  // = 24
                , :LoadField5                  // = 25
                , :DisplayWatchStatus          // = 26
                , :DisplayBottomLine           // = 27
                , :DisplayTopLine              // = 28
                // , :DisplayWeekDayNumbers       // = 29
  ];

 protected
  var _wfApp;
 protected
  var _displayFunctions = new DisplayFunctions();
 protected
  var _colors;
 protected
  var _lastBg = null;
 protected
  var _bgInterval = new Toybox.Time.Duration(59 * 60);  // one hour
 protected
  var _settingsCache = new SettingsCache();
 protected
  var _inLowPower = false;
 protected
  var _canBurnIn = false;
 protected
  var _aodIndex = 0;
 protected
  var _horizLine = null;
 protected
  var _vertLine = null;

  ( : debug) function loadApiKey() {
    var openWeatherToken =
        WatchUi.loadResource(Rez.Strings.OpenWeatherApiKeyValue);
    if (openWeatherToken != null && openWeatherToken has
        : length && openWeatherToken.length() > 0) {
      Setting.SetOpenWeatherToken(openWeatherToken);
    }
  }
  ( : production) function loadApiKey() {}

  function initialize() {
    WatchFace.initialize();
    _wfApp = OpenWatchFaceApp.getOpenWatchFaceApp();

    _wfApp.setSettings(_settingsCache);
    _displayFunctions.setSettings(_settingsCache);
    _displayFunctions.setFonts(_fonts);

    Setting.SetAppVersion(WatchUi.loadResource(Rez.Strings.AppVersionValue));
    // Setting.SetWatchServerToken(WatchUi.loadResource(Rez.Strings.WatchServerTokenValue));
    // Setting.SetExchangeApiKey(WatchUi.loadResource(Rez.Strings.ExchangeApiKeyValue));

    loadApiKey();

    var sSettings = Sys.getDeviceSettings();
    if (sSettings has : requiresBurnInProtection) {
      _canBurnIn = sSettings.requiresBurnInProtection;
    }
    // Setting.SetAccuWeatherToken(
    //     WatchUi.loadResource(Rez.Strings.AccuWeatherApiKeyValue));
  }

  // Load your resources here
  //
  function onLayout(dc) { InvalidateLayout(); }

  // calls every second for partial update
  //
  function onPartialUpdate(dc) {
    if (_settingsCache.showSeconds) {
      dc.setColor(_colors[_settingsCache.textColor],
                  _colors[_settingsCache.backgroundColor]);
      var font = _fonts[Enumerations.FONT_SMALL];
      dc.drawText(_layouts[Enumerations.LAYOUT_SEC]["x"][0],
                  _layouts[Enumerations.LAYOUT_SEC]["y"][0], font,
                  Sys.getClockTime().sec.format("%02d"),
                  _layouts[Enumerations.LAYOUT_SEC]["jus"][0]);
    }

    if (_settingsCache.pulseField < 3) {
      var layout =
          _layouts[Enumerations.LAYOUT_FIELD_3 + _settingsCache.pulseField];
      var pulseData = _displayFunctions.DisplayPulse(layout);
      if (pulseData[2]) {
        dc.setColor(_colors[_settingsCache.textColor],
                    _colors[_settingsCache.backgroundColor]);
        var font = _fonts[Enumerations.FONT_SMALL];
        dc.drawText(layout["x"][1], layout["y"][1],
                    // layout["font"][1],
                    font, pulseData[1], layout["jus"][1]);
      }
    }
  }

  // No preprocessor???
  ( : debug) function onUpdateHelper(dc) { onPartialUpdate(dc); }

  // No preprocessor???
  ( : production) function onUpdateHelper(dc) {}

  // Update the view
  //
  function onUpdate(dc) {
    onUpdateHelper(dc);

    _displayFunctions.setTime(Time.now());
    _displayFunctions.setDisplayContext(dc);

    var info = Activity.getActivityInfo();

    if (info != null && info.currentLocation != null) {
      var location = info.currentLocation.toDegrees();
      if (location[0] != 0.0 && location[1] != 0.0) {
        Setting.SetLastKnownLocation(location);
      }
    }

    /// fire background process if needed
    ///
    if (_lastBg == null) {
      _lastBg = new Time.Moment(Time.now().value());
    } else if (_lastBg.add(_bgInterval)
                   .lessThan(new Time.Moment(Time.now().value()))) {
      _lastBg = new Time.Moment(Time.now().value());
      _wfApp.InitBackgroundEvents();
    }

    // dc.clearClip();
    dc.setColor(Gfx.COLOR_TRANSPARENT, _colors[_settingsCache.backgroundColor]);
    dc.clear();

    for (var i = 0; i < _layouts.size(); i++) {
      // handle AMOLED (Venu) devices' low power
      if (_inLowPower && _canBurnIn && i != Enumerations.LAYOUT_TIME) {
        continue;
      }

      var funcs = null;
      if (_displayFunctions has _funcs[_layouts[i]["func"]]) {
        funcs = _displayFunctions.method(_funcs[_layouts[i]["func"]])
                    .invoke(_layouts[i]);
      } else {
        continue;
      }

      for (var j = 0; j < _layouts[i]["x"].size(); j++) {
        // Do not display layout elements with "hide" property set
        if (_layouts[i]["hide"] != null && _layouts[i]["hide"][j] == 1) {
          continue;
        }

        var color = _colors[_layouts[i]["col"][j]];
        if (_layouts[i] has : hasKey && _layouts[i].hasKey("type")) {
          if (_layouts[i]["type"][j] == Enumerations.TYPE_TEXT) {  // text color
            color = _colors[_settingsCache.textColor];
          } else if (_layouts[i]["type"][j] ==
                     Enumerations.TYPE_ICON) {  // icon color
            color = _colors[_settingsCache.iconColor];
          }
        }
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);

        var x = _layouts[i]["x"][j];
        var y = _layouts[i]["y"][j];
        var font = _layouts[i]["font"][j] < 100
                       ? _layouts[i]["font"][j]
                       : _fonts[_layouts[i]["font"][j] - 100];
        var text = funcs[j];
        var justification = _layouts[i]["jus"][j];

        // handle AMOLED (Venu) devices' low power
        if (_inLowPower && _canBurnIn) {
          // WTF are you doing here?
          // There are 3 items to move around on the screen,
          // So there are 6 elements in the array -
          // 3 for the position of each at each position
          var yArray = [ y - 200, y - 200, y - 200, y - 80, y - 80, y - 80 ];
          y = yArray[_aodIndex];
          _aodIndex = _aodIndex + 1;
          if (_aodIndex == 6) {
            _aodIndex = 0;
          }
        }

        dc.drawText(x, y, font, text, justification);
      }
    }

    //         Burn    Low_Power
    // show    0       0
    // show    0       1
    // show    1       0
    // hide    1       1
    if (!(_inLowPower && _canBurnIn)) {
      if (_horizLine != null && _vertLine != null && _colors != null &&
          _settingsCache.textColor != null) {
        dc.setPenWidth(2);
        dc.setColor(_colors[_settingsCache.textColor], Gfx.COLOR_TRANSPARENT);
        dc.drawLine(_horizLine["x"][0], _horizLine["y"][0], _horizLine["x"][1],
                    _horizLine["y"][1]);

        dc.drawLine(_vertLine["x"][0], _vertLine["y"][0], _vertLine["x"][1],
                    _vertLine["y"][1]);
      }
    }
  }

  function onHide() {}
  function onShow() {}

  function onExitSleep() {
    _inLowPower = false;
    WatchUi.requestUpdate();
  }

  function onEnterSleep() {
    _inLowPower = true;
    WatchUi.requestUpdate();
  }

  function InvalidateLayout() {
    _colors = [
      0x000000,  // 0 - Enumerations.ColorBlack
      0x555555,  // 1 - Enumerations.ColorDarkGray
      0xAAAAAA,  // 2 - Enumerations.ColorLightGray
      0xFFFFFF,  // 3 - Enumerations.ColorWhite
      0x0000FF,  // 4 - Enumerations.ColorBlue
      0xFF0000,  // 5 - Enumerations.ColorRed
      0x32CD32,  // 6 - Enumerations.ColorLimeGreen
      0x00FF00,  // 7 - Enumerations.ColorLime
      0xD2FF0C,  // 8 - Enumerations.ColorYellowGreen
      0xC8FFBF,  // 9 - Enumerations.ColorPaleGreen
      0xB5EBFF,  // 10 - Enumerations.ColorPaleBlue
      0xFFD3D9,  // 11 - Enumerations.ColorPink
      0x00F6FF,  // 12 - Enumerations.ColorAqua
      0xFFFF00,  // 13 - Enumerations.ColorYellow
      0xFFFF66,  // 14 - Enumerations.ColorPaleYellow
      0xFF422D,  // 15 - Enumerations.ColorYellowRed
      0xF88E46   // 16 - Enumerations.ColorOrange
    ];

    _layouts = [];

    _layouts.add(
        WatchUi.loadResource(Rez.JsonData.l_city_left));  // DisplayLocation  0
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_date));  // DisplayDate  1
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_time));  // DisplayTime  2
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_pmam));  // DisplayPmAm  3
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_sec));  // DisplaySeconds 4
    _layouts.add(
        WatchUi.loadResource(Rez.JsonData.l_currTemp));  // DisplayCurrentTemp 5
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_currFeelsTemp));  // DisplayFeelsTemp 6
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_todayMaxTemp));  // DisplayTodayMaxTemp 7
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_todayMinTemp));  // DisplayTodayMinTemp 8
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_nextMaxTemp));  // DisplayNextMaxTemp 9
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_nextMinTemp));  // DisplayNextMinTemp 10
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_nn_maxTemp));  // DisplayNextNextMaxTemp       11
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_nn_minTemp));  // DisplayNextNextMinTemp       12
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_thd_maxTemp));  // DisplayThirdMaxTemp 13
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_thd_minTemp));  // DisplayThirdMinTemp 14
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_weatherOption1));  // DisplayWeatherOption1        15
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_weatherOption2));  // DisplayWeatherOption2        16
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_weatherOption3));  // DisplayWeatherOption3        17
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_t_weatherIcon));  // DisplayTodayWeatherIcon      18
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_n_weatherIcon));  // DisplayNextWeatherIcon = 19
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_nn_weatherIcon));  // DisplayNextNextWeatherIcon   20
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_thirdWeatherIcon));  // DisplayThirdWeatherIcon      21
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_currWeatherIcon));  // DisplayCurrWeatherIcon 22
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_field3));  // LoadField3 23
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_field4));  // LoadField4 24
    _layouts.add(WatchUi.loadResource(Rez.JsonData.l_field5));  // LoadField5 25
    _layouts.add(
        WatchUi.loadResource(Rez.JsonData.l_battery));  // DisplayWatchStatus 26
    _layouts.add(WatchUi.loadResource(
        Rez.JsonData.l_bottom_line1));  // DisplayBottomLine  27
    _layouts.add(
        WatchUi.loadResource(Rez.JsonData.l_top_line));  // DisplayTopLine 28
    // _layouts.add(WatchUi.loadResource(
    //     Rez.JsonData.l_weekplusday));  // DisplayWeekDayNumbers 29

    _horizLine = WatchUi.loadResource(Rez.JsonData.l_horiz_line);
    _vertLine = WatchUi.loadResource(Rez.JsonData.l_vert_line);

    var frequency = Setting.GetWeatherUpdateTime();
    _bgInterval = new Toybox.Time.Duration(
        (frequency * 60) +
        5);  // slight delay so when bg is triggered it updates
  }
}
