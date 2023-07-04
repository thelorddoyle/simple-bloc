import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/main.dart';

import 'bloc_actions.dart';

extension IsEqualIgnoringOrdering<T> on Iterable<T> {
  bool isEqualIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

// const Iterable<String> names = ['foo', 'bar', 'baz'];

// const Iterable<String> otherNames = ['jazz', 'bar', 'baz'];

// void testThis() {
//   print(names.isEqualIgnoringOrdering(otherNames));
// }

@immutable
class FetchResult {
  final Iterable<Person> people;
  final bool isRetrievedFromCache;

  const FetchResult({required this.people, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, people = $people)';

  @override
  bool operator ==(covariant FetchResult other) =>
      people.isEqualIgnoringOrdering(other.people) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(people, isRetrievedFromCache);
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;
      _cache.log();
      if (_cache.containsKey(url)) {
        // we have value of cache
        final cachedPeople = _cache[url]!;
        final result =
            FetchResult(people: cachedPeople, isRetrievedFromCache: true);
        emit(result);
      } else {
        final loader = event.loader;
        final people = await loader(url);
        _cache[url] = people;
        final result = FetchResult(people: people, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}
