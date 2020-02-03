### Example

Just use following command:

```shell
spider
```

#### Before
```dart
Widget build(BuildContext context) {
  return Image(image: AssetImage('assets/background.png'));
}
```

#### After
```dart
Widget build(BuildContext context) {
  return Image(image: AssetImage(Assets.background));
}
```

#### Generated Assets Class
```dart
class Assets {
  static const String background = 'assets/background.png';
}
```