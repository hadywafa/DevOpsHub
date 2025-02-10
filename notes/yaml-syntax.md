# YAML Syntax

+ YAML (YAML Ain't Markup Language or, recursively, "YAML Ain't a Markup Language") is a human-readable data serialization format. It's often used for configuration files and data exchange between languages with different data structures. YAML files use indentation and simple syntax to represent data hierarchies. Below are some key aspects of YAML syntax:

## 1. Indentation

+ YAML uses indentation (spaces or tabs) to indicate the structure of data.
+ The number of spaces or tabs must be consistent within the same hierarchy level.
+ Indentation is significant for defining the nesting of elements.

## 2. Key-Value Pairs

+ Key-value pairs are expressed as `key : value`.
+ Use a colon (:) followed by a space to separate keys and values.

```yaml
key : value
```

## 3. Lists

+ Lists are represented using a hyphen (`-`) followed by a space.
+ Lists can include scalar values or nested structures.

 ```yaml
fruits:
    - apple
    - banana
    - orange
 ```

## 4. Dictionaries (Mappings)

+ Dictionaries or mappings use a colon (`:`) to associate keys with values.
+ Dictionaries can include key-value pairs or nested structures.

 ```yaml
person:
  name: John Doe
  age: 30
 ```

## 5. Scalars

+ Scalars represent atomic values (strings, numbers, etc.).
+ Scalars don't require any special syntax for simple values.

```yaml
message: Hello, YAML!
count: 42
```

## 6. Comments

+ Comments in YAML start with the # character and continue to the end of the line.

```yaml
# This is a comment
key: value  # This is also a comment
```

## 7. Quoted Strings

+ Strings that require special characters or spaces can be enclosed in single or double quotes.

 ```yaml
message: 'Hello, World!'
 ```

## 8. Multiline Strings

+ Multiline strings can be represented using the | or > characters.

 ```yaml
description: |
  This is a multiline
  YAML string.
 ```

## 9. Anchors and Aliases

+ Anchors (`&`) and aliases (`*`) allow you to reuse content within the same YAML file.

 ```yaml
# Database configuration anchor
database_config: &db_config
  host: localhost
  port: 5432
  username: myuser
  password: secret
  database: mydatabase

# Development environment
development:
  <<: *db_config
  pool_size: 10
  debug: true

# Production environment
production:
  <<: *db_config
  pool_size: 50
  debug: false
 ```

+ `&db_config` is an anchor for the common database configuration.
+ `<<: *db_config` is a merge key that includes all the key-value pairs from the anchored `database_config` into the current node.

## Examples

```yaml
person:
  name: John Doe
  age: 30
  hobbies:
    - reading
    - hiking
  address:
    city: "Alex"
    zip: "12345"
```
