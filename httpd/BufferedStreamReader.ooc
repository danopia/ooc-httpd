import text/Buffer
import io/Reader
import net/[StreamSocket, Exceptions]

BufferedStreamReader: class extends Reader {
  source: StreamSocket
  buffer: String
  closed := false

  init: func ~BufferedSocketReader (=source) {
    buffer = String new(0)
    marker = 0
  }

  readRaw: func~all -> String {
    return readRaw(source available())
  }

  readRaw: func~withSize(count: Int) -> String {
    if (count == 0 && closed) return ""
    
    string := String new(count)
    if (source receive(string, count) == 0) {
      closed = true
      return ""
    }
    return string
  }

  readMore: func~all -> Int {
    return readMore(source available())
  }

  readMore: func~withSize(max: Int) -> Int {
    if (max == 0 && closed) return 0
    string := readRaw(max)
    buffer += string
    return string length()
  }

  readMore!: func -> Int {
    if (closed)
      return 0
    else if (this hasNext?)
      return readMore(source available())
    else
      return readMore(1) // can this be, say, 512 to reduce the number of reads while blocking for data?
  }
  
  read: func(chars: String, offset: Int, count: Int) -> SizeT {
    // does this really matter?
    //skip(offset - marker)
    
    while (!closed && buffer length() < count) {
      readMore(count - (buffer length()))
    }
    
    chars = buffer substring(0, count)
    buffer = buffer substring(count)
    return chars length()
  }
  
  read: func ~char -> Char {
    if ((buffer length() > 0) || (readMore() > 0)) {
      char_ := buffer first()
      buffer = buffer substring(1)
      return char_
    } else {
      return readRaw(1) first()
    }
  }

  hasNext: func -> Bool { available > 0 }
  
  hasNext?: Bool { get { available > 0 } }
  rawAvail?: Bool { get { source available() > 0 } }
  veryEnd?: Bool { get { available == 0 } }
  
  hasLine?: Bool {
    get {
      if (rawAvail?) readMore()
      buffer contains('\n')
    }
  }
  
  available: Int { get { buffer length() + source available() } }

  rewind: func(offset: Int) {
    SocketError new("Sockets do not support rewind") throw()
  }

  mark: func -> Long { marker }

  reset: func(marker: Long) {
    SocketError new("Sockets do not support reset") throw()
  }
  
  
  
  readUntil: func~Char2 (end: Char) -> String {
    while (!closed && !buffer contains(end)) readMore!()
    
    if (veryEnd? || !buffer contains(end)) return ""
    
    string := buffer substring(0, buffer indexOf(end))
    buffer = buffer substring(string length() + 1)
    return string
  }
  
  readUntil: func~String2 (end: String) -> String {
    while (!closed && !buffer contains(end)) readMore!()
    
    if (veryEnd? || !buffer contains(end)) return ""
    
    string := buffer substring(0, buffer indexOf(end))
    buffer = buffer substring(string length() + end length())
    return string
  }
}
