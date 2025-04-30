<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# TEA Coaster

<div style="display: flex; align-items: center;">
    <img src="https://github.com/constacts/coaster/blob/main/doc/images/teacoaster_logo_clean.png?raw=true" alt="logo" style="width: 270px; height: auto;">
    <div style="margin-left: 20px;">TEA <span style="background-color: #f6e5c9; padding: 2px 4px; border-radius: 4px;">Coaster</span> is a Flutter package that implements The Elm Architecture (TEA) pattern, bringing the elegance of Elm's architecture to Flutter development.</div>
</div>

## Features

- **Model-View-Update (MVU) Architecture**: A clean and predictable state management pattern
- **Command Pattern**: Handle side effects in a structured way
- **Subscription System**: Manage event streams and subscriptions
- **Type Safety**: Full type safety with Dart's strong typing system
- **Testability**: Easy to test with clear separation of concerns

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  coaster: ^0.0.2
```

## Usage

### Basic Counter Example

Here's a simple counter application using TEA Coaster:

```dart
import 'package:flutter/material.dart';
import 'package:coaster/coaster.dart';

// Define your model
class CounterModel {
  final int count;
  
  CounterModel({required this.count});
}

// Define your messages
enum CounterMessage { increment, decrement }

// Create your update function
CounterModel update(CounterModel model, CounterMessage message) {
  switch (message) {
    case CounterMessage.increment:
      return CounterModel(count: model.count + 1);
    case CounterMessage.decrement:
      return CounterModel(count: model.count - 1);
  }
}

// Create your view
Widget view(CounterModel model, Dispatch<CounterMessage> dispatch) {
  return Scaffold(
    appBar: AppBar(title: Text('Counter Example')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Count: ${model.count}', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => dispatch(CounterMessage.increment),
                child: Text('Increment'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => dispatch(CounterMessage.decrement),
                child: Text('Decrement'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Use the Coaster widget
class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Coaster<CounterModel, CounterMessage>(
        init: CounterModel(count: 0),
        update: update,
        view: view,
      ),
    );
  }
}
```

### Advanced Features

For more advanced examples including:
- Command pattern for side effects
- Subscription system for event handling
- Complex state management

Please check out our [example directory](https://github.com/constacts/coaster/tree/main/example) for complete examples.



## Contributing

We welcome contributions! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
