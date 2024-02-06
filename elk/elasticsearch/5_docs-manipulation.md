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
















