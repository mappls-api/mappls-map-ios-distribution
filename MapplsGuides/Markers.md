[<img src="https://about.mappls.com/images/mappls-b-logo.svg" height="60"/>](https://about.mappls.com/api/)

# Markers

[← Back to Mappls Map SDK](../Readme.md)

There are two ways to put markers on a Mappls map:

- **Annotations:** you add marker objects to the map view. This is the quickest way to add a few markers with callouts.
- **Style layers:** you add your data as a source and draw it with a layer. This is faster for many markers, and lets you style markers from their data, add text labels and cluster them.

To place markers by **Mappls Pin** instead of coordinates, see [Mappls Pin](MapplsPin.md).

- [Annotations or layers?](#annotations-or-layers)
- **Annotations**
  - [Add a marker](#add-a-marker)
  - [Add many markers](#add-many-markers)
  - [Move or remove markers](#move-or-remove-markers)
  - [Use your own marker image](#use-your-own-marker-image)
  - [Use a custom view](#use-a-custom-view)
  - [Callouts and taps](#callouts-and-taps)
- **Style layers**
  - [Add markers with a symbol layer](#add-markers-with-a-symbol-layer)
  - [Different icons per marker](#different-icons-per-marker)
  - [Circle markers](#circle-markers)
  - [Handle taps on layer markers](#handle-taps-on-layer-markers)
  - [Update or remove layer markers](#update-or-remove-layer-markers)
  - [Cluster markers](#cluster-markers)
- [Troubleshooting](#troubleshooting)

## Annotations or layers?

| | Annotations | Style layers |
| :-- | :---------- | :----------- |
| Best for | Up to about 100 markers | Hundreds to thousands of markers |
| Setup | One call: `addAnnotation` | A source, a layer and (for icons) an image |
| Callout on tap | Built in | Write your own |
| Custom `UIView` markers, dragging | Yes, with `MGLAnnotationView` | No |
| Style from data (icon or color per category) | Per marker, in delegate methods | With expressions |
| Text labels that avoid overlapping | No | Yes |
| Clustering | No | Yes |
| After a [style change](MapStyles.md) | Kept automatically | Add again in `mapView(_:didFinishLoading:)` |

## Annotations

### Add a marker

Create an `MGLPointAnnotation`, set its coordinate and add it to the map. The map shows the default marker.

```swift
let marker = MGLPointAnnotation()
marker.coordinate = CLLocationCoordinate2D(latitude: 28.550834, longitude: 77.268918)
marker.title = "MapmyIndia"
marker.subtitle = "Okhla Phase 3, New Delhi"
mapView.addAnnotation(marker)
```

```objectivec
MGLPointAnnotation *marker = [[MGLPointAnnotation alloc] init];
marker.coordinate = CLLocationCoordinate2DMake(28.550834, 77.268918);
marker.title = @"MapmyIndia";
marker.subtitle = @"Okhla Phase 3, New Delhi";
[self.mapView addAnnotation:marker];
```

You can add annotations at any time, also before the map has finished loading.

### Add many markers

Add an array in one call, then fit the camera so all markers are visible:

```swift
let places: [(String, CLLocationCoordinate2D)] = [
    ("India Gate", CLLocationCoordinate2D(latitude: 28.612912, longitude: 77.229510)),
    ("Red Fort", CLLocationCoordinate2D(latitude: 28.656159, longitude: 77.241020)),
]

let markers = places.map { name, coordinate -> MGLPointAnnotation in
    let annotation = MGLPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = name
    return annotation
}

mapView.addAnnotations(markers)
mapView.showAnnotations(markers, animated: true)
```

### Move or remove markers

Changing `coordinate` moves a marker that is already on the map:

```swift
marker.coordinate = CLLocationCoordinate2D(latitude: 28.551, longitude: 77.269)
```

```swift
mapView.removeAnnotation(marker)          // one marker

if let all = mapView.annotations {        // all markers and shapes
    mapView.removeAnnotations(all)
}
```

### Use your own marker image

Return an `MGLAnnotationImage` from `mapView(_:imageFor:)` in your `MapplsMapViewDelegate`. Reuse images with a reuse identifier so the map doesn't create a new image per marker.

```swift
func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    let reuseIdentifier = "custom-marker"
    if let image = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
        return image
    }
    guard var image = UIImage(named: "marker") else { return nil }

    // The image is centered on the coordinate. For a pin whose tip is at the
    // bottom, add an inset of half the height so the tip touches the coordinate.
    image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height / 2, right: 0))
    return MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
}
```

```objectivec
- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id<MGLAnnotation>)annotation {
    NSString *reuseIdentifier = @"custom-marker";
    MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:reuseIdentifier];
    if (!annotationImage) {
        UIImage *image = [UIImage imageNamed:@"marker"];
        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height / 2, 0)];
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:reuseIdentifier];
    }
    return annotationImage;
}
```

To use different images, check the annotation (for example its `title`) and use one reuse identifier per image. Return `nil` to show the default marker.

### Use a custom view

For a marker built from a `UIView` (animations, dynamic content, dragging), return an `MGLAnnotationView` from `mapView(_:viewFor:)`. If this method returns a view, `mapView(_:imageFor:)` isn't called for that annotation.

```swift
func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    guard annotation is MGLPointAnnotation else { return nil }

    let reuseIdentifier = "dot"
    if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
        return view
    }

    let view = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
    view.bounds = CGRect(x: 0, y: 0, width: 24, height: 24)
    view.layer.cornerRadius = 12
    view.layer.borderWidth = 3
    view.layer.borderColor = UIColor.white.cgColor
    view.backgroundColor = .systemBlue
    view.isDraggable = true   // long-press and drag to move
    return view
}
```

Annotation views are regular views, so keep them to a few dozen. For more markers, use a [symbol layer](#add-markers-with-a-symbol-layer).

### Callouts and taps

```swift
// Show a callout with the title and subtitle when a marker is tapped.
func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    true
}

// Add a button to the callout...
func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    UIButton(type: .detailDisclosure)
}

// ...and react to it.
func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    mapView.deselectAnnotation(annotation, animated: true)
    // Open a detail screen here.
}

// Called for every marker tap, with or without a callout.
func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    print("Tapped:", annotation.title.flatMap { $0 } ?? "")
}
```

To select a marker from code: `mapView.selectAnnotation(marker, animated: true, completionHandler: nil)`.

For a fully custom callout, see [Custom Info Window](../Readme.md#custom-info-windowcustom-info-window).

## Style layers

Layers are part of the map style, so add them in `mapView(_:didFinishLoading:)`. This method runs again after every [style change](MapStyles.md), which also re-adds your markers.

### Add markers with a symbol layer

A symbol layer draws an icon, a text label, or both, for every point in a source.

```swift
import MapplsMap
import UIKit

class LayerMarkersViewController: UIViewController, MapplsMapViewDelegate {
    var mapView: MapplsMapView!
    var markerSource: MGLShapeSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapplsMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        view.addSubview(mapView)
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        // 1. The data: one feature per marker, with attributes you can style from.
        let places: [(String, String, CLLocationCoordinate2D)] = [
            ("India Gate", "monument", CLLocationCoordinate2D(latitude: 28.612912, longitude: 77.229510)),
            ("Red Fort", "monument", CLLocationCoordinate2D(latitude: 28.656159, longitude: 77.241020)),
            ("AIIMS", "hospital", CLLocationCoordinate2D(latitude: 28.567450, longitude: 77.210000)),
        ]
        let features = places.map { name, category, coordinate -> MGLPointFeature in
            let feature = MGLPointFeature()
            feature.coordinate = coordinate
            feature.identifier = name
            feature.attributes = ["name": name, "category": category]
            return feature
        }

        // 2. The source holds the data.
        let source = MGLShapeSource(identifier: "markers", features: features, options: nil)
        style.addSource(source)
        markerSource = source

        // 3. The icon image, registered with the style under a name.
        if let image = UIImage(named: "marker") {
            style.setImage(image, forName: "marker-icon")
        }

        // 4. The layer draws the icon and the name of each feature.
        let layer = MGLSymbolStyleLayer(identifier: "markers-layer", source: source)
        layer.iconImageName = NSExpression(forConstantValue: "marker-icon")
        layer.iconAnchor = NSExpression(forConstantValue: "bottom")   // tip of the pin on the coordinate
        layer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        layer.text = NSExpression(forKeyPath: "name")                 // label from the "name" attribute
        layer.textFontSize = NSExpression(forConstantValue: 12)
        layer.textAnchor = NSExpression(forConstantValue: "top")
        layer.textOffset = NSExpression(forConstantValue: NSValue(cgVector: CGVector(dx: 0, dy: 0.5)))
        layer.textColor = NSExpression(forConstantValue: UIColor.darkGray)
        layer.textHaloColor = NSExpression(forConstantValue: UIColor.white)
        layer.textHaloWidth = NSExpression(forConstantValue: 1)
        style.addLayer(layer)
    }
}
```

```objectivec
- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    MGLPointFeature *feature = [[MGLPointFeature alloc] init];
    feature.coordinate = CLLocationCoordinate2DMake(28.612912, 77.229510);
    feature.attributes = @{ @"name": @"India Gate" };

    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"markers" features:@[feature] options:nil];
    [style addSource:source];
    [style setImage:[UIImage imageNamed:@"marker"] forName:@"marker-icon"];

    MGLSymbolStyleLayer *layer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"markers-layer" source:source];
    layer.iconImageName = [NSExpression expressionForConstantValue:@"marker-icon"];
    layer.iconAnchor = [NSExpression expressionForConstantValue:@"bottom"];
    layer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@YES];
    layer.text = [NSExpression expressionForKeyPath:@"name"];
    layer.textAnchor = [NSExpression expressionForConstantValue:@"top"];
    [style addLayer:layer];
}
```

Source and layer identifiers must be unique in the style. Labels that would overlap other labels are hidden automatically; set `textAllowsOverlap` to `true` to always show them.

### Different icons per marker

Register one image per category, named after the category, and take the icon name from the feature's attribute:

```swift
if let hospital = UIImage(named: "hospital"), let monument = UIImage(named: "monument") {
    style.setImage(hospital, forName: "hospital")
    style.setImage(monument, forName: "monument")
    layer.iconImageName = NSExpression(forKeyPath: "category")   // "hospital" or "monument"
}
```

### Circle markers

A circle layer draws a colored dot per feature, with no image needed. The color can depend on an attribute:

```swift
let circles = MGLCircleStyleLayer(identifier: "markers-circles", source: source)
circles.circleRadius = NSExpression(forConstantValue: 8)
circles.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
circles.circleStrokeWidth = NSExpression(forConstantValue: 2)
circles.circleColor = NSExpression(
    forMGLMatchingKey: NSExpression(forKeyPath: "category"),
    in: [NSExpression(forConstantValue: "hospital"): NSExpression(forConstantValue: UIColor.systemRed),
         NSExpression(forConstantValue: "monument"): NSExpression(forConstantValue: UIColor.systemOrange)],
    default: NSExpression(forConstantValue: UIColor.systemBlue))
style.addLayer(circles)
```

### Handle taps on layer markers

Layer markers don't have callouts. Add a tap gesture recognizer once (in `viewDidLoad`) and look up the features under the tap:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ... create mapView ...

    let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
    // Let the map's own tap handling (annotations, callouts) run first.
    for recognizer in mapView.gestureRecognizers ?? [] where recognizer is UITapGestureRecognizer {
        tap.require(toFail: recognizer)
    }
    mapView.addGestureRecognizer(tap)
}

@objc func handleMapTap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: mapView)
    let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["markers-layer"])
    if let feature = features.first {
        print("Tapped:", feature.attribute(forKey: "name") ?? "")
    }
}
```

### Update or remove layer markers

To change the markers, give the source a new shape. The layer redraws immediately:

```swift
markerSource?.shape = MGLShapeCollectionFeature(shapes: newFeatures)
```

To remove them, remove the layer first, then the source:

```swift
if let style = mapView.style {
    if let layer = style.layer(withIdentifier: "markers-layer") { style.removeLayer(layer) }
    if let source = style.source(withIdentifier: "markers") { style.removeSource(source) }
}
```

To hide them for a while, use `layer.isVisible = false`.

### Cluster markers

With many markers close together, clustering replaces each group with one circle and a count. Zooming in splits the clusters.

```swift
let source = MGLShapeSource(identifier: "clustered", features: features,
                            options: [.clustered: true, .clusterRadius: 50])
style.addSource(source)

// Clusters: a circle with the number of markers.
let clusterCircles = MGLCircleStyleLayer(identifier: "clusters", source: source)
clusterCircles.predicate = NSPredicate(format: "cluster == YES")
clusterCircles.circleRadius = NSExpression(forConstantValue: 18)
clusterCircles.circleColor = NSExpression(forConstantValue: UIColor.systemBlue)
style.addLayer(clusterCircles)

let clusterCount = MGLSymbolStyleLayer(identifier: "cluster-count", source: source)
clusterCount.predicate = NSPredicate(format: "cluster == YES")
clusterCount.text = NSExpression(format: "CAST(point_count, 'NSString')")
clusterCount.textColor = NSExpression(forConstantValue: UIColor.white)
style.addLayer(clusterCount)

// Single markers that aren't part of a cluster.
let single = MGLSymbolStyleLayer(identifier: "unclustered", source: source)
single.predicate = NSPredicate(format: "cluster != YES")
single.iconImageName = NSExpression(forConstantValue: "marker-icon")
style.addLayer(single)
```

## Troubleshooting

| Symptom | Cause and fix |
| :------ | :------------ |
| Layer markers disappear after changing the style | Add sources and layers in `mapView(_:didFinishLoading:)`, which runs after every style load. |
| App crashes adding a source or layer | The identifier is already in use. Use unique identifiers, or check `style.source(withIdentifier:)` first. |
| Symbol layer shows nothing | The icon name doesn't match a name registered with `style.setImage(_:forName:)`, or the marker is outside the visible area. |
| Pin image floats above the location | For annotations, add the bottom alignment inset shown above. For layers, set `iconAnchor` to `"bottom"`. |
| Some labels are missing | They overlap other labels. Set `textAllowsOverlap` and `iconAllowsOverlap` to `true`. |
| Delegate methods aren't called | Set `mapView.delegate` before the map loads. |
