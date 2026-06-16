import Foundation
import CoreLocation
import Combine

final class CustomerLocationManager:
NSObject,
ObservableObject,
CLLocationManagerDelegate {

    private let manager =
    CLLocationManager()

    @Published var latitude = 0.0
    @Published var longitude = 0.0

    @Published var heading = 0.0
    @Published var speed = 0.0

    @Published var locationReady = false
    @Published var city = ""
    @Published var state = ""

    override init() {

        super.init()

        manager.delegate = self

        manager.desiredAccuracy =
        kCLLocationAccuracyBest

        manager.startUpdatingHeading()
    }

    func requestLocation() {

        manager.requestWhenInUseAuthorization()

        manager.startUpdatingLocation()
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
        
        reverseGeocode(
            location
        )

        speed =
        max(0, location.speed)

        locationReady = true
    }

    private func reverseGeocode(
        _ location: CLLocation
    ) {

        CLGeocoder()
            .reverseGeocodeLocation(
                location
            ) { placemarks, error in

                guard let place =
                    placemarks?.first
                else {

                    return
                }

                DispatchQueue.main.async {

                    self.city =
                        place.locality ?? ""

                    self.state =
                        place.administrativeArea ?? ""
                }
            }
    }
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {

        heading =
        newHeading.trueHeading
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        switch manager.authorizationStatus {

        case .authorizedAlways,
             .authorizedWhenInUse:

            manager.startUpdatingLocation()

        default:

            break
        }
    }
}
