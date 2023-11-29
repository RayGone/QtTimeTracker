import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Shapes 1.3

Rectangle{
    id: rect
    color: app.primaryColor
    // I want to use conical ConicalGradient or RadialGradient
    gradient: RadialGradient {
        GradientStop { position: 0.0; color: Material.color(Material.Blue,Material.Shade600) }
        GradientStop { position: 0.5; color: Material.color(Material.BlueGrey,Material.Shade800) }
        GradientStop { position: 1.0; color: Material.color(Material.Blue,Material.Shade600) }
    }

    Behavior on opacity{
        NumberAnimation {
            target: rect
            property: "opacity"
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }
}
