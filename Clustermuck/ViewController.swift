import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {

    var map: MGLMapView?
    var features = [MGLFeature]()
    var clustered = false

    override func viewDidLoad() {
        super.viewDidLoad()

        map = MGLMapView(frame: view.bounds)
        map!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map!.delegate = self
        view.addSubview(map!)

        map!.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
    }

    func handleLongPress(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            clustered = !clustered
            update()
        }
    }

    func update() {
        if let map = map,
           let buildings = map.style().layer(withIdentifier: "building") {
            if let source = map.style().source(withIdentifier: "source"),
               let layer = map.style().layer(withIdentifier: "layer") {
                map.style().remove(source)
                map.style().remove(layer)
            }

            let source = MGLGeoJSONSource(identifier: "source", features: features, options: [.clustered: clustered])
            map.style().add(source)

            let layer = MGLCircleStyleLayer(identifier: "layer", source: source)
            layer.circleColor = MGLStyleValue(rawValue: UIColor.red)
            layer.circleRadius = MGLStyleValue(rawValue: NSNumber(value: 5))
            layer.circleOpacity = MGLStyleValue(rawValue: NSNumber(value: 0.25))
            map.style().insert(layer, below: buildings)
        }
    }

    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            let sw = CLLocationCoordinate2D(latitude: 45, longitude: -123)
            let ne = CLLocationCoordinate2D(latitude: 46, longitude: -122)
            for _ in 0..<10000 {
                let feature = MGLPointFeature()
                let lat = CLLocationDegrees(Float.random(min: Float(sw.latitude), max: Float(ne.latitude)))
                let lon = CLLocationDegrees(Float.random(min: Float(sw.longitude), max: Float(ne.longitude)))
                feature.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                self.features.append(feature)
            }
            DispatchQueue.main.async {
                self.update()
                mapView.setVisibleCoordinateBounds(MGLCoordinateBoundsMake(sw, ne),
                                                   edgePadding: UIEdgeInsetsMake(20, 20, 20, 20),
                                                   animated: false)
            }
        }
    }

}

// https://gist.github.com/AppleBetas/1ffc212c9b860b5a79133884d245ac75
extension Float {
    // Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random num Float

     - parameter min: Float
     - parameter max: Float

     - returns: Float
     */
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}
