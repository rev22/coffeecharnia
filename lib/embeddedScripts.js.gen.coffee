scripts = [
  [ 'coffee-script.js', 'CoffeeCharniaChromium/coffee-script.js' ]
  [ 'https://github.com/ajaxorg/ace-builds/raw/master/src-min-noconflict/ace.js', 'lib/ace.js' ]
]

fs = require 'fs'

write = (x)-> process.stdout.write x

write """
  window.embeddedScripts = window.embeddedScripts || { };

  """

quot = (x)-> '"' + x.replace(/[\\\"]/g, (a)-> "\\#{a}").replace(/\n/g, "\\n") + '"'

for script in scripts
  [ scriptSrc, scriptFile ] = script
  scriptFile ?= scriptSrc
  code = fs.readFileSync(scriptFile).toString()
  write """
    window.embeddedScripts[#{quot scriptSrc}] = #{quot code};    

    """