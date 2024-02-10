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
### Text
- analyzed before is persisted, to support complex text queries
- process of remove punctuation, tokenization, stemmin, synonism
- elastic uses the `standard analyser` for this
- use `_analyze` API to test this process

`token_count`
- specialized type of text
- capture the number of tokens in this field
- inside the `text`attribute will be a nested attribute `word_count` to support this value:

```json
PUT tech_books
{
  "mappings": {
    "properties": {
      "title": {
        "type": "token_count", 
        "analyzer": "standard" 
      }
    }
  }
}
```
Now this `text` field can be queried through the number of tokens in it:
```json
// Range query
GET tech_books/_search
{
  "query": {
   "range": {
     "title": {
       "gt": 3,
       "lte": 5
     }
   }
  }
}

// Match query
GET tech_books/_search
{
  "query": {
    "term": {
     "title.word_count": {
        "value": 4
      }
    }
  }
}
```
### Keyword
#### Keyword
- text values that do not need to be analyzed 
- can be used for: aggregations, range queries, filter, sorting
- if numerical values are not used on range queries (bank account) created them as keyword


#### constant_keyword
- same value, does not change
- a default value can be set
```json
PUT census 
{
  "mappings": {
    "properties": {
      "country":{
        "type": "constant_keyword",
        "value":"United Kingdom"
      }
    }
  }
}
```

#### Wildcard
- searching data using wildcards & regular expressions

### Date
- structured data, as a result support filtering, sorting, aggregations
- Uses strings with ISO 8601 standard by default
- The date definition format can be customized
```json
PUT flights
{
  "mappings": {
    "properties": {
      "departure_date_time":{
        "type": "date",
        "format": "dd-MM-yyyy||dd-MM-yy"
      }
    }
  }
}
```
- the dates values can also be stored as numbers, to do so these will be converted internally as milliseconds
```json
{
  "properties": {
    "string_date":{ "type": "date", "format": "dd-MM-yyyy" },
    "millis_date":{ "type": "date", "format": "epoch_millis" },
    "seconds_date":{ "type": "date", "format": "epoch_second"}
  }
}
```

#### Range
- lower & upper bounds for a field
- Some subtypes are:
  - date_range
  - integer_range
  - float_range
  - ip_range

```json
PUT trainings
{
  "mappings": {
    "properties": {
      "training_dates":{
        "type": "date_range"
      }
    }
  }
}

PUT trainings/_doc/1 
{
  "training_dates":{ 
    "gte":"2021-08-07",
    "lte":"2021-08-10"
  }
}

GET trainings/_search
{
  "query": {
    "range": {
      "training_dates": {
        "gt": "2021-08-10",
        "lt": "2021-08-12"
      }
    }
  }
}
```