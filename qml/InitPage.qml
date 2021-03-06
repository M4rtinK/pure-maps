/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import "."
import "platform"

PageEmptyPL {
    id: page

    property bool ready: false

    BusyModal {
        id: busy
        running: !py.ready
        text: !py.ready ? app.tr("Initializing") : ""
    }

    Connections {
        target: py
        onReadyChanged: {
            if (!py.ready) return;
            page.ready = true
            if (!py.call_sync("poor.key.get", ["MAPBOX_KEY"])) {
                var d = app.push("MessagePage.qml", {
                                     "acceptText": app.tr("Dismiss"),
                                     "title": app.tr("Missing Mapbox key"),
                                     "message": app.tr("Your installation is missing Mapbox API key. " +
                                                       "Please register at Mapbox and fill in your personal API key " +
                                                       "in Preferences. This key is not needed if you plan to use " +
                                                       "Pure Maps with the offline map provider.")
                                 });
            } else start();
        }
    }

    onPageStatusActive: if (page.ready) start()

    function start() {
        app.rootPage = app.pages.replace("RootPage.qml");
        app.initialize();
    }
}
