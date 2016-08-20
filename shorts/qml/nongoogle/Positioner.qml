/*
 * Copyright (C) 2014-2015 Canonical Ltd
 *
 * This file is part of Ubuntu Clock App
 *
 * Ubuntu Clock App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Clock App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import U1db 1.0 as U1db
import QtPositioning 5.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
//import "../components"

Item {
    id: positioner
    objectName: "positioner"

    anchors.fill: parent

    // Property to keep track of app cold start status
    property string countryCode: ""

    Component.onCompleted: {
    }

    PositionSource {
        id: geoposition

        // Property to store the time of the last GPS location update
        property var lastUpdate

        readonly property real userLongitude: position.coordinate.longitude

        readonly property real userLatitude: position.coordinate.latitude

        active: true
        updateInterval: 1000

        onSourceErrorChanged: {
            // Stop querying user location if location service is not available
            if (sourceError !== PositionSource.NoError) {
                console.log("[Source Error]: Location Service Error")
                geoposition.stop()

            }
        }

        onPositionChanged: {
            // Do not accept an invalid user location
            if(!position.longitudeValid || !position.latitudeValid) {
                return
            }

            if(position.longitudeValid || position.latitudeValid) {
                //print("current position: ", userLatitude, userLongitude)
                geoposition.stop()
                getCountryCode(userLatitude, userLongitude)
            }


        }

        /* get country code from geonames.org
          // http://api.geonames.org/countryCode?lat=23&lng=113&username=krnekhelesh
         */
        function getCountryCode(lat, lng) {

            var url = "http://api.geonames.org/countryCode?lat=" + lat + "&lng=" + lng + "&username=krnekhelesh&type=JSON"

            var doc = new XMLHttpRequest()

            doc.onreadystatechange = function() {
                if (doc.readyState === XMLHttpRequest.DONE) {

                    var resObj
                    if (doc.status == 200) {
                        resObj = JSON.parse(doc.responseText)
                    } else { // Error
                        resObj = {"responseDetails" : doc.statusText,
                            "responseStatus" : doc.status}
                    }

                    countryCode = resObj.countryName
                    print("countryCode", resObj)

                    if (countryCode == "China") {
                        if (optionsKeeper.useGoogleSearch) {
                            PopupUtils.open(componentDialogNG, pageStack)
                        }
                    }
                }
            }

            doc.open("GET", url, true);
            doc.send();
        }
    } //PositionSource

}
