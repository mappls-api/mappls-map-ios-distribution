[<img src="https://about.mappls.com/images/mappls-b-logo.svg" height="60"/>](https://about.mappls.com/api/)

# Live Traffic

[← Back to Mappls Map SDK](../Readme.md)

The traffic layers draw live traffic on the roads of the map: how fast traffic is flowing, where it is congested, which roads are closed, and stop or incident icons. You turn traffic on with one property and choose which kinds to show with four more.

- [Show traffic](#show-traffic)
- [Choose what to show](#choose-what-to-show)
- [Example: a traffic toggle](#example-a-traffic-toggle)
- [API reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## Show traffic

Traffic is off by default. Turn it on with `isTrafficEnabled`:

```swift
mapView.isTrafficEnabled = true
```

```objectivec
self.mapView.trafficEnabled = YES;
```

This shows all four kinds of traffic below. You can set it before or after the map has loaded; the setting is kept when you [change the map style](MapStyles.md).

Live traffic must be part of your Mappls license. If it isn't, setting these properties has no effect (see [Troubleshooting](#troubleshooting)).

## Choose what to show

Each kind of traffic has its own property. They only take effect while `isTrafficEnabled` is `true`.

| Property | Shows | Default |
| :------- | :---- | :------ |
| `isFreeFlowTrafficEnabled` | Roads where traffic moves at normal speed. | `true` |
| `isNonFreeFlowTrafficEnabled` | Roads with slow or congested traffic. | `true` |
| `isClosureTrafficEnabled` | Closed roads. | `true` |
| `isStopIconTrafficEnabled` | Stop and incident icons on the road. | `true` |

For example, to show only congestion and closures:

```swift
mapView.isTrafficEnabled = true
mapView.isFreeFlowTrafficEnabled = false
mapView.isNonFreeFlowTrafficEnabled = true
mapView.isClosureTrafficEnabled = true
mapView.isStopIconTrafficEnabled = false
```

```objectivec
self.mapView.trafficEnabled = YES;
self.mapView.freeFlowTrafficEnabled = NO;
self.mapView.nonFreeFlowTrafficEnabled = YES;
self.mapView.closureTrafficEnabled = YES;
self.mapView.stopIconTrafficEnabled = NO;
```

## Example: a traffic toggle

```swift
import MapplsMap
import UIKit

class TrafficViewController: UIViewController {
    var mapView: MapplsMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapplsMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let trafficSwitch = UISwitch()
        trafficSwitch.isOn = mapView.isTrafficEnabled
        trafficSwitch.addTarget(self, action: #selector(trafficToggled(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trafficSwitch)
    }

    @objc private func trafficToggled(_ sender: UISwitch) {
        mapView.isTrafficEnabled = sender.isOn
    }
}
```

### SwiftUI

```swift
import MapplsMap
import SwiftUI

struct TrafficMap: UIViewRepresentable {
    var showsTraffic: Bool

    func makeUIView(context: Context) -> MapplsMapView {
        MapplsMapView()
    }

    func updateUIView(_ mapView: MapplsMapView, context: Context) {
        mapView.isTrafficEnabled = showsTraffic
    }
}
```

## API reference

All properties are on `MGLMapView`, so `MapplsMapView` has them too.

| Swift | Objective-C | Default |
| :---- | :---------- | :------ |
| `isTrafficEnabled` | `trafficEnabled` | `false` |
| `isFreeFlowTrafficEnabled` | `freeFlowTrafficEnabled` | `true` |
| `isNonFreeFlowTrafficEnabled` | `nonFreeFlowTrafficEnabled` | `true` |
| `isClosureTrafficEnabled` | `closureTrafficEnabled` | `true` |
| `isStopIconTrafficEnabled` | `stopIconTrafficEnabled` | `true` |

## Troubleshooting

Turn on SDK logs first:

```swift
MapplsAccountManager.setIsEnableLogging(true)
```

| Symptom | Cause and fix |
| :------ | :------------ |
| Log shows `Traffic method is not allowed` and no traffic appears | Live traffic isn't part of your license. Contact [apisupport@mappls.com](mailto:apisupport@mappls.com). |
| No traffic, no log message | Check that `isTrafficEnabled` is `true` and at least one of the four kinds is on. Traffic is only drawn on roads that have live data. |
| No traffic with my own style URL | Traffic needs the Mappls traffic layers. Use a Mappls style; see [Map Styles](MapStyles.md). |
