[<img src="https://about.mappls.com/images/mappls-b-logo.svg" height="60"/>](https://about.mappls.com/api/)

# Polylines

[← Back to Mappls Map SDK](../Readme.md)

A polyline is a line through a list of coordinates, for example a route, a trip or a boundary. There are two ways to draw one:

- **Annotations:** you add an `MGLPolyline` to the map view and style it in delegate methods. The quickest way to draw a simple line.
- **Style layers:** you add the line as a source and draw it with a line layer. This adds zoom-based width, dashes, gradients, an outline (casing), and drawing below the map's labels.

- [Annotations or layers?](#annotations-or-layers)
- **Annotations**
  - [Add a polyline](#add-a-polyline)
  - [Color, width and opacity](#color-width-and-opacity)
  - [Fit the line on screen](#fit-the-line-on-screen)
  - [Update or remove the polyline](#update-or-remove-the-polyline)
- **Style layers**
  - [Add a line layer](#add-a-line-layer)
  - [Route with an outline](#route-with-an-outline)
  - [Width that changes with zoom](#width-that-changes-with-zoom)
  - [Dashed line](#dashed-line)
  - [Gradient line](#gradient-line)
  - [Draw below the map labels](#draw-below-the-map-labels)
  - [Update, hide or remove the line](#update-hide-or-remove-the-line)
- [Troubleshooting](#troubleshooting)

## Annotations or layers?

| | Annotations | Style layers |
| :-- | :---------- | :----------- |
| Best for | A few simple lines | Routes, many lines, styled lines |
| Color, width, opacity | Yes, in delegate methods | Yes, also per feature and per zoom level |
| Dashes, gradient, outline, rounded ends | No | Yes |
| Position in the map | Above the map labels | Anywhere, for example below labels |
| Tap detection | Built in (`didSelect`) | With `visibleFeatures(at:styleLayerIdentifiers:)` |
| After a [style change](MapStyles.md) | Kept automatically | Add again in `mapView(_:didFinishLoading:)` |

## Annotations

### Add a polyline

```swift
var coordinates = [
    CLLocationCoordinate2D(latitude: 28.550834, longitude: 77.268918),
    CLLocationCoordinate2D(latitude: 28.551059, longitude: 77.268890),
    CLLocationCoordinate2D(latitude: 28.550938, longitude: 77.267641),
    CLLocationCoordinate2D(latitude: 28.551764, longitude: 77.267575),
]
let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
polyline.title = "Route"
mapView.addAnnotation(polyline)
```

```objectivec
CLLocationCoordinate2D coordinates[] = {
    CLLocationCoordinate2DMake(28.550834, 77.268918),
    CLLocationCoordinate2DMake(28.551059, 77.268890),
    CLLocationCoordinate2DMake(28.550938, 77.267641),
};
MGLPolyline *polyline = [MGLPolyline polylineWithCoordinates:coordinates count:3];
[self.mapView addAnnotation:polyline];
```

### Color, width and opacity

Implement these `MapplsMapViewDelegate` methods. They are called for every polyline, so check `title` (or keep a reference) to style lines differently. Defaults: the map's tint color, 3 points wide, fully opaque.

```swift
func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    annotation.title == "Route" ? .systemBlue : .systemGray
}

func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
    6
}

func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
    0.8
}
```

```objectivec
- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation {
    return [UIColor systemBlueColor];
}

- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(MGLPolyline *)annotation {
    return 6;
}
```

### Fit the line on screen

```swift
let edgePadding = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
let camera = mapView.cameraThatFitsShape(polyline, direction: 0, edgePadding: edgePadding)
mapView.setCamera(camera, animated: true)
```

### Update or remove the polyline

Setting new coordinates redraws a polyline that is already on the map, for example to extend a live track:

```swift
coordinates.append(CLLocationCoordinate2D(latitude: 28.5521, longitude: 77.2671))
polyline.setCoordinates(&coordinates, count: UInt(coordinates.count))
```

```swift
mapView.removeAnnotation(polyline)
```

## Style layers

Add sources and layers in `mapView(_:didFinishLoading:)`. It runs again after every [style change](MapStyles.md), which re-adds your line.

### Add a line layer

```swift
import MapplsMap
import UIKit

class RouteViewController: UIViewController, MapplsMapViewDelegate {
    var mapView: MapplsMapView!
    var routeSource: MGLShapeSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapplsMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        view.addSubview(mapView)
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        var coordinates = [
            CLLocationCoordinate2D(latitude: 28.550834, longitude: 77.268918),
            CLLocationCoordinate2D(latitude: 28.551059, longitude: 77.268890),
            CLLocationCoordinate2D(latitude: 28.550938, longitude: 77.267641),
            CLLocationCoordinate2D(latitude: 28.551764, longitude: 77.267575),
        ]
        let route = MGLPolylineFeature(coordinates: &coordinates, count: UInt(coordinates.count))

        let source = MGLShapeSource(identifier: "route", shape: route, options: nil)
        style.addSource(source)
        routeSource = source

        let line = MGLLineStyleLayer(identifier: "route-line", source: source)
        line.lineColor = NSExpression(forConstantValue: UIColor.systemBlue)
        line.lineWidth = NSExpression(forConstantValue: 6)
        line.lineCap = NSExpression(forConstantValue: "round")    // rounded ends
        line.lineJoin = NSExpression(forConstantValue: "round")   // rounded corners
        line.lineOpacity = NSExpression(forConstantValue: 0.9)
        style.addLayer(line)
    }
}
```

```objectivec
- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    CLLocationCoordinate2D coordinates[] = {
        CLLocationCoordinate2DMake(28.550834, 77.268918),
        CLLocationCoordinate2DMake(28.551059, 77.268890),
        CLLocationCoordinate2DMake(28.550938, 77.267641),
    };
    MGLPolylineFeature *route = [MGLPolylineFeature polylineWithCoordinates:coordinates count:3];
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"route" shape:route options:nil];
    [style addSource:source];

    MGLLineStyleLayer *line = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-line" source:source];
    line.lineColor = [NSExpression expressionForConstantValue:[UIColor systemBlueColor]];
    line.lineWidth = [NSExpression expressionForConstantValue:@6];
    line.lineCap = [NSExpression expressionForConstantValue:@"round"];
    line.lineJoin = [NSExpression expressionForConstantValue:@"round"];
    [style addLayer:line];
}
```

To draw several lines from one source, pass `MGLShapeCollectionFeature(shapes: [line1, line2])` as the shape.

### Route with an outline

Draw the same source twice: a wider white "casing" first, then the colored line on top. Layers added later are drawn above earlier ones.

```swift
let casing = MGLLineStyleLayer(identifier: "route-casing", source: source)
casing.lineColor = NSExpression(forConstantValue: UIColor.white)
casing.lineWidth = NSExpression(forConstantValue: 10)
casing.lineCap = NSExpression(forConstantValue: "round")
casing.lineJoin = NSExpression(forConstantValue: "round")
style.addLayer(casing)

style.addLayer(line)   // the 6-point blue line from above
```

### Width that changes with zoom

Thin when zoomed out, wide when zoomed in. Values between the stops are interpolated:

```swift
line.lineWidth = NSExpression(forMGLInterpolating: .zoomLevelVariable,
                              curveType: .linear,
                              parameters: nil,
                              stops: NSExpression(forConstantValue: [12: 3, 18: 12]))
```

### Dashed line

The pattern alternates dash and gap lengths, in multiples of the line width:

```swift
let dashed = MGLLineStyleLayer(identifier: "route-dashed", source: source)
dashed.lineColor = NSExpression(forConstantValue: UIColor.systemGray)
dashed.lineWidth = NSExpression(forConstantValue: 4)
dashed.lineDashPattern = NSExpression(forConstantValue: [2, 1.5])
style.addLayer(dashed)
```

### Gradient line

A gradient colors the line from start (`0`) to end (`1`). It needs line distance data in the source, so create the source with the `.lineDistanceMetrics` option:

```swift
let source = MGLShapeSource(identifier: "route", shape: route, options: [.lineDistanceMetrics: true])
style.addSource(source)

let line = MGLLineStyleLayer(identifier: "route-line", source: source)
line.lineWidth = NSExpression(forConstantValue: 6)
line.lineGradient = NSExpression(forMGLInterpolating: NSExpression(forVariable: "lineProgress"),
                                 curveType: .linear,
                                 parameters: nil,
                                 stops: NSExpression(forConstantValue: [0: UIColor.systemGreen,
                                                                        1: UIColor.systemRed]))
style.addLayer(line)
```

### Draw below the map labels

By default your layer is drawn on top of everything, including street names. To draw it below the labels, insert it below the style's first symbol layer:

```swift
if let firstLabelLayer = style.layers.first(where: { $0 is MGLSymbolStyleLayer }) {
    style.insertLayer(line, below: firstLabelLayer)
} else {
    style.addLayer(line)
}
```

### Update, hide or remove the line

```swift
// New coordinates: give the source a new shape. The line redraws immediately.
var newCoordinates = [/* ... */] as [CLLocationCoordinate2D]
routeSource?.shape = MGLPolylineFeature(coordinates: &newCoordinates, count: UInt(newCoordinates.count))

// Hide and show.
mapView.style?.layer(withIdentifier: "route-line")?.isVisible = false

// Remove: layers first, then the source.
if let style = mapView.style {
    if let layer = style.layer(withIdentifier: "route-line") { style.removeLayer(layer) }
    if let source = style.source(withIdentifier: "route") { style.removeSource(source) }
}
```

## Troubleshooting

| Symptom | Cause and fix |
| :------ | :------------ |
| Line layer disappears after changing the style | Add sources and layers in `mapView(_:didFinishLoading:)`, which runs after every style load. |
| App crashes adding a source or layer | The identifier is already in use. Use unique identifiers, or check `style.source(withIdentifier:)` first. |
| Gradient isn't drawn | The source needs the `.lineDistanceMetrics: true` option. |
| Line covers street names | Insert it [below the map labels](#draw-below-the-map-labels). |
| Annotation polyline ignores my color | Implement `mapView(_:strokeColorForShapeAnnotation:)` in the map view's delegate, and set the delegate before adding the line. |
| Removing the source fails | Remove every layer that uses the source first. |
