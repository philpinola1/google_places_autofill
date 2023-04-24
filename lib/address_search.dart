import 'package:flutter/material.dart';
import 'place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken, this.result);

  final String? sessionToken;
  final Suggestion? result;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // The value provided for result is used as the return value of
        //  the call to [showSearch] that launched the search initially.
        close(context, result ?? Suggestion('', '', ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print('in buildResults...');
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    print('in buildSuggestions...');

    var pap = PlaceApiProvider(sessionToken!);

    var fb = FutureBuilder(
      // We will put the api call here
      future: query.isNotEmpty ? pap.fetchSuggestions(query, 'en') : null,
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                        // we will display the data returned from our future here
                        // title: Text(snapshot.data?.elementAt(index).placeId),
                        title: snapshot.data != null
                            ? Text((snapshot.data?.elementAt(index).mainText)!)
                            : const Text('bye'),
                        onTap: () {
                          close(context, (snapshot.data?.elementAt(index))!);
                        },
                      ),
                  itemCount: snapshot.data?.length)
              : const Text('Loading...'),
    );

    return fb;
  }
}
