# Work with Documents
Elasticsearch classifies the APIs into two categories: single document APIs and multi-document APIs.

The single document APIs, as the name suggests, are applied to perform operations like indexing, fetching, modifying, and deleting documents one by one, using the appropriate endpoints.

The multi-document APIs, on the other hand, are geared towards working with documents in batches.

## Indexing documents
- If the doc has an identifier provided by the client, use `PUT` method. Otherwise, `POST` for elastic to assign a random uuid
- should use the HTTP POST action to index documents that don't have a business identity
```json
// request
PUT <index_name>/_doc/<identifier>
{
    ... body
}

```

- On the result there are some values:
 - `_version` indicates the current version of this document; the value 1 here means the first version for the document. The number gets incremented if we modify the document and reindex it.
- Elasticsearch provides another endpoint: _create. This endpoint solves the overwrite situation. We can use the _create endpoint in place of _doc when indexing a document to avoid overriding the existing one.
  - will not let you reindex the document with the same ID again, while the _doc wouldn't mind.
```json
PUT movies/_create/100
{
  "title":"Mission Impossible"
}
```

---
#### Disable auto-index creation
Elasticsearch, by default, auto-creates a required index if the index doesn't already exist. If we want to restrict this feature, we need to set a flag called action.auto_create_index to false, can be done through two ways:
- Set the flag to false in the `elasticsearch.yml` config file or
- Explicitly set the flag by invoking `_cluster/settings`
```json
PUT _cluster/settings
{
  "persistent": {
    "action.auto_create_index": "false" 
  }
}
```
---

### Mechanisms of Indexing
When a document is indexed, the document is first pushed into the shard's in-memory buffer. The document is held in this in-memory buffer until a refresh occurs

Lucene’s scheduler issues a refresh every 1 second to collect all the documents available in the in-memory buffer, and creates a new segment with these documents. The segment consists of the document data and inverted indexes. **The data is first written to the filesystem cache and then committed to the physical disk**

As I/O operations are expensive, Lucene avoids frequent I/O operations when writing data to the disk. Hence, it waits for the refresh interval (default is one second), after which the documents are bundled up to be pushed into segments. Once the documents are moved to the segments, they are then made available for searching.

During the 1-second refresh interval, a new segment is created to hold however many documents are collected in the in-memory buffer.

The heap memory of the shard (Lucene instance) dictates the number of documents it can hold in an in-memory buffer before flushing it out to the file store.

For all practical purposes, Lucene treats the segments as immutable resources. That is, once a segment is created with available documents from the buffer, any new document will not make its way into this existing segment. Instead, it’s moved into a brand new segment. Similarly, the deletes are not performed physically on the documents inside the segments, but they are marked for removal later.

### Customize the refresh
Documents that get indexed live in memory until the refresh cycle kicks in. This means, we will be living with uncommitted (non-durable) documents until the next refresh cycle. A server failure could trigger a data loss.

```json
// configure the refresher cycle
PUT movies/_settings
{
  "index":{
    "refresh_interval":"60s"
  }
}
```
We can also control the refresh operation from the client side for CRUD operations on documents by setting the refresh query parameter. The document APIs (index, delete, update, and _bulk) expect refresh as a query parameter.

## Retrieving documents
### Single doc API
- Needs to indicate the doc id to fetch
- This query returns 200 - OK if the document exists. If the document is unavailable in the store, a 404 Not Found error is returned
```json
GET <index_name>/_doc/<id>
```

### Multiple doc API
`_mget` API will work for retrieving multiple documents:
```json
// single index
GET movies/_mget
{
  "ids" : ["1", "12", "19", "34"]
}

// multiple index
GET _mget #A
{
  "docs":[
   {
     "_index":"classic_movies", 
     "_id":11
   },
   {
     "_index":"international_movies", 
     "_id":22
   }
  ]
}
```
Other option is to use the `_search` API with multiple index
```json
GET classic_movies,international_movies/_search 
{ 
  # body
}
```


### Ids query
```json
GET classic_movies/_search
{
  "query": {
    "ids": {
      "values": [1,2,3,4]
    }
  }
}
```

## Manipulate results
- Omit/include metada
```json
GET <index_name>/_source/<id>
```
- Include/exclude body of doc
```json
GET movies/_doc/1?_source=false
```
- Include/exclude doc attributes
```json
GET movies/_source/3?_source_includes=title,rating,genre

GET movies/_source/3?_source_excludes=actors,synopsis
```

## Update documents
There is two endpoints for this: `_update` & `_update_by_query` 

### Update mechanism
Process is composed of three parts:
1. Fetch the document
2. Modify the document
3. **Re-index** the updated document

When an update takes place elastic increments the value of `version` for the document. When the new version is ready, the old one gets marked for deletion.

### _update
`POST <index_name>/_doc/<id>/_update`
```json
POST movies/_update/1
{
  "doc": {
    "title":"The Godfather (Original)"
  }
}
```
#### Script update
- Scripted updates allow us to update the document based on some conditions
- Provide the updates as a value to this source key with the help of a context variable ctx - which is used to fetch the original document’s attributes by calling ctx._source.<field>.
```json
// add a new element to a list
POST movies/_update/1
{
  "script": {
   "source": "ctx._source.actors.add('Diane Keaton')" #A
  }
}

// remove a field from an array
{
 "script":{
   "source":
     "ctx._source.actors.remove(ctx._source.actors.indexOf('Diane Keaton'))"
  }
}

// add a field
POST movies/_update/1
{
  "script": {
    "source": "ctx._source.imdb_user_rating = 9.2"
  }
}

// remove a field
POST movies/_update/1
{
  "script": {
    "source": "ctx._source.remove('metacritic_rating')"
  }
}

// conditionals
POST movies/_update/1
{
  "script": {
    "source": """
    if(ctx._source.boxoffice_gross_in_millions > 125) 
      {ctx._source.blockbuster = true} 
     else 
      {ctx._source.blockbuster = false}
    """
  }
}
```

### Upsert
- Checks if a document exists, if so it will be updated, otherwise it will be created with the `update` block content.
- if the doc **does not** exists, the script update will not be executed
```json
POST movies/_update/5
{
  "script": {
    "source": "ctx._source.gross_earnings = '357.1m'"
  },
  "upsert": {
    "title":"Top Gun",
    "gross_earnings":"357.5m"
  }
}
```

### _update_by_query
- mechanism to update tons of documents based on a criteri
```json
POST movies/_update_by_query #A
{
  "query": {
    "match": {
      "actors": "Al Pacino"
    }
  },
  "script": {
    "source": """ctx._source.actors.add('Oscar Winner Al Pacino');""",
    "lang": "painless"
  }
}
```

## Delete Documents
`DELETE <index_name>/_doc/<id>`
- Delete a single document by `_id`

- Delete many documents through a matching criteria
```json
POST movies/_delete_by_query
{
  "query":{
    "match":{
      "director":"James Cameron"
    }
  }
}
```

## Bulk
- Used to index large datasets simultaneosly, and not only limited to indexing
- Is not limited to a single index, not a single operation


```json
// create a doc into an specific index
POST movies/_bulk
{"index":{"_id":"100"}}
{"title": "Mission Impossible"}

// bulk through index for each doc
POST _bulk
{"update":{"_index":"movies","_id":"200"}}
{"doc": {"director":"Brett Ratner"}}
```

## Reindex documents
- need to migrate an older index to a newer one due to changes in our mapping schema or settings
- use the `_reindex` API for this
```json
POST _reindex
{
  "source": {"index": "<source_index>"},
  "dest": {"index": "<destination_index>"}
}
```












