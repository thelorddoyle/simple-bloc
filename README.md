# cubit

Simple project where I create a `flutter_bloc` and learn how it is implemented.

## Side Quests

I played around with the `extension` keyword:

```js
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
```

I updated the `Subscript` in Iterables (as it does not work like a List):

```js
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
```

I dug in to why Bloc Events are `abstract` classes:

```js
@immutable
abstract class LoadAction {
  const LoadAction();
}

// Because a Bloc looks like this: Bloc<Event, State>
// It takes a single Event generic type (in this case our Load Action)
// Abstract classes can hold different types of LoadActions inside of them but still only be one type
// But also! And importantly! Abstract classes CANNOT be initialised
// This helps us so that we cannot initialise a LoadAction class such as LoadAction.LoadImage and just send that to our bloc
```

## Main Quest

Implement a basic Bloc that takes in a `LoadAction` event and emits a State of `FetchResult`.

I use Live Server (VSCode extension) and reference the local url of two person data JSON files e.g.

```js
[
  {
    name: "Foo 1",
    age: 20,
  },
  {
    name: "Bar 1",
    age: 30,
  },
  {
    name: "Bax 1",
    age: 40,
  },
];
```

I implement two buttons: Load JSON 1 and Load JSON 2.

If we already have the JSON X state (FetchResult) in cache, just use the cached data and don't make the request.

You can view all implemented logic in `main.dart`.
