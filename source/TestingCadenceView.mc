import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;

class TestingCadenceView extends WatchUi.View {

    private var _cadenceDisplay;
    private var _refreshTimer;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _cadenceZoneDisplay;

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
        _cadenceZoneDisplay = findDrawableById("cadence_zone");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text");
        _timeDisplay = findDrawableById("time_text");
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
        

        if (info != null && info.currentCadence != null){
            _cadenceDisplay.setText(info.currentCadence.toString());
        }else{
            _cadenceDisplay.setText("--");
        }

        // Show whether current cadence is inside configured zone
        var minZone = getApp().getMinCadence();
        var maxZone = getApp().getMaxCadence();
        var zoneText = "";
        if (info != null && info.currentCadence != null) {
            var c = info.currentCadence;
            if (c >= minZone && c <= maxZone) {
                zoneText = (WatchUi.loadResource(Rez.Strings.zone_in) as String) + " (" + minZone.toString() + "-" + maxZone.toString() + ")";
            } else {
                zoneText = (WatchUi.loadResource(Rez.Strings.zone_out) as String) + " (" + minZone.toString() + "-" + maxZone.toString() + ")";
            }
        } else {
            zoneText = "(" + minZone.toString() + "-" + maxZone.toString() + ")";
        }
        if (_cadenceZoneDisplay != null) {
            _cadenceZoneDisplay.setText(zoneText);
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

}
