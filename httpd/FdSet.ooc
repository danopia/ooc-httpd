include stdio
include sys/types
include sys/socket
include sys/ioctl
include sys/poll
include unistd | (__USE_BSD)
include sys/select
include arpa/inet
include netdb | (__USE_POSIX)


_TimeVal: cover from struct timeval {
  tv_sec: extern Long
  tv_usec: extern Long
}

TimeVal: cover from _TimeVal* {
  new: static func -> This {
    gc_malloc(_TimeVal size) as This
  }

  new: static func~both (sec, usec: Long) -> This {
    it := new()
    it@ tv_sec = sec
    it@ tv_usec = usec
    it
  }

  new: static func~together (seconds: Double) -> This {
    useconds := seconds - (seconds as Long)
    useconds *= 1000000
    new(seconds as Long, useconds as Long)
  }
}


FdMask: cover from __fd_mask extends Long
FdBitLength: extern(__FD_SETSIZE) Int

_FdSet: cover from fd_set {
    __fds_bits: extern FdMask[FdBitLength / (FdMask size * 8)]
}

FdSet: cover from _FdSet* {
  new: static func -> This {
    gc_malloc(_FdSet size) as This
  }

  // Not needed unless reusing FdSets because of the GC
  clear: func {
    for (i in 0..(FdBitLength / (FdMask size * 8)))
      _data[i] = 0
  }

  add: func (bitNum: Int) {
    mask := _getMask(bitNum)
    _data[mask min] |= mask max
  }

  remove: func (bitNum: Int) {
    mask := _getMask(bitNum)
    _data[mask min] &= !(mask max)
  }

  contains?: func (bitNum: Int) -> Bool {
    mask := _getMask(bitNum)
    (_data[mask min] & mask max) == mask max
  }

  _getMask: func (bitNum: Int) -> Range {
    byteNum := bitNum / (8*8) as Int
    offsetDist := bitNum - (byteNum * (8*8))
    mask := 1 << offsetDist
    
    return byteNum..mask
  }

  _data: FdMask* { get { this } }
}

setsockopt: extern func(s: Int, level: Int, optname: Int, optval: Pointer, optlen: UInt) -> Int
getsockopt: extern func(s: Int, level: Int, optname: Int, optval: Pointer, optlen: UInt) -> Int

select: extern func(n: Int, readfds, writefds, exceptfds: FdSet, timeout: TimeVal) -> Int
