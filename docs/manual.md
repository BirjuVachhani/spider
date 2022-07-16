Below table contains all the configuration options that [**Spider**](https://pub.dev/packages/spider) offers.

> **Note:** This is a table! If it doesn't look like one then head over to the [*repository*](https://github.com/birjuvachhani/spider).

| KEY             	| TYPE         	| DEFAULT VALUE  	| SCOPE  	| DESCRIPTION                                                                                           	|
|-----------------	|--------------	|----------------	|--------	|-------------------------------------------------------------------------------------------------------	|
| `path/paths`*   	| String       	| *None*           	| GROUP  	| Where to locate assets?                                                                               	|
| `class_name`*   	| String       	| *None*           	| GROUP  	| What will be the name of generated dart class?                                                        	|
| `package`       	| String       	| `resources`      	| GLOBAL 	| Where to generate dart code in the lib folder?                                                        	|
| `file_name`     	| String       	| *{class_name}*   	| GROUP  	| What will be the name of the generated dart file?                                                     	|
| `prefix`        	| String       	| *None*           	| GROUP  	| What will be the prefix of generated dart references?                                                 	|
| `use_underscores`        	| bool       	| `false`           	| GROUP  	| User underscore instead of camelcase for dart references?                                                 	|
| `types`         	| List<String> 	| *All*            	| GROUP  	| Which types of assets should be included?                                                             	|
| `generate_test` 	| bool         	| `false`          	| GLOBAL 	| Generate test cases to make sure that asssets are still present inthe project?                        	|
| `no_comments`   	| bool         	| `false`          	| GLOBAL 	| Removes all the `generated` comments from top of all generated dart code.Use this to avoid vcs noise. 	|
| `export`        	| bool         	| `true`           	| GLOBAL 	| Generates a dart file exporting all the generated classes. Can be used toavoid multiple exports.      	|
| `export_file`   	| String       	| `resources.dart` 	| GLOBAL 	| What will be the name of generated export file?                                                       	|
| `use_part_of`   	| bool         	| `false`          	| GLOBAL 	| Allows to opt in for using `part of` instead of exporting generated dartfiles.                        	|
| `use_references_list`   	| bool         	| `false`          	| GLOBAL 	| Generates value list just like enums which contains all the asset references of that class.                        	|
| `ignored_rules`   	| List<String>         	| *None*          	| GLOBAL 	| Generates `//ignore_for_file` lint suppression for dart files.                        	|

<br/>