# Mappings
Elasticsearch derive data implicitly based on the documents to index, as a result creating an schema.
It is better practice to define an schema before indexing data.

## Dynamic Mapping
Elasticsearch understands the data types of the fields while indexing the documents and, accordingly, stores the fields into appropriate data structures.

When creating an document as first time without index the `string`values will have two types:
- keyword: exact value searching. Value is untouched and **do not** go through some analyzis steps
- text: full-text related queries

## Explicit Mapping
Define an schema for the documents to index. To do so, there are two strategies:
- indexing API: request consisting the mapping definition when creating an index
```json
PUT index
{
  mappings:{
    properties:{
      title:{
        type: "text"
      },
      autor:{
        properties:{
          age:{type:"integer"}
          name:{type:"text"}
        }
      }
    }
  }
}
```

- mapping API: update the schema definition. Uses the `_mapping` endpoint
```json
PUT index/_mapping
{
  properties:{
    release_date:{
      type: "date",
      format: "dd-mm-yyyy"
    }
  }
}
```

When needing to update the type of the attributes of the index. Elasticsearch doesn’t allow us to change or modify the data types of existing fields. It requires more complex work.

### Modifying existing fields
Modifications of the existing fields on the live index is prohibited, it cannot be changed to a different data type.
To solve this issue it will need `re-indexing`

### Type coercion
At times, the JSON documents might have incorrect values, differing from the ones that are present in the schema definition. For example, an integer-defined field may have been indexed with a string value. Elasticsearch tries to convert such inconsistent types, thus avoiding indexing issues
The coercion only works if the parsed value of the field matches the expected data type.


## Data types
Categorized into the next buckets:
- simple: string, number, dates, booleans
- complex: composition of objects
- specialized: geolocation, IP address, date range

Elasticsearch is pretty cool when it comes to representing a field with multiple data types`

## Core Data Types
TODO

