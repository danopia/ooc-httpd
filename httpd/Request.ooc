import structs/[ArrayList, HashMap]

import httpd/split

HttpRequest: class {
  method, path, queryString, version: String
  headers := HashMap<String, String> new()
  body: String = null
  
  setPath: func (path: String) {
    parts := path splits('?', 1)
    this path = parts[0]
    if (parts size() > 1)
      queryString = parts[1]
  }
  
  hasData?: Bool { get { body != null } }
  
  parseForm: func -> HashMap<String, String> {
    fields := HashMap<String, String> new()
    
    typeParts := headers["Content-Type"] splits("; ")
    match (typeParts[0]) {
      
      case "multipart/form-data" => {
        boundary := "\r\n--" + typeParts[1] splits("=", 1) last()
        body := this body substring(0, this body indexOf(boundary + "--\r\n"))
        boundary += "\r\n"
        
        for (section in body split(boundary)) {
          parts := section splits("\r\n\r\n", 1)
          if (parts size() == 1) parts add("") // in case it's empty
          
          header := parts[0]
          name := header substring(header indexOf('"') + 1, header lastIndexOf('"'))
          
          fields[name] = parts[1]
        }
      }
    
    }
    
    fields
  }
}
