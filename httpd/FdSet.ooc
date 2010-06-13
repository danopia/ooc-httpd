include stdio
include sys/types
include sys/socket
include sys/ioctl
include sys/poll
include unistd | (__USE_BSD)
include sys/select
include arpa/inet
include netdb | (__USE_POSIX)

FdMask: cover from __fd_mask extends Long

__FdSet: cover from fd_set {
    __fds_bits: extern FdMask[8] // __FD_SETSIZE / 8
}

_FdSet: cover from __FdSet* {
    new: static func -> This {
        it := gc_malloc(__FdSet size) as This
        it clear()
        it
    }
    
    
    clear: func {
      "2 %p" format(this)  println()
      "3 %p" format(__data) println()
      
      for (i in 0..7) {
        "%i: %p %x" format(i, __data[i]&, __data[i]) println()
        __data[i] = 0
      }
    }
    
    add: func (bitNum: Int) {
        mask := _getMask(bitNum)
        __data[mask min] |= mask max
    }
    
    remove: func (bitNum: Int) {
        mask := _getMask(bitNum)
        __data[mask min] &= !(mask max)
    }
    
    contains?: func (bitNum: Int) -> Bool {
        mask := _getMask(bitNum)
        (__data[mask min] & mask max) == mask max
    }
    
    _getMask: func (bitNum: Int) -> Range {
        byteNum := bitNum / (8*8) as Int
        offsetDist := bitNum - (byteNum * (8*8))
        mask := 1 << offsetDist
        
        return byteNum..mask
    }
    
    __data: FdMask* { get { this } }
}
