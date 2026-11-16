[<img src="https://about.mappls.com/images/mappls-b-logo.svg" height="60"/>](https://about.mappls.com/api/)

# Map Styles

[← Back to Mappls Map SDK](../Readme.md)

A **map style** decides how the map looks: colors, labels and which features are shown, for example a day map, a night map or a grey map. The styles available to you depend on your Mappls license. The SDK downloads that list when the map is authorized, and shows the default style automatically.

- [Get the available styles](#get-the-available-styles)
- [The MapplsMapStyle object](#the-mapplsmapstyle-object)
- [Set a style](#set-a-style)
- [Example: a style picker](#example-a-style-picker)
- [Use your own style URL](#use-your-own-style-url)
- [API reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## Get the available styles

The style list is ready after the map is authorized. There are two ways to get it.

**1. Delegate callback (recommended).** `MapplsMapView` calls `didLoadedMapplsMapStyles(_:styles:withError:)` right after a successful authorization:

```swift
class ViewController: UIViewController, MapplsMapViewDelegate {
    var mapView: MapplsMapView!
    var styles: [MapplsMapStyle] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapplsMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
    }

    func didLoadedMapplsMapStyles(_ mapView: MapplsMapView, styles: [MapplsMapStyle], withError error: Error?) {
        self.styles = styles
        for style in styles {
            print(style.name ?? "", style.displayName ?? "", style.isDefault == 1 ? "(default)" : "")
        }
    }
}
```

```objectivec
- (void)didLoadedMapplsMapStyles:(MapplsMapView *)mapView styles:(NSArray<MapplsMapStyle *> *)styles withError:(NSError *)error {
    for (MapplsMapStyle *style in styles) {
        NSLog(@"%@ - %@", style.name, style.displayName);
    }
}
```

**2. Ask the map view.** After `mapView(_:authorizationCompleted:withError:)` reports success, call `getAvailableMapplsMapStyle()` at any time:

```swift
func mapView(_ mapView: MapplsMapView, authorizationCompleted isSuccess: Bool, withError error: Error?) {
    guard isSuccess else { return }
    let styles = mapView.getAvailableMapplsMapStyle()
    print("\(styles.count) styles available")
}
```

Before authorization finishes, `getAvailableMapplsMapStyle()` returns an empty list.

## The MapplsMapStyle object

`MapplsMapStyle` comes from `MapplsAPICore`. Add `import MapplsAPICore` if you use it outside a `MapplsMapView` delegate method.

| Property | Type | Use it for |
| :------- | :--- | :--------- |
| `name` | `String?` | The identifier. Pass it to `setMapplsMapStyle(_:)`. |
| `displayName` | `String?` | A readable name to show in your UI. |
| `imageUrl` | `String?` | URL of a preview image, for a style picker. |
| `isDefault` | `Int` | `1` for the style the SDK shows by default. |
| `styleUrl` | `String?` | The style's URL. The SDK uses it for you; you don't need it to switch styles. |

## Set a style

Pass a style's `name` from the [available styles](#get-the-available-styles) to `setMapplsMapStyle(_:)`:

```swift
if let name = styles.first(where: { $0.isDefault != 1 })?.name {
    mapView.setMapplsMapStyle(name)
}
```

```objectivec
MapplsMapStyle *style = styles.firstObject;
[self.mapView setMapplsMapStyle:style.name];
```

Always take the `name` from the list you received: the names available to you depend on your license.

What happens next:

- The map reloads with the new style, and `mapView(_:didFinishLoading:)` is called when it is ready. Add your own layers there, because a style change removes them.
- Markers added with `addAnnotation` or `addMapplsAnnotation` stay on the map.
- **The choice is remembered.** The next `MapplsMapView` you create, also after the app restarts, uses the same style.
- If the name doesn't match any available style, the map shows the default style instead.

## Example: a style picker

```swift
import MapplsAPICore
import MapplsMap
import UIKit

class StylePickerViewController: UIViewController, MapplsMapViewDelegate {
    var mapView: MapplsMapView!
    private var styles: [MapplsMapStyle] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapplsMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        view.addSubview(mapView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Style", style: .plain,
                                                            target: self, action: #selector(showStyles))
    }

    func didLoadedMapplsMapStyles(_ mapView: MapplsMapView, styles: [MapplsMapStyle], withError error: Error?) {
        DispatchQueue.main.async {
            self.styles = styles
        }
    }

    @objc private func showStyles() {
        let sheet = UIAlertController(title: "Map style", message: nil, preferredStyle: .actionSheet)
        for style in styles {
            guard let name = style.name else { continue }
            sheet.addAction(UIAlertAction(title: style.displayName ?? name, style: .default) { _ in
                self.mapView.setMapplsMapStyle(name)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true)
    }
}
```

## Use your own style URL

To show a style that isn't in the Mappls list, stop the SDK from applying Mappls styles **before** you create the map view, then set `styleURL` yourself:

```swift
MapplsMapConfiguration.setIsDefaultStyleEnabled(false)

let mapView = MapplsMapView(frame: view.bounds)
mapView.styleURL = URL(string: "https://example.com/your-style.json")
```

With this setting, `setMapplsMapStyle(_:)` has no visible effect. Turn it back on with `MapplsMapConfiguration.setIsDefaultStyleEnabled(true)`.

## API reference

| API | Class | What it does |
| :-- | :---- | :----------- |
| `didLoadedMapplsMapStyles(_:styles:withError:)` | `MapplsMapViewDelegate` | Delivers the available styles after authorization. |
| `getAvailableMapplsMapStyle()` | `MapplsMapView` | Returns the available styles (empty before authorization). |
| `setMapplsMapStyle(_:)` | `MapplsMapView` | Switches to the style with this `name` and remembers it. |
| `setIsDefaultStyleEnabled(_:)` | `MapplsMapConfiguration` | `false` stops the SDK from applying Mappls styles. |
| `mapView(_:didFinishLoading:)` | `MGLMapViewDelegate` | Called each time a style finishes loading. |
| `mapViewDidFailLoadingMap(_:withError:)` | `MGLMapViewDelegate` | Called when a style can't be loaded. |

## Troubleshooting

| Symptom | Cause and fix |
| :------ | :------------ |
| Empty style list | Authorization hasn't finished or failed. Wait for `authorizationCompleted` with `isSuccess == true`. |
| `setMapplsMapStyle` shows the default style | The name isn't in your list. Use a `name` from `getAvailableMapplsMapStyle()`. Names are case-sensitive. |
| The map always opens with an old style | The last selected style is remembered. Call `setMapplsMapStyle(_:)` with the style you want. |
| My custom layers disappear after a style change | Add them again in `mapView(_:didFinishLoading:)`. |
| The map stays blank | Check `mapView(_:authorizationCompleted:withError:)` and `mapViewDidFailLoadingMap(_:withError:)` for an error, and see [SDK error codes](../Readme.md#sdk-error-codes). |
