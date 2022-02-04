Familiar with `Enum.values` list which contains all the enum values? Spider also provides support for
generating `values`
list for all the asset references in given dart class. Use `use_references_list` global config to enable `values` list
generation.

```yaml
# global config
use_references_list: true
```

> This is disabled by default as it can be overwhelming to have this code-gen if you don't need it.

