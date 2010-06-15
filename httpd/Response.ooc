import structs/HashMap
import io/Reader

import httpd/Request

HttpResponse: class {
  request: HttpRequest
  status: Int
  headers := HashMap<String, String> new()
  body: String
  reader: Reader
  
  init: func (=request) {}
  init: func~withCode (=request, =status) {}
}
