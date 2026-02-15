import CoreLocation

func reverseGeocode(lat: Double, lon: Double) async -> String? {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: lat, longitude: lon)
    
    do {
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first {
            var items: [String] = []
            
            if let street = placemark.thoroughfare {
                items.append(street)
            }
            if let city = placemark.locality {
                items.append(city)
            }
            if let zone = placemark.subLocality {
                items.append(zone)
            }
            
            return items.joined(separator: ", " )
        }
        return nil
    } catch {
        return nil
    }
}
