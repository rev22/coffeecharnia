scripts = [
  [ 'coffee-script.js', 'CoffeeCharniaChromium/coffee-script.js' ]
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
