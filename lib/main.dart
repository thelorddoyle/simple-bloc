// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocProvider(
          create: (context) => PersonsBloc(),
          child: const MyHomePage(),
        ));
  }
}

// How do extensions work?

// Can extend on any keyword
extension LengthExtension on String {
  int getLength() {
    return length;
  }
}

// Here it is in action. I will use it now for creating an enum (PersonUrl) and then giving it a method via na extension
void fun() {
  String myString = 'Hello, there!';
  int length = myString.getLength();
  print(length);
}

// What are subscripts?

// In Flutter, a subscript refers to the ability to access individual elements
// or properties of a collection or object using square brackets [].
// It is a way to retrieve or set values at a specific index or key within a data structure.
extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

// We are extending the Iterable subscript to actually be able to operate
// similarly to a list, and access an item at index, but also changing
// the Type to be T? so that it can return null of the int provided
// has no value at that index

void testIt() {
  Iterable<String> names = ['foo', 'bar', 'baz'];
  var thisName = names[2];
  print(thisName);
}

// Why is this an abstract class?
// Because a Bloc looks like this: Bloc<Event, State>
// It takes a single Event generic type (in this case our Load Action)
// Abstract classes can hold different types of LoadActions inside of them but still only be one type
// But also! And importantly! Abstract classes CANNOT be initialised
// This helps us so that we cannot initialise a LoadAction class such as LoadAction.LoadImage and just send that to our bloc

@immutable
abstract class LoadAction {
  const LoadAction();
}

enum PersonUrl { persons1, persons2 }

extension UrlString on PersonUrl {
  String get urlString {
    return switch (this) {
      PersonUrl.persons1 => 'http://127.0.0.1:5500/api/person-1.json',
      PersonUrl.persons2 => 'http://127.0.0.1:5500/api/person-2.json'
    };
  }
}

@immutable
class LoadPersonsAction implements LoadAction {
  final PersonUrl url;

  const LoadPersonsAction({required this.url}) : super();
}

@immutable
class Person {
  final String name;
  final int age;

  // default / manual constructor
  const Person({required this.name, required this.age});

  // json constructor
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;

  @override
  String toString() => 'Person (name: $name, age: $age)';
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((value) => value.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  final Iterable<Person> people;
  final bool isRetrievedFromCache;

  const FetchResult({required this.people, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, people = $people)';
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
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
        final people = await getPersons(url.urlString);
        _cache[url] = people;
        final result = FetchResult(people: people, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homepage')),
      body: Column(children: [
        Row(
          children: [
            TextButton(
                onPressed: () => {
                      context
                          .read<PersonsBloc>()
                          .add(const LoadPersonsAction(url: PersonUrl.persons1))
                    },
                child: const Text('Load JSON #1')),
            TextButton(
                onPressed: () => {
                      context
                          .read<PersonsBloc>()
                          .add(const LoadPersonsAction(url: PersonUrl.persons2))
                    },
                child: const Text('Load JSON #2')),
          ],
        ),
        BlocBuilder<PersonsBloc, FetchResult?>(
          buildWhen: (previousResult, currentResult) {
            return previousResult?.people != currentResult?.people;
          },
          builder: (context, fetchResult) {
            fetchResult?.log();
            final people = fetchResult?.people;
            if (people == null) {
              return const SizedBox();
            }
            return Expanded(
              child: ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    final person = people[index]!;
                    return ListTile(title: Text(person.name));
                  }),
            );
          },
        )
      ]),
    );
  }
}
