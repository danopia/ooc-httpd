import structs/HashMap

HttpRequest: class {
  method, path, version: String
  headers := HashMap<String, String> new()
  body: String = null
}
