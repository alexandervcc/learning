# Indexing

## Index operations

### Creation

- Two ways for doing this: Implicit & Explicit
- When creating `implicit` indexes, take care of default values that cannot be re-configured later like the number of shards.
- Each index is composed of three parts:
  - **mapping:** schema definition
  - **setting:** number shards, replicas, refresh rate, codec etc. There are two types: `dynamics` & `static`.
  - **aliases:** alternate name given to an index. Can point to more than 1 index

```json
// setttings
PUT cars_index_with_sample_settings
{
  "settings": {
    "number_of_replicas": 3,
    "codec": "best_compression"
  }
}


//aliases
PUT cars_index_with_sample_alias #A
{
  "aliases": {
    "alias_for_cars_index_with_sample_alias": {}
  }
}
```

### Explicit index

- Configuration can be done through `_settings` API for updates
- `static` settings should be changed through a re-index process

```json
// create an index explicitly
PUT cars_with_custom_settings #A
{
  "mappings":{
    ...
  },
  "aliases":{
    "my_new_cars_alias": {}
  },
  "settings":{
    "number_of_shards":3,
    "number_of_replicas":5,
    "codec": "best_compression",
    "max_script_fields":128,
    "refresh_interval": "60s"
  }
}

// update exiting index settings
PUT cars_with_custom_settings/_settings
{
  "settings": {
    "number_of_replicas": 2
  }
}

// fetch index settings
GET cars_with_custom_settings/_settings

// create aliases for existing index
PUT cars_for_aliases/_alias/my_cars_alias

```

- If a change of static settings is required, some steps are required:
  1. Close the current index (that is, index cannot support read/write operations).
  2. Create a new index with the new settings.
  3. Migrate the data from the old index to the new index (reindexing operation).
  4. Repoint the alias to the new index (assuming the index has an existing alias).

#### Alias

- use the `_alias` API for management of an index alias
- use `_aliases` API for multiple alias actions in a single operation

```json
POST _aliases
{
  "actions": [
    {
      "remove": {
        "index": "vintage_cars",
        "alias": "vintage_cars_alias"
      }
    },
    {
      "add": {
        "index": "vintage_cars_new",
        "alias": "vintage_cars_alias"
      }
    },
    // create an alias for multiple indeces
    {
      "add": {
        "indices": ["vintage_cars","power_cars","rare_cars","luxury_cars"],
        "alias": "high_end_cars_alais"
      }
    }
  ]
}
```

## Reading indeces

### Public index

- Norma indexes used for bussiness data application

### Hidden index

- Name has prefix `.`
- Usually reserved for system management

## Delete index

```json
// format
DELETE <index_name>


// many indeces
DELETE cars,movies,order

// alias
DELETE cars/_alias/cars_alias
```

## Close & Open indeces
### close
  - closed for business, any operation will cease
  - no more read/write operations are allowed
  - overhead of mantaining shards is reduced, resources will be purged and memory will be reclaimed
  - use `_close` API
```json
POST cars/_close
``` 

### open
- kick starts the shard back into bussiness, ready for write/read
- closed index can be opened
- 
```json
POST cars/_open
```

## Index Template
- Remove the need to write the same config when creating new indeces
- Have predefined patterns and configurations
- templates can also be based on `glob`

- Can be categorized into two types:
  - **composable index template**
    - composed of `0+` component templates
  - **component templates**
    - reusable block of configuration to be assigned into an index

- Index template can exist on its own without the need of being associated with a component
- An index creation with explicit config, will take precedence over the template
- To create an index template use the `_index_template` endpoint
- 
```json
// create index template
PUT _index_template/cars_template
{
  "index_patterns": ["*cars*"],
  "priority": 1, 
  "template": {
    "mappings": {
      "properties":{
        "created_at":{
          "type":"date"
        },
        "created_by":{
          "type":"text"
        }
      }
    }
  }
}
```

- When creating an index, if the name matches the template wildcard, the template will be used
- The `priority` allow to use settings with higher value, when the creation of an index would use `2+` templates. As a result, the lower ones get overriden.

### Component Templates
- use the `_component_template` endpoint
```json
POST _component_template/dev_settings_component_template
{
  "template":{
    "settings":{
      "number_of_shards":3,
      "number_of_replicas":3
    }
  }
}
```
- Create `index template` based on `component template`
```json
POST _index_template/composed_cars_template
{
  "index_patterns": ["*cars*"], 
  "priority": 200, 
  "composed_of": ["dev_settings_component_template", "dev_mapping_component_template"]
}
```

## Monitoring and managing indeces
### Statistics
- Every index generates statistics such as total number of documents it has, count of documents that were deleted, the shard’s memory, get and search request data, and so on
- Use `_stats` API
```json
GET cars/_stats
```

- The response consists of two blocks primarily:
  - The `_all block`, where we see the aggregated statistics of all indices combined
  - The `indices block`, where we see the statistics for the individual indices (each of the index in that cluster)

- Both these blocks consist of two buckets of statistics: 
  - `primaries` bucket contains the statistics related to just the primary shards
  - `total` bucket indicates the statistics for both primary and replica shards.

It is possible to get statistics of the `segments` of an index
```json
// general
GET cars/_stats/segments

// specific API
GET cars/_segments
```

## Advanced Operations
### Splitting an index


















