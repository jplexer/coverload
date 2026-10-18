import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    width: Theme.coverSizeLarge.width
    height: parent ? parent.height / scale : 0
    scale: parent && parent.width > 0 ? parent.width / width : 1
    transformOrigin: Item.TopLeft
}
