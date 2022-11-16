> This feature is introduced in Spider [v3.2.0](/spider/changelog/#320)

Spider allows you to specify **ignore rules** for the generated dart files so that your linter won't complain about certains rules
it can't follow. e.g. **public_member_api_docs** or **avoid_classes_with_only_static_members**.

Spider will add `//ignore_for_file` lint suppression to all the generated dart files. You can use `ignored_rules` **global** config to specify list of rules that should be ignored for the generated code.

**spider.yaml**

```yaml
ignored_rules:
  - public_member_api_docs
  - avoid_classes_with_only_static_members
```

**Generated Code:**

```dart
// ignore_for_file: public_member_api_docs, avoid_classes_with_only_static_members

class Images {
  Images._();

  static const String image1 = 'assets/images/image1.png';
  static const String image2 = 'assets/images/image2.png';
}

```
<br/>