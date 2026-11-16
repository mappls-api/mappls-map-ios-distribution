[<img src="https://about.mappls.com/images/mappls-b-logo.svg" height="60"/>](https://about.mappls.com/api/)

# Indoor Maps

[← Back to Mappls Map SDK](../Readme.md)

Indoor maps show the inside of buildings such as malls, airports and hospitals: shops, rooms, entrances and points of interest, floor by floor. When the user zooms in on a building with indoor data, the SDK shows a **floor selector** on the map. Tapping a floor switches the map to that floor.

- [Enable indoor maps](#enable-indoor-maps)
- [When the floor selector appears](#when-the-floor-selector-appears)
- [Position the floor selector](#position-the-floor-selector)
- [Turn indoor maps off](#turn-indoor-maps-off)
- [Full example](#full-example)
- [API reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## Enable indoor maps

Indoor maps are on by default. You only need to make sure `isLayerControlEnabled` is `true`:

```swift
mapView.isLayerControlEnabled = true
```

```objectivec
self.mapView.layerControlEnabled = YES;
```

No extra setup, plugin object or delegate method is needed. The SDK checks the building at the map center each time the map stops moving.

## When the floor selector appears

The floor selector is shown when all of these are true:

1. `isLayerControlEnabled` is `true`.
2. The zoom level is **16 or higher**.
3. The **center of the map** is over a building with Mappls indoor data.
4. The building has **more than one floor**.

The selector shows one button per floor, with `G` for the ground floor, and the map starts on the ground floor. When the user moves away from the building or zooms out, the selector hides and the building returns to the ground floor.

To open a building directly, center the map on it at zoom 17 or higher:

```swift
let mall = CLLocationCoordinate2D(latitude: 28.528600, longitude: 77.219300)  // Select Citywalk, New Delhi
mapView.setCenter(mall, zoomLevel: 17.5, animated: false)
```

## Position the floor selector

The selector sits at the bottom left of the map. Move it with two properties, in points:

```swift
mapView.indoorSelecorViewLeftConstraintConstant = 16     // distance from the left edge
mapView.indoorSelecorViewBottomConstraintConstant = 80   // distance from the bottom edge
```

Raise it above anything you place at the bottom of the map, such as the Mappls logo, a bottom sheet or a tab bar.

Note the spelling: `indoorSelecor…`.

## Turn indoor maps off

```swift
mapView.isLayerControlEnabled = false
```

The floor selector hides and any building that shows an upper floor goes back to the ground floor.

## Full example

```swift
import MapplsMap
import UIKit

class IndoorViewController: UIViewController, MapplsMapViewDelegate {
    var mapView: MapplsMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapplsMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self

        // Show the floor selector, 80 points above the bottom edge.
        mapView.isLayerControlEnabled = true
        mapView.indoorSelecorViewBottomConstraintConstant = 80

        // Open on a mall with indoor data. The selector needs zoom 16 or higher.
        mapView.setCenter(CLLocationCoordinate2D(latitude: 28.528600, longitude: 77.219300),
                          zoomLevel: 17.5, animated: false)

        view.addSubview(mapView)
    }
}
```

## API reference

| API | Class | What it does |
| :-- | :---- | :----------- |
| `isLayerControlEnabled` | `MGLMapView` | Shows indoor floors and the floor selector. Default `true`. |
| `indoorSelecorViewLeftConstraintConstant` | `MGLMapView` | Distance of the floor selector from the left edge, in points. |
| `indoorSelecorViewBottomConstraintConstant` | `MGLMapView` | Distance of the floor selector from the bottom edge, in points. |

`MapplsMapView` inherits these from `MGLMapView`.

## Troubleshooting

| Symptom | Cause and fix |
| :------ | :------------ |
| No floor selector | Zoom in to 16 or more, and move the map so its **center** is over the building. |
| No floor selector on a known building | The building has only one floor, or no indoor data yet. |
| Selector is hidden behind my UI | Increase `indoorSelecorViewBottomConstraintConstant` or `indoorSelecorViewLeftConstraintConstant`. |
| Selector doesn't appear with my own style | Indoor needs the Mappls indoor layers. Use a Mappls style; see [Map Styles](MapStyles.md). |
| Selector disappeared after I implemented `updateFloorSelector`, `showFloorSelector` or `hideFloorSelector` | Implementing any of these in the map view's delegate hides the built-in selector. Remove them from your delegate. |
