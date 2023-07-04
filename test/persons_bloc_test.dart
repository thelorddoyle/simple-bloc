import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';
import 'package:testingbloc_course/bloc/person.dart';
import 'package:testingbloc_course/bloc/persons_bloc.dart';

const mockedPersons1 = [
  Person(name: 'Daniel', age: 34),
  Person(name: 'Luke', age: 54)
];

const mockedPersons2 = [
  Person(name: 'Jordan', age: 23),
  Person(name: 'Dom', age: 12)
];

// we ignore the urls here
Future<Iterable<Person>> mockGetPersons1(String url) =>
    Future.value(mockedPersons1);

// so we can use _ here
Future<Iterable<Person>> mockGetPersons2(String _) =>
    Future.value(mockedPersons2);

void main() {
  group('Testing persons bloc', () {
    // write out tests here
    late PersonsBloc bloc;
    setUp(() => {bloc = PersonsBloc()});

    blocTest<PersonsBloc, FetchResult?>('Test initial state',
        build: () => bloc, verify: (bloc) => expect(bloc.state, null));

    blocTest<PersonsBloc, FetchResult?>(
      'Mock retrieving person from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
            const LoadPersonsAction(loader: mockGetPersons1, url: 'dummyUrl1'));
        // test caching
        bloc.add(
            const LoadPersonsAction(loader: mockGetPersons1, url: 'dummyUrl1'));
      },
      expect: () => [
        const FetchResult(people: mockedPersons1, isRetrievedFromCache: false),
        const FetchResult(people: mockedPersons1, isRetrievedFromCache: true)
      ],
    );

    blocTest<PersonsBloc, FetchResult?>(
      'Mock retrieving person from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(
            const LoadPersonsAction(loader: mockGetPersons1, url: 'dummyUrl1'));
        // test caching
        bloc.add(
            const LoadPersonsAction(loader: mockGetPersons2, url: 'dummyUrl2'));
      },
      expect: () => [
        const FetchResult(people: mockedPersons1, isRetrievedFromCache: false),
        const FetchResult(people: mockedPersons2, isRetrievedFromCache: false)
      ],
    );
  });
}
