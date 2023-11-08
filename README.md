# Kong plugin: Dynamic Routing by Header
This Kong plugin adds a Header (depending on the Authorization header of the Consumer) and enables a dynamic Routing on Header. It manages a multiple acceptance authentication on the same Route path.

## How does the Kong plugin work?
- Job is done by implementing the `rewrite` phase (in this phase, neither the Service nor the Consumer have been identified). So the plugin must be deployed globally.
- Retrieve the `Authorization` header
- Append an `X-Dynamic-Route` header depending of the `Authorization` header
  - `Authorization: Basic ***` => `X-Dynamic-Route: Basic`
  - `Authorization: Bearer ***` => `X-Dynamic-Route: Bearer`

## How configure the Kong plugin and prepare a test environment?
1) Deploy **globally** the `dynamic-routing-by-header` plugin 
2) Create a Service called `httpbin` on https://httpbin.org/anything
3) Add a `basic` Route on the `httpbin` Service with following properties:
    - Name: `httpbin_basic`
    - Routing Rules
      - Paths: `/httpbin`
      - Headers: `X-Dynamic-Route: Basic`
4) Add an `oidc` Route on the `httpbin` Service with following properties:
    - Name: `httpbin_oidc`
    - Routing Rules
      - Paths: `/httpbin`
      - Headers: `X-Dynamic-Route: Bearer`
5) Authentication: `Basic`
  - Add a `Basic Authentication` plugin to `httpbin_basic` Route
  - Create a consumer with a Basic Auth. Username/password: `client1/secret1`
6) Authentication: `OIDC`
  - Add an `OpenID Connect` plugin to `httpbin_oidc` Route
  - Declare a Client ID in your IDP Server
  
## Test the Kong plugin
Install [httpie](https://httpie.io/) tool.
1) Test the `httpbin_basic` Route
- Request:
```shell
http :8000/httpbin Authorization:'Basic Y2xpZW50MTpzZWNyZXQx'
```
- Response:
```shell
HTTP/1.1 200 OK
...
Via: kong/3.4.0.0-enterprise-edition
{
    "args": {},
    "data": "",
    "files": {},
    "form": {},
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "Authorization": "Basic Y2xpZW50MTpzZWNyZXQx",
        ...
        "X-Dynamic-Route": "Basic",
        ...
    },
    ...
}
```

2) Test the `httpbin_oidc` Route
- Prerequiste: get a JWT for the Client ID created previously.
- Request:
```shell
http :8000/httpbin Authorization:'Bearer ABC.DEF.GHI'
```
- Response:
```shell
HTTP/1.1 200 OK
...
Via: kong/3.4.0.0-enterprise-edition
{
    "args": {},
    "data": "",
    "files": {},
    "form": {},
    "headers": {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "Authorization": "Bearer ABC.DEF.GHI",
        ...
        "X-Dynamic-Route": "Bearer",
        ...
        },
    ...
¬
```
See the `X-Dynamic-Route` header added dynamically by the custom plugin: the header value depends of the `authorization` provided by the Consumer. 

By having this mechanism we are able to call different Route on the same path (i.e. `/httpbin`) with multiple acceptance authentication.