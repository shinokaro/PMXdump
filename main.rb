# coding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require_relative "ext"
require_relative "pmx_reader"
require_relative "pmx_class"

pmx = PMXInfo.new()
pmx.load_pmx('C:\Users\shinokaro\Documents\GitHub\PMXdump\Appearance Miku\Appearance Miku.pmx')
