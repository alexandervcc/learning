# Base Concepts

## Index a document

- Use `POST` method for the creation of a document into an index
- Use `_doc` endpoint inside the index
- If the index has no schema set prior documents additions, one will be created by default by Elastid. It is done by looking at the JSON attributes and types it holds.
  - Still this is not a good practice, a schema **must** be created before documents are indexed.

## Basic query operations

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

## Full text search

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

## Load many documents at once

- Need to use `_bulk` API
- By default will replace old data with the new one


## Searching across multiple fields
