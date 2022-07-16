
Spider provides supports for multiple configurations and classifications. If you wanna group your assets by module, type or anything, you can do that using `groups` in spider.

**Example**


Suppose you have both vector(SVGs) and raster images in your project and you want to me classified separately so that you can use them with separate classes. You can use groups here. Keep your vector and raster images in separate folder and specify them in the config file.

`spider.yaml`
```yaml
groups:
  - path: assets/images
    class_name: Images
    package: res
  - path: assets/vectors
    class_name: Svgs
    package: res
```

Here, first item in the list indicates to group assets of `assets/images` folder under class named `Images` and the second one indicates to group assets of `assets/vectors` directory under class named `Svgs`.

So when you refer to `Images` class, auto-complete suggests raster images only and you know that you can use them with `AssetImage` and other one with vector rendering library.

## Categorizing by File Extension

By default, Spider allows any file to be referenced in the dart code. but you can change that behavior. You can specify which files you want to be referenced.

```yaml
path: assets
class_name: Assets
package: res
types: [ jpg, png, jpeg, webp, bmp, gif ]
```

## Sub grouping

Starting from `v3.2.0`, you can specify sub groups for a group if you ever want to use different prefixes for different types.

```yaml
groups:
  - class_name: Images
    sub_groups:
      - path: assets/images
        prefix: png
        types: [ .png ]
      - path: assets/vectors
        prefix: svg
        types: [ .svg ]
```

This configuration will add `png` prefix for the generated references if it is a **PNG** image file and `jpg` prefix if it is a **JPG** or **JPEG** image file. Notice that instead of specifying `path` in the group, we specified it directly to the sub-group.


<br/>