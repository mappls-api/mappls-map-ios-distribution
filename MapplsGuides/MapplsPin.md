[<img src="https://about.mappls.com/images/mappls-b-logo.svg" height="60"/>](https://about.mappls.com/api/)

# Mappls Pin

[← Back to Mappls Map SDK](../Readme.md)

A **Mappls Pin** is a short, unique code for a place, for example `mmi000`. You can use a Mappls Pin anywhere you would use a coordinate: to place a marker, to move the camera, or to fit several places on screen. The SDK resolves each Mappls Pin to its coordinate over the network.

- [Before you start](#before-you-start)
- [Add a marker at a Mappls Pin](#add-a-marker-at-a-mappls-pin)
- [Add many markers](#add-many-markers)
- [Use an existing MGLPointAnnotation](#use-an-existing-mglpointannotation)
- [Move a marker to another Mappls Pin](#move-a-marker-to-another-mappls-pin)
- [Center the map on a Mappls Pin](#center-the-map-on-a-mappls-pin)
- [Show several Mappls Pins on screen](#show-several-mappls-pins-on-screen)
- [Move the camera with a Mappls Pin](#move-the-camera-with-a-mappls-pin)
- [Get the Mappls Pin of a tapped place](#get-the-mappls-pin-of-a-tapped-place)
- [API reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## Before you start

- Complete the [Quick start](../Readme.md#quick-start): the SDK must be initialized and the map authorized.
- Every Mappls Pin call needs a network connection, because the pin is resolved on Mappls servers.
- **Update your UI on the main thread.** Completion handlers of the Mappls Pin methods can run on a background thread. Wrap UI work in `DispatchQueue.main.async { … }`.
- **Always pass a completion handler**, even an empty one, to the `addMapplsAnnotation…`, `setMapCenterAtMapplsPin…` and `showMapplsPins…` methods.

## Add a marker at a Mappls Pin

Create a `MapplsPointAnnotation` with the Mappls Pin and add it with `addMapplsAnnotation`. The SDK resolves the pin, sets the marker's coordinate and adds it to the map.

#### Swift

```swift
import MapplsMap

let annotation = MapplsPointAnnotation(mapplsPin: "mmi000")
annotation.title = "MapmyIndia Head Office"
annotation.subtitle = "mmi000"

mapView.addMapplsAnnotation(annotation) { isSuccess, errorMessage in
    DispatchQueue.main.async {
        if !isSuccess {
            print("Could not add marker: \(errorMessage ?? "unknown error")")
        }
    }
}
```

#### Objective-C

```objectivec
@import MapplsMap;

MapplsPointAnnotation *annotation = [[MapplsPointAnnotation alloc] initWithMapplsPin:@"mmi000"];
annotation.title = @"MapmyIndia Head Office";
annotation.subtitle = @"mmi000";

[self.mapView addMapplsAnnotation:annotation completionHandler:^(BOOL isSuccess, NSString * _Nullable errorMessage) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isSuccess) {
            NSLog(@"Could not add marker: %@", errorMessage);
        }
    });
}];
```

Remove the marker like any other annotation: `mapView.removeAnnotation(annotation)`.

## Add many markers

`addMapplsAnnotations` resolves all pins in a single request, which is faster than adding markers one by one.

```swift
let mapplsPins = ["mmi000", "MMI000"]
let annotations = mapplsPins.map { pin -> MapplsPointAnnotation in
    let annotation = MapplsPointAnnotation(mapplsPin: pin)
    annotation.title = pin
    return annotation
}

mapView.addMapplsAnnotations(annotations) { isSuccess, errorMessage in
    DispatchQueue.main.async {
        guard isSuccess else {
            print("Could not add markers: \(errorMessage ?? "unknown error")")
            return
        }
        // All markers are on the map. Fit them on screen:
        self.mapView.showMapplsPins(mapplsPins, animated: true) { _, _ in }
    }
}
```

If the request succeeds but one pin has no coordinate, that marker is still added at its current coordinate. Check the SDK log for `No coordinates for Mappls Pin` (see [Troubleshooting](#troubleshooting)).

## Use an existing MGLPointAnnotation

If your app already uses `MGLPointAnnotation`, set its `mapplsPin` property and add it with `addMapplsAnnotation`. Custom marker images from `mapView(_:imageFor:)` and callouts work as usual.

```swift
let point = MGLPointAnnotation()
point.mapplsPin = "mmi000"
point.title = "Office"

mapView.addMapplsAnnotation(point) { _, _ in }
```

`MapplsAnnotationView` (a subclass of `MGLAnnotationView`) also has a `mapplsPin` property, for markers drawn with a custom view.

## Move a marker to another Mappls Pin

`updateMapplsPin(_:completionHandler:)` resolves a new Mappls Pin and moves the marker there. It works on both `MapplsPointAnnotation` and `MGLPointAnnotation`.

```swift
annotation.updateMapplsPin("MMI000") { isSuccess, errorMessage in
    if !isSuccess {
        print("Could not move marker: \(errorMessage ?? "unknown error")")
    }
}
```

On a `MapplsPointAnnotation` this moves the marker but does not change its read-only `mapplsPin` property. If you need the new pin later, keep it yourself or create a new annotation.

## Center the map on a Mappls Pin

```swift
// Keep the current zoom level
mapView.setMapCenterAtMapplsPin("mmi000", animated: true) { _, _ in }

// Set a zoom level (16 shows streets, 18 shows buildings)
mapView.setMapCenterAtMapplsPin("mmi000", zoomLevel: 16, animated: true) { _, _ in }

// Set a zoom level and rotate the map (heading in degrees, 0 = north)
mapView.setMapCenterAtMapplsPin("mmi000", zoomLevel: 16, direction: 90, animated: true) { _, _ in }
```

```objectivec
[self.mapView setMapCenterAtMapplsPin:@"mmi000" zoomLevel:16 animated:YES completionHandler:^(BOOL isSuccess, NSString * _Nullable errorMessage) {
}];
```

## Show several Mappls Pins on screen

`showMapplsPins` moves and zooms the camera so that all the given places are visible. It does not add markers; use [`addMapplsAnnotations`](#add-many-markers) for that.

```swift
mapView.showMapplsPins(["mmi000", "MMI000"], animated: true) { isSuccess, errorMessage in
    if !isSuccess {
        print("Could not show pins: \(errorMessage ?? "unknown error")")
    }
}
```

With a single Mappls Pin, the map centers on it at zoom level 17.

## Move the camera with a Mappls Pin

To control distance, pitch and heading as well, build an `MGLMapCamera` from a Mappls Pin. Pass it to `setCamera` or `fly(to:)`; the SDK resolves the pin before moving the camera.

```swift
let camera = MGLMapCamera(lookingAtCenterMapplsPin: "mmi000",
                          acrossDistance: 500,   // meters visible across the screen
                          pitch: 45,              // degrees, 0 = looking straight down
                          heading: 0)             // degrees, 0 = north
mapView.fly(to: camera, completionHandler: nil)
```

```objectivec
MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterMapplsPin:@"mmi000"
                                                     acrossDistance:500
                                                              pitch:45
                                                            heading:0];
[self.mapView flyToCamera:camera completionHandler:nil];
```

If the pin can't be resolved, the camera does not move. The completion handler is still called.

## Get the Mappls Pin of a tapped place

When the user taps a labelled place on the map (a shop, hospital, landmark, locality and so on), the SDK calls `mapView(_:didTapPlaceWithMapplsPin:)` with that place's Mappls Pin. Implement it in your `MapplsMapViewDelegate`:

```swift
class ViewController: UIViewController, MapplsMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didTapPlaceWithMapplsPin mapplsPin: String?) {
        guard let mapplsPin else { return }

        // For example, drop a marker on the tapped place:
        let annotation = MapplsPointAnnotation(mapplsPin: mapplsPin)
        annotation.title = mapplsPin
        (mapView as? MapplsMapView)?.addMapplsAnnotation(annotation) { _, _ in }
    }
}
```

```objectivec
- (void)mapView:(MGLMapView *)mapView didTapPlaceWithMapplsPin:(NSString *)mapplsPin {
    NSLog(@"Tapped place: %@", mapplsPin);
}
```

Taps on empty map areas and roads don't call this method. To show details of the tapped place, pass the Mappls Pin to the Mappls REST APIs in `MapplsAPIKit`.

## API reference

| API | Class | What it does |
| :-- | :---- | :----------- |
| `init(mapplsPin:)` | `MapplsPointAnnotation` | Creates a marker for a Mappls Pin. Its coordinate is set when it is added with `addMapplsAnnotation`. |
| `mapplsPin` | `MGLPointAnnotation`, `MapplsAnnotationView` | Mappls Pin of an existing annotation type. |
| `updateMapplsPin(_:completionHandler:)` | `MapplsPointAnnotation`, `MGLPointAnnotation` | Moves the marker to another Mappls Pin. |
| `addMapplsAnnotation(_:completionHandler:)` | `MapplsMapView` | Resolves the pin and adds one marker. |
| `addMapplsAnnotations(_:completionHandler:)` | `MapplsMapView` | Resolves all pins in one request and adds the markers. |
| `setMapCenterAtMapplsPin(_:animated:completionHandler:)` | `MapplsMapView` | Centers the map on a pin. |
| `setMapCenterAtMapplsPin(_:zoomLevel:animated:completionHandler:)` | `MapplsMapView` | Centers the map on a pin at a zoom level. |
| `setMapCenterAtMapplsPin(_:zoomLevel:direction:animated:completionHandler:)` | `MapplsMapView` | Same, and rotates the map. |
| `showMapplsPins(_:animated:completionHandler:)` | `MapplsMapView` | Fits the camera to several pins. |
| `init(lookingAtCenterMapplsPin:acrossDistance:pitch:heading:)` | `MGLMapCamera` | Camera centered on a pin. |
| `centerMapplsPin` | `MGLMapCamera` | Mappls Pin the camera is centered on. |
| `mapView(_:didTapPlaceWithMapplsPin:)` | `MGLMapViewDelegate` | Reports the Mappls Pin of a tapped place. |

All completion handlers have the form `(isSuccess: Bool, errorMessage: String?)`.

## Troubleshooting

Turn on SDK logs to see why a Mappls Pin call failed:

```swift
MapplsAccountManager.setIsEnableLogging(true)
MGLLoggingConfiguration.shared.loggingLevel = .verbose
```

| Log message or symptom | Cause and fix |
| :--------------------- | :------------ |
| `Invalid Mappls Pin` | The pin is empty or only spaces. |
| `Could not resolve Mappls Pin…` | Network error, or the pin doesn't exist. Check the pin and the connection. |
| `Mappls Pin: … returned invalid coordinates` | The pin exists but has no location. |
| `No coordinates for Mappls Pin` | One pin in `addMapplsAnnotations` could not be resolved; its marker stays at its old coordinate. |
| `Method not allowed` | Your Mappls license doesn't include this feature. Contact [apisupport@mappls.com](mailto:apisupport@mappls.com). |
| Marker added but UI not updated | You updated UIKit from the completion handler on a background thread. Use `DispatchQueue.main.async`. |
| `didTapPlaceWithMapplsPin` never called | The delegate isn't set, or the tap wasn't on a labelled place. |
