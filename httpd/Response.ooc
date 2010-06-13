import structs/HashMap
import httpd/Request

HttpResponse: class {
  request: HttpRequest
  status: Int
  headers := HashMap<String, String> new()
  body: String
  
  init: func (=request) {}
  init: func~withCode (=request, =status) {}
}
