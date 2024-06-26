# Base Concepts

## Index a document

- Use `POST` method for the creation of a document into an index
- Use `_doc` endpoint inside the index
- If the index has no schema set prior documents additions, one will be created by default by Elastid. It is done by looking at the JSON attributes and types it holds.
  - Still this is not a good practice, a schema **must** be created before documents are indexed.

### Basic query operations

- Count all documents inside an index, has a path:
  - `GET <index-name>/_count`
- Get a document by its identifier
  - `GET <index-name>/_doc/<id>`
  - This will retrieve two main part: `metadata` & document inside a `_source` attribute
- Get a document by its identifier, only the source:
  - `GET <index-name>/_source/<id>`
- Get a list of document by ids
  - Needs to use the `_search` API instead of the `_doc` one
  ```json
      GET <index-name>/_search
      {
          "query":{
              "ids":{
                  "values": [1,2,3]
              },
          }
      }
  ```
- Get all documents
  - Need to use `_search` API
  - `GET <index-name>/_seach`

### Full text search

- Query to search an string value inside a text attribute. **It uses the inverted index**

  - Changing the letter into a mix of Upper/Lower case will still succed
    ```json
        GET books/_search
        {
            "query": {
                "match": {
                    "author": "Joshua"
                }
            }
        }
    ```
  - Sending just a substring will fail, it would require a `prefix` operator to use it as a `regex`. But the value must be lowercase.
    ```json
        GET books/_search
        {
            "query": {
                "prefix": {
                    "author": "josh"
                }
            }
        }
    ```

- Sending many word for the match query, will result as an `OR` operation through the terms.
  - Send a match query using `AND` operator. So will check that the attribute contains all the values inside the query
    ```json
        GET books/_search
        {
            "query": {
                "match": {
                    "author": {
                        "query": "Joshua Schildt",
                        "operator": "AND"
                    }
                }
            }
        }
    ```

### Load many documents at once

- Need to use `_bulk` API
- By default will replace old data with the new one

### Searching across multiple fields

- Requires to use `multi_match` query
  ```json
      GET books/_search
      {
        "query": {
          "multi_match": {
            "query": "Java",
            "fields": ["title","synopsis"]
          }
        }
      }
  ```
- It can select which field would have a higher score through the `boosting factor`. This is addded next to the field with `^<factor>`
  ```json
      GET books/_search
      {
        "query": {
          "multi_match": {
            "query": "Java",
            "fields": ["title^3","synopsis"]
          }
        }
      }
  ```

### Search phrases

- To search a long list of words in an specific order use `match_phrase`
  ```json
    GET books/_search
    {
      "query": {
        "match_phrase": {
          "synopsis": "must-have book for every Java programmer"
        }
      }
  ```

### Highlighting Results

- Highlight parts of the queried attribute where the query hit. But it requires an extra object `highlight` at the same level as `query`
  ```json
      GET books/_search
      {
        "query": {
          "match_phrase": {
            "synopsis": "must-have book for every Java programmer"
          }
        },
        "highlight": {
          "fields": {
            "synopsis": {}
          }
        }
      }
  ```

### Phrases with missing words
## Term-level Queries
Elasticsearch treats the structured and unstructured data in different ways: the unstructured (full-text) data gets analyzed, while the structured fields are stored as is.
The term-level queries produce a binary output: fetch results if the query matches with the criteria, else no results are sent.

### Term query
Use `term` attribute for this query:
  ```json
      GET books/_search
      {
        "_source": ["title","edition"], 
        "query": {
          "term": { 
            "edition": { 
              "value": 3
            }
          }
        }
      }
  ```

### Range query
Match a range an attribute, uses `match` attribute
```json
  GET books/_search
  {
    "query": {
      "range": { 
        "amazon_rating": {
          "gte": 4.5,
          "lte": 5 
        }
      }
    }
  }
```

## Compound queries
Mechanism to create sophisticated queries. There are a handful of compound queries:
- Boolean (bool) query,
- Constant score (constant_score) query
- Function (function_score) score,
- Boosting (boosting) query
- Disjunction max (dis_max) query

## Bool query
- Create a query combining other queries based on bool conditions
- Applies 4 clauses: `must`, `must_not`, `should`, `filter`. And expects one or more of these.
```json
  GET books/_search
  {
    "query": {
      "bool": {
        "must": [{ }],
        "must_not": [{ }],
        "should": [{ }],
        "filter": [{ }]
      }
    }
  }
```







