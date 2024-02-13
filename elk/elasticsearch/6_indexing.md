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

- Sometimes the indices may be overloaded with data.
- To avoid risk of losing data or mitigate slower search query responses, we can re-distribute the data on to additional shards
- Adding additional shards to the index will optimize the memory and distribute documents evenly.
- Splitting is nothing more than creating a new index with more shards and copying the data from the old index into the new index.
- Elasticsearch provides a `_split` API for splitting an index
- The split API can’t change any settings on the target index. It will copy/redistribute the documents.
- `Before invoking the split operation the index must be disabled for indexing purposes, so that the index is changed to read-only`

```json
// Convert index into read-only
PUT all_cars/_settings
{
  "settings":{
    "index.blocks.write":"true"
  }
}

// Split the index
POST all_cars/_split/all_cars_new
{
  "settings": {
    "index.number_of_shards": 12
  }
}
```

Conditions for split operation:

- The target index must not exist before this operation
- The number of shards in the target index must be a multiple of the number of shards in the source index
- The target index’s primary shards can never be less than the source primary shards.
- The target index’s node must have adequate space.

### Shrink an index

- reduces the number of shards
- When: `To increase the read speed (search throughput), we may have taken a strategy to add additional data nodes. And once the demand subsides, no reason to keep all those nodes active`
- the first step is to make sure our all_cars index is read-only, so we’ll set the index.blocks.write property to true

```json
// block write operations
PUT all_cars/_settings
{
  "settings": {
    "index.blocks.write": true,
    "index.routing.allocation.require._name": "node1"
  }
}

// shrink index
PUT all_cars/_shrink/all_cars_new
{
  "settings":{
    // reset old index changes
    "index.blocks.write":null,
    "index.routing.allocation.require._name":null,
    // new index config
    "index.number_of_shards":1,
    "index.number_of_replicas":5
  }
}
```

To avoid having in the new index, the changes done in the old index previous the shrinking. It is required to reset them.

Conditions to shrink:

- The source index must be switched off (made read-only) for indexing.
- The target index mustn’t be created or exists before the shrinking activity
- All index shards must reside on the same node
  - **There is a property called index.routing.allocation.require.<node_name> on the index that we must set with the node name to achieve this.**
- The target index’s shard number can only be a factor of the source index’s shard number
- The target index’s node satisfies the memory requirements.

### Rollover an index

The current index is rolled over to a new blank index pretty much automatically.

Unlike a splitting operation, in a rollover, the documents are not copied to the new index. The old index becomes read-only, and any new documents will be indexed into this rolled over index going forward.

The rollover operation is heavily used when dealing with time-series data.

**Steps:**

1. Create an alias pointing to the index we want to roll over

- the alias must point to a writable index - hence the setting is_write_index to true in the listing

2. Issue the rollove operation

```json
// step 1
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "cars_2021-000001",
        "alias": "latest_cars_a",
        "is_write_index": true
      }
    }
  ]
}

// step 2
POST latest_cars_a/_rollover
```

On the background the rollover operation does:

- Creates a new index with the same configuration as the old one
- Remaps the alias to point to the new index that was freshly generated
- Deletes the alias on the current index and repoints it to the newly created rollover index.

## Index Life-Cycle Management ILM

The ILM is all about managing the indices based on a life-cycle policy. The policy is a definition that declares some rules that are executed by the engine when the conditions of the rules are met.
For example:

- The index reaches a certain size (say 40 GB, for example)
- The number of documents in the index crossed, say, 10,000
- The day is rolled over

### Index lifecycle

An index has five life-cycle phases:

- **hot:** full operational mode for write/read
- **warm:** read-only, not index operation allowed
- **cold:** read-only, slow as it expects infrequent querying
- **frozen:** read-only, less frecuent than cold
- **delete:**

### Manage ILM manually

API for working with the index life-cycle policy with an endpoint is `_ilm`
**Steps:**

1. Defined policy

- Set the phases and actions on these

2. Associate the policy with an index

```json
// step 1
PUT _ilm/policy/hot_delete_policy #A
{
  "policy": {
    "phases": {
      "hot": {
        // live one day before carryng the action
        "min_age": "1d",
        "actions": {
        "set_priority": {
            "priority": 250
          }
        }
      },
      "delete": {
        "actions": {
          "delete" : { }
        }
      }
    }
  }
}

// step 2
PUT hot_delete_policy_index
{
  "settings": {
    "index.lifecycle.name":"hot_delete_policy"
  }
}
```

### ILM with rollover

Set conditions on a timeseries index to magically roll when those conditions are met

```json
PUT _ilm/policy/hot_simple_policy
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "1d",
            "max_docs": 10000,
            "max_size": "10gb"
          }
        }
      }
    }
  }
}
```

Attach ILM policy into a template

```json
PUT _index_template/mysql_logs_template
{
  "index_patterns": ["mysql-*"],
  "template":{
    "settings":{
      // set the policy
      "index.lifecycle.name":"hot_simple_policy",
      // needed as the policy uses rollover
      "index.lifecycle.rollover_alias":"mysql-logs-alias"
    }
  }
}
```

Create the index using the template & automatically rollover

```json
PUT mysql-index-000001
{
  "aliases": {
    "mysql-logs-alias": {
      //
      "is_write_index":true
    }
  }
}
```

- By default policies are scanned every `10 minutes`. To update its values, so that elastic looks the new policies created and uses them, update the scan value

```json
PUT _cluster/settings
{
  "persistent": {
     "indices.lifecycle.poll_interval":"10ms"
  }
}
```
