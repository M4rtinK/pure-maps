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

PagePL {
    id: page
    title: app.tr("Navigation")

    canNavigateForward:
        (!page.fromNeeded || (page.from && (page.fromText !== app.tr("Current position") || gps.ready))) &&
        (!page.toNeeded   || (page.to   && (page.toText   !== app.tr("Current position") || gps.ready)))

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: app.tr("Follow me")
            onClicked: {
                followMe.checked = !followMe.checked;
                columnFollow.visible = true;
                columnRouter.settingsChecked = false;
                page.params = {};
                columnRouter.settings && columnRouter.settings.destroy();
                columnRouter.settings = null;
                columnRouter.addSettings();
            }
        }
        PageMenuItemPL {
            text: app.tr("Reverse endpoints")
            onClicked: {
                var from = page.from;
                var fromText = page.fromText;
                page.from = page.to;
                page.fromText = page.toText;
                page.to = from;
                page.toText = fromText;
            }
        }
    }

    property var    columnRouter
    property var    from: null
    property bool   fromNeeded: true
    property string fromText: ""
    property var    params: {}
    property var    to: null
    property bool   toNeeded: true
    property string toText: ""

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: app.styler.themePaddingLarge

        Column {
            id: columnRouter
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: app.styler.themePaddingMedium
            visible: !followMe.checked

            property var  settings: null
            property bool settingsChecked: false

            ValueButtonPL {
                id: usingButton
                label: app.tr("Using")
                height: app.styler.themeItemSizeSmall
                value: py.evaluate("poor.app.router.name")
                width: parent.width
                onClicked: {
                    var dialog = app.push("RouterPage.qml");
                    dialog.accepted.connect(function() {
                        columnRouter.settingsChecked = false;
                        usingButton.value = py.evaluate("poor.app.router.name");
                        page.fromNeeded = py.evaluate("poor.app.router.from_needed");
                        page.toNeeded = py.evaluate("poor.app.router.to_needed");
                        if (columnRouter.settings) columnRouter.settings.destroy();
                        columnRouter.settings = null;
                        columnRouter.addSettings();
                    });
                }
            }

            ValueButtonPL {
                id: fromButton
                label: app.tr("From")
                height: app.styler.themeItemSizeSmall
                value: page.fromText
                visible: page.fromNeeded
                // Avoid putting label and value on different lines.
                width: 3 * parent.width

                BusyIndicatorSmallPL {
                    anchors.right: parent.right
                    anchors.rightMargin: app.styler.themeHorizontalPageMargin + (parent.width - page.width)
                    anchors.verticalCenter: parent.verticalCenter
                    running: page.fromText === app.tr("Current position") && !gps.ready
                    z: parent.z + 1
                }

                onClicked: {
                    var dialog = app.push("RoutePointPage.qml");
                    dialog.accepted.connect(function() {
                        if (dialog.selectedPoi && dialog.selectedPoi.coordinate) {
                            page.from = [dialog.selectedPoi.coordinate.longitude, dialog.selectedPoi.coordinate.latitude];
                            page.fromText = dialog.selectedPoi.title || app.tr("Unnamed point");
                        } else if (dialog.query === app.tr("Current position")) {
                            page.from = map.getPosition();
                            page.fromText = dialog.query;
                        } else {
                            page.from = dialog.query;
                            page.fromText = dialog.query;
                            py.call_sync("poor.app.history.add_place", [dialog.query]);
                        }
                    });
                }

            }

            ValueButtonPL {
                id: toButton
                label: app.tr("To")
                height: app.styler.themeItemSizeSmall
                value: page.toText
                visible: page.toNeeded
                // Avoid putting label and value on different lines.
                width: 3 * parent.width

                BusyIndicatorSmallPL {
                    anchors.right: parent.right
                    anchors.rightMargin: app.styler.themeHorizontalPageMargin + (parent.width - page.width)
                    anchors.verticalCenter: parent.verticalCenter
                    running: page.toText === app.tr("Current position") && !gps.ready
                    z: parent.z + 1
                }

                onClicked: {
                    var dialog = app.push("RoutePointPage.qml");
                    dialog.accepted.connect(function() {
                        if (dialog.selectedPoi && dialog.selectedPoi.coordinate) {
                            page.to = [dialog.selectedPoi.coordinate.longitude, dialog.selectedPoi.coordinate.latitude];
                            page.toText = dialog.selectedPoi.title || app.tr("Unnamed point");
                        } else if (dialog.query === app.tr("Current position")) {
                            page.to = map.getPosition();
                            page.toText = dialog.query;
                        } else {
                            page.to = dialog.query;
                            page.toText = dialog.query;
                            py.call_sync("poor.app.history.add_place", [dialog.query]);
                        }
                    });
                }

            }


            Connections {
                target: page
                onFromChanged: columnRouter.addSettings();
                onToChanged: columnRouter.addSettings();
            }

            Connections {
                target: followMe
                onCheckedChanged: columnRouter.addSettings();
            }

            Component.onCompleted: {
                columnRouter.addSettings();
                page.columnRouter = columnRouter;
            }

            function addSettings() {
                if (columnRouter.settingsChecked || (page.from==null && page.fromNeeded) || (page.to==null && page.toNeeded) || followMe.checked) return;
                // Add router-specific settings from router's own QML file.
                columnFollow.visible = !(page.fromNeeded && page.toNeeded);
                page.params = {};
                columnRouter.settings && columnRouter.settings.destroy();
                var uri = py.evaluate("poor.app.router.settings_qml_uri");
                if (!uri) return;
                var component = Qt.createComponent(uri);
                if (component.status === Component.Error) {
                    console.log('Error while creating component');
                    console.log(component.errorString());
                    return null;
                }
                columnRouter.settings = component.createObject(columnRouter);
                columnRouter.settings.anchors.left = columnRouter.left;
                columnRouter.settings.anchors.right = columnRouter.right;
                columnRouter.settings.width = columnRouter.width;
                columnRouter.settingsChecked = true;
            }
        }

        Column {
            id: columnFollow
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: app.styler.themePaddingMedium

            /////////////////
            // Follow Me mode
            TextSwitchPL {
                id: followMe
                checked: false
                description: app.tr("Follow the movement and show just in time information")
                enabled: app.mode !== modes.followMe
                text: app.tr("Follow me")
                Component.onCompleted: {
                    checked = (app.mode === modes.followMe);
                }
            }

            ToolItemPL {
                id: beginFollowMeItem
                icon.source: app.mode === modes.followMe ? app.styler.iconStop : app.styler.iconStart
                icon.sourceSize.height: app.styler.themeIconSizeMedium
                text: app.mode === modes.followMe ? app.tr("Stop") : app.tr("Begin")
                visible: followMe.checked
                width: columnFollow.width
                onClicked: {
                    if (app.mode === modes.followMe) {
                        app.setModeExplore();
                        app.showMap();
                    } else {
                        app.setModeFollowMe();
                        app.hideMenu();
                    }
                }
            }

            ComboBoxPL {
                id: mapmatchingComboBox
                description: app.tr("Select mode of transportation. Only applies when Pure Maps is in follow me mode.")
                label: app.tr("Mode of transportation")
                model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot") ]
                visible: followMe.checked
                property string  value: "car"
                property var     values: ["car", "bicycle", "foot"]
                Component.onCompleted: {
                    var v = app.conf.mapMatchingWhenFollowing;
                    mapmatchingComboBox.currentIndex = Math.max(0, mapmatchingComboBox.values.indexOf(v));
                    value = values[mapmatchingComboBox.currentIndex];
                }
                onCurrentIndexChanged: {
                    mapmatchingComboBox.value = values[mapmatchingComboBox.currentIndex]
                    app.conf.set("map_matching_when_following", mapmatchingComboBox.value);
                    scaleSlider.value = app.conf.get("map_scale_navigation_" + mapmatchingComboBox.value)
                }
            }

            SliderPL {
                id: scaleSlider
                label: app.tr("Map scale")
                maximumValue: 4.0
                minimumValue: 0.5
                stepSize: 0.1
                value: app.conf.get("map_scale_navigation_" + mapmatchingComboBox.value)
                valueText: value
                visible: followMe.checked
                width: parent.width
                onValueChanged: {
                    if (!mapmatchingComboBox.value) return;
                    app.conf.set("map_scale_navigation_" + mapmatchingComboBox.value, scaleSlider.value);
                    if (app.mode === modes.followMe) map.setScale(scaleSlider.value);
                }
            }
            // Follow Me mode: done
            ///////////////////////

        }
    }

    Component.onCompleted: {
        if (!page.from) {
            page.from = map.getPosition();
            page.fromText = app.tr("Current position");
        }
        page.fromNeeded = py.evaluate("poor.app.router.from_needed");
        page.toNeeded = py.evaluate("poor.app.router.to_needed");
        columnRouter.addSettings();
    }

    onPageStatusActive: {
        if (page.fromText === app.tr("Current position"))
            page.from = map.getPosition();
        if (page.toText === app.tr("Current position"))
            page.to = map.getPosition();
        var uri = py.evaluate("poor.app.router.results_qml_uri");
        app.pushAttached(uri);
    }

}
