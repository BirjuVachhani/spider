From Spider `v0.4.0`, multiple paths can be specified for a single group to collect references from multiple directories and generate all the references under single dart class.

**Example**

```yaml
groups:
  - paths:
      - assets/images
      - assets/more_images/
    class_name: Images
    package: res
    types: [ .png, .jpg, .jpeg, .webp, .webm, .bmp ]
```

By using `paths`, multiple source directories can be specified. Above example will generate references from `assets/images` and `assets/more_images/` under a single dart class named `Images`.