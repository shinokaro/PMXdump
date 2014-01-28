class IO
  def read_pmx_text(unicode_type) # true: UTF8; false: UTF16
    p read(self.read_uint).encode(Encoding::UTF_8_MAC, unicode_type ? Encoding::UTF_8 : Encoding::UTF_16LE)
  end
  def read_pmx_index(size)
    case size
    when 1
      read_uint8
    when 2
      read_int16
    when 4
      read_int32
    else
      raise
    end
  end
  def read_int(size=4)
    case size
    when 1
      read_int8
    when 2
      read_int16
    when 4
      read_int32
    else
      raise
    end
  end
  def read_bit(bits)
    read(bits / 8 + 1).unpack("b#{bits}").at(0).each_byte.map{ |s| s.to_i.zero? ? false : true }
  end
  def read_bool
    read(1).unpack("c").at(0).zero? ? false : true ;
  end
  def read_int8
    read(1).unpack("c").at(0)
  end
  def read_int16
    r = read(2).unpack("C2").reverse.inject(0){ |sum, a| sum * 256 + a }
    r % 32768 - r / 32768 * 32768 
  end
  def read_int32
    read(4).unpack("l").at(0)
  end
  def read_uint(size=4)
    case size
    when 1
      read_uint8
    when 2
      read_uint16
    when 4
      read_uint32
    else
      raise
    end
  end
  def read_uint8
    read(1).unpack("C").at(0)
  end
  def read_uint16
    read(2).unpack("v").at(0)
  end
  def read_uint32
    read(4).unpack("V").at(0)
  end
  def read_float
    read(4).unpack("f").at(0)
  end
  def read_float2
    read(8).unpack("f2")
  end
  def read_float3
    read(12).unpack("f3")
  end
  def read_float4
    read(16).unpack("f4")
  end
end