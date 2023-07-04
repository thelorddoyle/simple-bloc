import 'package:flutter/foundation.dart' show immutable;
import 'package:testingbloc_course/bloc/person.dart';

// enum PersonUrl { persons1, persons2 }

// extension UrlString on PersonUrl {
//   String get urlString {
//     return switch (this) {
//       PersonUrl.persons1 => 'http://127.0.0.1:5500/api/person-1.json',
//       PersonUrl.persons2 => 'http://127.0.0.1:5500/api/person-2.json'
//     };
//   }
// }

const persons1 = 'http://127.0.0.1:5500/api/person-1.json';
const persons2 = 'http://127.0.0.1:5500/api/person-2.json';

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final String url;
  final PersonsLoader loader;

  const LoadPersonsAction({required this.loader, required this.url}) : super();
}
