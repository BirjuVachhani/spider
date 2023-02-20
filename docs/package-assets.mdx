> This feature is introduced in Spider [v4.1.0](/spider/changelog/#410)

Flutter supports bundling of package assets which allows you to expose assets put into `lib` forlder of your package.
You can read more about it on offical Flutter docs [here](https://docs.flutter.dev/development/ui/assets-and-images#bundling-of-package-assets).

Spider now supports assets generation for this specific scenario. If you are a package/library developer and you're
including assets in your `lib` folder that you may want user to access properly, Generating package compatible assets will help you do that.
This will allow package authers to expose assets using generated dart references.

For example, If you have your assets in your package like this:

```
lib/images
├── image1.png
├── image2.png
├── image3.png
├── image4.png
└── image5.png
```

then put this in your package's `spider.yaml` file configuration file:

```yaml
groups:
- path: packages/<package_name>/images
    class_name: PackageImages
    types: [ .png, .jpg, .jpeg, .webp, .webm, .bmp ]
```
Notice the `path` here is a special one that does all the magic.

Running spider build command would generate this:

```yaml
lib/resources
├── package_images.dart
└── resources.dart
```

```dart
part of 'resources.dart';

class PackageImages {
  PackageImages._();

  static const String image1 = 'packages/<package_name>/images/image1.png';
  static const String image2 = 'packages/<package_name>/images/image2.png';
  static const String image3 = 'packages/<package_name>/images/image3.png';
  static const String image4 = 'packages/<package_name>/images/image4.png';
  static const String image5 = 'packages/<package_name>/images/image5.png';
}
```

### IMPORTANT:

It is a hard requirement from Flutter that you mention each and every assets individually in your application's pubspec.yaml file.