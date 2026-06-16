import Foundation
import CoreLocation
import Combine

final class MerchantLocationManager:
NSObject,
ObservableObject,
CLLocationManagerDelegate {

    private let manager =
    CLLocationManager()

    @Published var latitude = 0.0
    @Published var longitude = 0.0
    @Published var altitude = 0.0

    @Published var accuracy = 0.0
    @Published var speed = 0.0
    @Published var heading = 0.0

    @Published var locationCaptured = false

    override init() {

        super.init()

        manager.delegate = self

        manager.desiredAccuracy =
        kCLLocationAccuracyBestForNavigation

        manager.distanceFilter = 1
    }

    func requestLocation() {

        let status = manager.authorizationStatus

        switch status {

        case .notDetermined:

            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse,
             .authorizedAlways:

            manager.startUpdatingLocation()

            manager.startUpdatingHeading()

        default:

            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location =
        locations.last else {

            return
        }

        latitude =
        location.coordinate.latitude

        longitude =
        location.coordinate.longitude

        altitude =
        location.altitude

        accuracy =
        location.horizontalAccuracy

        speed =
        location.speed

        locationCaptured = true
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        switch manager.authorizationStatus {

        case .authorizedWhenInUse,
             .authorizedAlways:

            print("Location Permission Granted")

            manager.startUpdatingLocation()

            manager.startUpdatingHeading()

        case .denied:

            print("Location Permission Denied")

        case .restricted:

            print("Location Permission Restricted")

        case .notDetermined:

            print("Location Permission Not Decided")

        @unknown default:

            break
        }
    }
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {

        heading =
        newHeading.trueHeading
    }
}
