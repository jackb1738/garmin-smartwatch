import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class TestingCadenceChartView extends WatchUi.View {

    private var _refreshTimer;

    function initialize() {
        View.initialize();
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshScreen), 3000, true);
    }

    function onLayout(dc as Dc) as Void {
        // No layout file needed - we'll draw directly
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        // Clear the screen (black RGB: 0,0,0 = 0x000000)
        dc.setColor(0x000000, 0x000000);
        dc.clear();
        
        // Draw all the elements
        drawElements(dc);
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
        }
    }

    function refreshScreen() as Void {
        WatchUi.requestUpdate();
    }

    function drawElements(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var info = Activity.getActivityInfo();
        var app = getApp();
        
        // Draw elapsed time at top (yellow RGB: 255,248,18 = 0xFFF, using picker in paint to get RGB then convert to hex
        if (info != null && info.timerTime != null) {
            var seconds = info.timerTime / 1000;
            var hours = seconds / 3600;
            var minutes = (seconds % 3600) / 60;
            var secs = seconds % 60;
            var timeStr = hours.format("%01d") + ":" + minutes.format("%02d") + "." + secs.format("%02d");
            dc.setColor(0xFFF813, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, 3, Graphics.FONT_LARGE, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw heart rate circle (left, dark red RGB: 211,19,2519
        var hrX = width / 4;
        var hrY = (height * 2) / 5;
        var circleRadius = 42;
        
        dc.setColor(0x9D0000, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(hrX, hrY, circleRadius);
        
        if (info != null && info.currentHeartRate != null) {
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT); // White RGB: 255,255,255
            dc.drawText(hrX, hrY - 25, Graphics.FONT_TINY, info.currentHeartRate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(hrX, hrY + 8, Graphics.FONT_XTINY, "bpm", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw distance circle (right, dark green RGB: 24,19,24 = 0x1D5E11)
        var distX = (width * 3) / 4;
        var distY = hrY;
        
        dc.setColor(0x1D5E11, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(distX, distY, circleRadius);
        
        if (info != null && info.elapsedDistance != null) {
            var distanceKm = info.elapsedDistance / 100000.0;
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT); // White RGB: 255,255,255
            dc.drawText(distX, distY - 25, Graphics.FONT_TINY, distanceKm.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(distX, distY + 8, Graphics.FONT_XTINY, "km", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw current cadence and label in center
        var cadenceY = height - 150;
        
        if (info != null && info.currentCadence != null) {
            // Draw "CADENCE" label (light gray RGB: 170,170,170 = 0xAAAAAA)
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, cadenceY, Graphics.FONT_XTINY, "CADENCE", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw cadence value in green (RGB: 0,255,0 = 0x00FF00)
            dc.setColor(0x00FF00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, cadenceY + 20, Graphics.FONT_MEDIUM, info.currentCadence.toString() + "  spm", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw the chart at the bottom
        drawChart(dc);
    }

    function drawChart(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Get zone history from app
        var app = getApp();
        var zoneHistory = app.getZoneHistory();
        var historyIndex = app.getHistoryIndex();
        
        // Chart area dimensions - positioned at bottom like in the design
        var chartHeight = 60;
        var chartTop = height - chartHeight - 10;
        var chartBottom = height - 10;
        var chartLeft = 20;
        var chartRight = width - 20;
        var chartWidth = chartRight - chartLeft;
        
        // Draw white border around chart (RGB: 255,255,255 = 0xFFFFFF)
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(chartLeft - 1, chartTop - 1, chartWidth + 2, chartHeight + 2);
        
        // Calculate bar width
        var numBars = 60;
        var barWidth = chartWidth / numBars;
        
        // Draw bars
        for (var i = 0; i < numBars; i++) {
            var dataIndex = (historyIndex + i) % 60; // Start from oldest data
            var zoneState = zoneHistory[dataIndex];
            
            if (zoneState != null) {
                var barX = chartLeft + (i * barWidth);
                var barY = chartTop;
                var barH = chartHeight;
                
                // Set color based on zone state using RGB hex values
                if (zoneState == 0) {
                    dc.setColor(0x00FF00, Graphics.COLOR_TRANSPARENT); // Green RGB: 0,255,0
                } else if (zoneState == -1) {
                    dc.setColor(0x0000FF, Graphics.COLOR_TRANSPARENT); // Blue RGB: 0,0,255
                } else {
                    dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT); // Red RGB: 255,0,0
                }
                
                // Draw the bar (with 1 pixel spacing)
                if (barWidth > 1) {
                    dc.fillRectangle(barX, barY, barWidth - 1, barH);
                } else {
                    dc.fillRectangle(barX, barY, 1, barH);
                }
            }
        }
    }
}
