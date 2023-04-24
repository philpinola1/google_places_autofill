import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? zipCode;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

// For storing our result
class Suggestion {
  final String placeId;
  final String description;
  final String mainText;

  Suggestion(this.placeId, this.description, this.mainText);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId, mainText: $mainText)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final String sessionToken;

  static const String androidKey = 'AIzaSyCbBQQ86-GY93iL1wYd5VH47pqgFTQwpQw';
  static const String iosKey = 'AIzaSyCbBQQ86-GY93iL1wYd5VH47pqgFTQwpQw';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    print('fetching suggestions...');
    final request = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'types': 'address',
          'language': lang,
          'components': 'country:us',
          'key': apiKey,
          'sessiontoken': sessionToken
        });

    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description'],
                p['structured_formatting']['main_text']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      print(response.statusCode);
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    print('making request to maps.googleapis.com/maps/api/place/details/json');
    final request = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'address_component',
          'key': apiKey,
          'sessiontoken': sessionToken
        });

    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final components =
            result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
        components.forEach((c) {
          final List type = c['types'];
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          }
          if (type.contains('route')) {
            place.street = c['long_name'];
          }
          if (type.contains('locality')) {
            place.city = c['long_name'];
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
        });
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
