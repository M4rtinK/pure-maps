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
    title: app.tr("About Pure Maps")

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: app.styler.themePaddingLarge
        width: parent.width

        Image {
            // Logo
            anchors.horizontalCenter: parent.horizontalCenter
            height: width/sourceSize.width * sourceSize.height
            smooth: true
            source: "icons/pure-maps-512.png"
            width: 0.25 * Math.min(page.height,page.width)
        }

        ListItemLabel {
            height: app.styler.themeItemSizeExtraSmall
            horizontalAlignment: Text.AlignHCenter
            text: app.tr("version %1", py.evaluate("poor.__version__"))
        }

        ButtonPL {
            anchors.horizontalCenter: parent.horizontalCenter
            height: app.styler.themeItemSizeLarge
            preferredWidth: app.styler.themeButtonWidthMedium
            text: app.tr("GitHub page")
            onClicked: Qt.openUrlExternally("https://github.com/rinigus/pure-maps");
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: app.styler.themePaddingSmall
            width: Math.min(page.height,page.width)

            ListItemLabel {
                font.pixelSize: app.styler.themeFontSizeSmall
                height: implicitHeight
                text: "Copyright ©"
            }

            ListItemLabel {
                font.pixelSize: app.styler.themeFontSizeSmall
                height: implicitHeight
                horizontalAlignment: Text.AlignRight
                text: "2014–2018 Osmo Salomaa\n2018 Rinigus"
            }

            ListItemLabel {
                font.pixelSize: app.styler.themeFontSizeSmall
                height: implicitHeight
                horizontalAlignment: Text.AlignRight
                text: app.tr("Logo by %1", "Fellfrosch")
            }
        }

        ListItemLabel {
            font.pixelSize: app.styler.themeFontSizeSmall
            height: implicitHeight
            horizontalAlignment: implicitWidth >
                                 parent.width - anchors.leftMargin - anchors.rightMargin ?
                                     Text.AlignLeft : Text.AlignHCenter
            text: app.tr("Pure Maps is free software released under the GNU General Public License (GPL), version 3 or later.")
            wrapMode: Text.WordWrap
        }

        SectionHeaderPL {
            text: app.tr("Translated by")
        }

        ListItemLabel {
            font.pixelSize: app.styler.themeFontSizeSmall
            height: visible ? app.styler.themeItemSizeExtraSmall : 0
            horizontalAlignment: Text.AlignHCenter
            // TRANSLATORS: This is a special message that shouldn't be translated
            // literally. It is used in the about page to give credits to the translators.
            // Thus, you should translate it to your name. You can also include other
            // translators who have contributed to this translation; in that case, please
            // write them on separate lines seperated by newlines (\n).
            text: app.tr("translator-credits")
            visible: text && text !== "translator-credits"
        }

        ListItemLabel {
            font.pixelSize: app.styler.themeFontSizeSmall
            height: implicitHeight
            horizontalAlignment: implicitWidth >
                                 parent.width - anchors.leftMargin - anchors.rightMargin ?
                                     Text.AlignLeft : Text.AlignHCenter
            text: app.tr("You can add new user interface translations or contribute to existing ones at Transifex.")
            wrapMode: Text.WordWrap
        }

        ButtonPL {
            anchors.horizontalCenter: parent.horizontalCenter
            height: app.styler.themeItemSizeLarge
            preferredWidth: app.styler.themeButtonWidthMedium
            text: app.tr("Transifex page")
            onClicked: Qt.openUrlExternally("https://www.transifex.com/rinigus/pure-maps/");
        }
    }
}
