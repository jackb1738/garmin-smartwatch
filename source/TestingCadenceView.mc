import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.Application;
import Toybox.System;

class TestingCadenceView extends WatchUi.View {

    private var _cadenceDisplay;
    private var _refreshTimer;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _zoneIndicator;
    private var _previousCadence = null;
    private var _wasOutOfZone = false;
    private var _lastVibrateTime = 0;

    function initialize() {
        View.initialize();
        _refreshTimer = new Timer.Timer();
        //Updated the refersh timer to 3 seconds to help preserve battery life
        _refreshTimer.start(method(:refreshScreen), 3000, true);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _cadenceDisplay = findDrawableById("cadence_text");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text");
        _timeDisplay = findDrawableById("time_text");
        _zoneIndicator = findDrawableById("zone_indicator");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        //update the display for current cadence
        displayCadence();
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function refreshScreen() as Void{
        WatchUi.requestUpdate();
    }

    function displayCadence() as Void{
        var info = Activity.getActivityInfo();
        var app = Application.getApp();
        var minCadence = app.getProperty("minCadence");
        var maxCadence = app.getProperty("maxCadence");
        
        // Set default values if properties are null
        if (minCadence == null) {
            minCadence = 160;
        }
        if (maxCadence == null) {
            maxCadence = 180;
        }

        if (info != null && info.currentCadence != null){
            var currentCadence = info.currentCadence;
            _cadenceDisplay.setText(currentCadence.toString());
            
            // Check if cadence is in zone
            var isInZone = (currentCadence >= minCadence && currentCadence <= maxCadence);
            
            // Update zone indicator
            if (isInZone) {
                _zoneIndicator.setText("IN ZONE");
                _zoneIndicator.setColor(Graphics.COLOR_GREEN);
                _wasOutOfZone = false;
            } else if (currentCadence < minCadence) {
                _zoneIndicator.setText("TOO LOW");
                _zoneIndicator.setColor(Graphics.COLOR_RED);
                checkAndVibrate(false); // false = below zone
            } else {
                _zoneIndicator.setText("TOO HIGH");
                _zoneIndicator.setColor(Graphics.COLOR_ORANGE);
                checkAndVibrate(true); // true = above zone
            }
            
            _previousCadence = currentCadence;
        }else{
            _cadenceDisplay.setText("--");
            _zoneIndicator.setText("NO DATA");
            _zoneIndicator.setColor(Graphics.COLOR_LT_GRAY);
        }

        if (info != null && info.currentHeartRate != null){
            _heartrateDisplay.setText(info.currentHeartRate.toString());
        }else{
            _heartrateDisplay.setText("--");
        }

        // Display distance in kilometers with 2 decimal places
        if (info != null && info.elapsedDistance != null){
            var distanceKm = info.elapsedDistance / 100000.0; // Convert centimeters to kilometers
            _distanceDisplay.setText(distanceKm.format("%.2f") + " km");
        }else{
            _distanceDisplay.setText("-- km");
        }

        // Display elapsed time in HH:MM:SS format
        if (info != null && info.timerTime != null){
            var seconds = info.timerTime / 1000; // Convert milliseconds to seconds
            var hours = seconds / 3600;
            var minutes = (seconds % 3600) / 60;
            var secs = seconds % 60;
            _timeDisplay.setText(hours.format("%02d") + ":" + minutes.format("%02d") + ":" + secs.format("%02d"));
        }else{
            _timeDisplay.setText("--:--:--");
        }
        
    }

    function checkAndVibrate(isAboveZone as Boolean) as Void {
        var currentTime = System.getTimer();
        
        // Only vibrate if:
        // 1. We weren't already out of zone (just went out)
        // 2. Or if it's been more than 10 seconds since last vibration
        if (!_wasOutOfZone || (currentTime - _lastVibrateTime) > 10000) {
            if (Attention has :vibrate) {
                var vibrateData = [
                    new Attention.VibeProfile(50, 200),  // 50% intensity for 200ms
                    new Attention.VibeProfile(0, 100),   // Pause for 100ms
                    new Attention.VibeProfile(50, 200)   // 50% intensity for 200ms
                ];
                Attention.vibrate(vibrateData);
            }
            _lastVibrateTime = currentTime;
            _wasOutOfZone = true;
        }
    }

}
