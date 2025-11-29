# duckdb secrets

Configure the duckdb secrets for remote access.

## Usage

``` r
duckdb_secrets(
  key = Sys.getenv("AWS_ACCESS_KEY_ID", ""),
  secret = Sys.getenv("AWS_SECRET_ACCESS_KEY", ""),
  endpoint = Sys.getenv("AWS_S3_ENDPOINT", "s3.amazonaws.com"),
  region = Sys.getenv("AWS_REGION", "us-east-1"),
  bucket = NULL,
  url_style = NULL,
  use_ssl = Sys.getenv("AWS_HTTPS", "TRUE"),
  url_compatibility_mode = TRUE,
  session_token = Sys.getenv("AWS_SESSION_TOKEN", ""),
  type = "S3",
  conn = cached_connection()
)
```

## Arguments

- key:

  key

- secret:

  secret

- endpoint:

  endpoint address

- region:

  AWS region (ignored by some other S3 providers)

- bucket:

  restricts the "SCOPE" of this key to only objects in this bucket-name.
  note that the bucket name is currently insensitive to endpoint

- url_style:

  path or vhost, for S3

- use_ssl:

  Use SSL address (https instead of http), default TRUE

- url_compatibility_mode:

  optional mode for increased compatibility with some endpoints

- session_token:

  AWS session token, used in some AWS authentication with short-lived
  tokens

- type:

  Key type, e.g. S3. See duckdb docs for details. references
  <https://duckdb.org/docs/configuration/secrets_manager.html>

- conn:

  A connection to a database.
