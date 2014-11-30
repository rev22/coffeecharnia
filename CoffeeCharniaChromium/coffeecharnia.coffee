window.coffeecharniaLoader =
        config:
          coffeescriptUrl: "coffee-script.js" # document.getElementById("coffeecharniaInject").coffeescriptUrl # "coffee-script.js" # "lib/coffee-script.js"        
        pkgInfo:
          version: "CoffeeCharnia 0.2.38"
          description: "Reflective CoffeeScript Console"
          copyright: "Copyright (c) 2014 Michele Bini"
          license: "GPL3"
        coffeecharniaBase:
          alert: alert
          inlineStyle: @>
           s = @sizePercentage ? 38
           (g = @gravity)? then
             [ x, y ] = g
           else
             x = y = 1
           y = ([ (-> "top:0"),   (-> "top:#{(100-s)/2}%"),   (-> "bottom:0")  ])[y]()
           x = ([ (-> "left:0"),  (-> "left:#{(100-s)/2}%"),  (-> "right:0")   ])[x]()
           g = "#{x};#{y}"
           "position:absolute;overflow:auto;width:#{s}%;height:#{s}%;#{g};background:black;color:#ddd"
         
          accumulator: [ ]
                       
          printHtml: (s)@>
            @accumulator.push s
                       
          isConverting: false
          
          targetObject: null # "window"
           
          processSource: (s)@> @targetObject? then ("((x)->x.call(" + @targetObject + ")) ()->") + ("\n" + s).replace(/\n/g, "\n  ") else s
                       
          evalCoffeescript: (x)@>
            @eval(@libs.CoffeeScript.compile(@processSource(x), bare:true))
                       
          evalWithSourceMap: (x)@>
            # This technique does not seem to work properly on Chromium 22
            { js, sourceMapV3, file_name } = @libs.CoffeeScript.compile x, sourceMap: 1
            @lastSourceMap = ""
            @eval(js)
                       
          preQuote: (x)@> "<pre>#{ x.replace /</g, "&lt;" }</pre>"
                       
          printVal: (x)@>
            @preQuote(@libs.DynmodPrinter.limitLines(1000).print(x))
            # x.toString()
                       
          recalculateTextareaSize: @>
            { setTimeout } = @
            setTimeout (=>
              editor = @view.coffeeArea.transformed
              editor.resize()
              editor.renderer.scrollCursorIntoView()
            ), 0
          
          runButtonClick: @>
            x = @view.coffeeArea.value
            isError = null
            val = if true
              @evalCoffeescript x catch error
                isError = true
                val = error.stack ? error?.toString() ? error ? "Undefined error"
            else
              @evalWithSourceMap x
            { coffeecharniaConsole: console, introFooter, resultFooter, resultDatum } = @view
            if val?
              introFooter.setAttribute "style", "display:none"
              # resultFooter.setAttribute "style", "max-height:#{console.getBoundingClientRect().height / 2.6 | 0}px"
              resultFooter.setAttribute "style", ""
              if isError
                resultDatum.innerHTML = @preQuote val
              else
                resultDatum.innerHTML = @printVal val              
            else
              introFooter.setAttribute "style", ""
              resultFooter.setAttribute "style", "display:none"
              resultDatum.innerHTML = ""
            (@aceEditor())? then
              @recalculateTextareaSize()
            else
              { setTimeout } = @
              if true
                # Keep it Simple!
                setTimeout (=> @view.coffeeArea.scrollTop += 999999), 0
                return 
              fixUp = =>
                area = @view.coffeeArea
                area.focus()
                (pos = area.selectionEnd)? then
                  pos--
                  area.setSelectionRange?(pos, pos)
              setTimeout fixUp, 0
          setup: @>
            # @fs.readFileSync = (x)=> @readFileSync(x)
            # @fs.writeFileSync = (x)=> @readFileSync(x)
            # @ace? and @setupAce()
            app = @
            @view.runButton.onclick      = => @runButtonClick()
            @view.enlargeButton.onclick  = => @enlargeButtonClick()
            # @view.dragButton.onmousedown = (event)-> app.dragButtonDown(event,this)
            @view.dragButton.onmouseup   = (event)-> app.dragButtonUp(event,this)
            @view.shrinkButton.onclick   = => @shrinkButtonClick()
            @view.killButton.onclick     = => @killButtonClick()
            area = @view.coffeeArea
            area.focus()
            (pos = area.value.length)? then area.setSelectionRange?(pos, pos)
            area.setupTransform = (editor)->
              area.transformed = editor
              app.aceRefcoffeeMode (mode)->
                editor.getSession().setMode(mode)
              editor.setTheme("ace/theme/merbivore")
            @getElement().onkeydown = (event)->
              return app.handleEnterKey?(event) if event.keyCode and event.keyCode is 13
              true
                       
          getElement: @> @view.coffeecharniaConsole
        
          killButtonClick: @>
            el = @getElement()
            el.parentNode.removeChild el
        
          shrinkButtonClick: @>
            el = @getElement()
            s = @sizePercentage ? 38
            s = s / 100.0
            s = s / (1 + 0.05 + (1 - s) / 5)
            s = 0.1 if s < 0.1
            @sizePercentage = s * 100
            el.setAttribute('style', @inlineStyle())
            @recalculateTextareaSize()
        
          dragButtonUp: (ev,el)@>
           r = el.getClientRects()[0]
           x = (((ev.clientX - r.left) / r.width) * 3)|0
           y = (((ev.clientY - r.top) / r.height) * 3)|0
           x < 0 then x = 0 else x > 3 then x = 3
           y < 0 then y = 0 else y > 3 then y = 3
           @gravity = [ x, y ]
           el = @getElement()
           el.setAttribute('style', @inlineStyle())
           @recalculateTextareaSize()              
             
          enlargeButtonClick: @>
           el = @getElement()
           s = @sizePercentage ? 38
           s = s / 100.0
           s = s * (1 + 0.05 + (1 - s)/5)
           s = 1 if s > 1
           @sizePercentage = s * 100
           el.setAttribute('style', @inlineStyle())
           @recalculateTextareaSize()
         
          hideButtonClick: @>
           el = @getElement()
           el.setAttribute "style", el.getAttribute("style") + ";display:none"
                       
          getSelection: @>
            (t = @view.coffeeArea.transformed)? then
              t.getSelection()
            else
              @getInputSelection(@view)
                       
          aceEditor: @>
            @view.coffeeArea.transformed
                          
          handleEnterKey: (event)@>
            if event.shiftKey
              return true
            if event.ctrlKey
                  @runButtonClick()
                  return false
            (editor = @aceEditor())? then
              alert = @alert
              cursorPosition = editor.getCursorPosition()
              doc = editor.session.doc
              lines = doc.getLength()
              # lines - 1 <= cursorPosition.row then
              line = doc.getLine(cursorPosition.row)
              !/\S/.test(line) then
                      line.length is cursorPosition.column then
                          @runButtonClick()
                          return false
            else
              area = @view.coffeeArea
              (end = area.selectionEnd)? then
                text = area.value
                text.length > 0 and text.length <= end and text[text.length - 1] is "\n" then
                    @runButtonClick()
                    return false
            true
                       
          aceRefcoffeeMode: (cb)@>
            cb? then
              ace = @libs.ace
              ace.config.loadModule "ace/mode/coffee", =>
                @libs.aceRefcoffeeMode.setup ace: @libs.ace, CoffeeScript: @libs.CoffeeScript
                cb "ace/mode/refcoffee"
            else
              try
                @libs.aceRefcoffeeMode.setup ace: @libs.ace, CoffeeScript: @libs.CoffeeScript
                @libs.ace.require("ace/mode/refcoffee")
                "ace/mode/refcoffee"
              catch e
                "ace/mode/coffee"
          
        lib:
          alert: alert
          Error: Error
          window: window
          document: document
          deleteNode: (x)@> x.parentNode.removeChild(x)
          camelcapBookmarklet:
             lib: { document, RegExp }
             setup: (ace)@>
              { document, RegExp } = @lib
              return if document.getElementById "ccapcss"
              ace.require ["ace/layer/text"], ({Text}) ->
                return if document.getElementById "ccapcss"
                orig = Text.prototype.$renderToken
              
                patched = do (
                  rgx = new RegExp "[a-z][0-9]*[A-Z]", "g"
                ) -> (builder, col, token, value) ->
                  if match = rgx.exec value
                    type = token.type
                    type_c = type + ".ccap"
                    p = 0
                    loop
                      q = rgx.lastIndex - 1
                      s = value.substring(p, q)
                      col = orig.call @, builder, col, { type, value: s }, s
                      s = value.substring(q, p = q + 1)
                      col = orig.call @, builder, col, { type: type_c, value: s }, s
                      break unless match = rgx.exec value
                    s = value.substring(p)
                    orig.call @, builder, col, { type, value: s }, s            
                  else
                    orig.apply @, arguments
              
                Text.prototype.$renderToken = patched
              
                x = document.createElement "style"
                x.id = "ccapcss"
                x.innerHTML = ".ace_ccap { font-weight: bold; }"
                document.head.appendChild x
          HtmlGizmo:
            pkgInfo:
              version: "HtmlGizmo 0.2.0"
              description: "Reflective Html Widgets"
              copyright: "Copyright (c) 2014 Michele Bini"
              license: "GPL3"
            # Interface
            #
            # Abstract method:
            #
            # make: (htmlcup)@>
            #
            #  Create the HTML for the widget using the provided htmlcup object.
            #
            #  Can call @cssClass() and @homeEvent()
            #
            withBroker: (symbol)@>
              # Allow specifying a global symbol for the widget instance.  If at all, it should be run before 'make'
              eventHub: symbol
              __proto__: @
            withHome: (home)@>
              eventHome: home
              __proto__: @
            setElement: (@element)->
              # This may be run after 'make' to the set element when it is obtained
            withCssPrefix: (prefix)@>
              # Allow prefixing all css classes.  If at all, it should be run before 'make'
              cssPrefix: prefix
              __proto__: @
            getGlobalCss: @> # Abstract
            getElement: (name)@>
              # Get a named element of the widget
              @element.getElementsByClassName(@cssClass(name))?[0]
            
            # For use inside 'make'
            cssClass:     (name)@>
              @cssPrefix + name
            homeEvent:  (name)@>
              "javascript:#{@eventHome ? throw "No event home defined"}.#{name}(event,this)"
            
            # Implementation
            eventHome: null
            cssPrefix: ""
            element: null
          DynmodPrinter:
            pkgInfo:
              version: "DynmodPrinter 0.2.7-coffeecharnia"
              description: "Generic printer, for data and reflective code"
              copyright: "Copyright (c) 2014 Michele Bini"
              license: "MIT"
            pkgTest: @>
              testPrint = (v, r)=>
                r2 = @print(v)
                if r isnt r2
                  throw "Expected representation: '#{r}', obtained: '#{r2}'"
              testPrint [ ], "[ ]"
              testPrint [ { } ], "[ { } ]"
              testPrint new @Date("2014-05-12T23:04:24.627Z"), 'new Date("2014-05-12T23:04:24.627Z")'
            Date: Date
            Array: Array
            RegExp: RegExp
            columns:
              74
            console: console
            window: window
            global: window
            globalName: "window"
            symbolicPackages: true
            # maxLines: 1000
            newline: @> true
            limitLines: (maxLines)@>
              lines: 0
              maxLines: maxLines
              newline: @> @lines++ < @maxLines
              __proto__: @
            print:
              (x, prev, depth = 0, ind = "")@>
                p = arguments.callee
                depth = depth + 1
                print = (y)=> p.call @, y, { prev, x }, depth
                clean = (x)->
                  if /^[(]([(@][^\n]*)[)]$/.test x
                    x.substring(1, x.length - 1)
                  else
                    x
                if x == null
                  ind + "null"
                else if x == @global
                  ind + @globalName
                else if x == undefined
                  ind + "undefined"
                else
                  t = typeof x
                  if t is "boolean"
                    ind + if x then "true" else "false"
                  else if t is "number"
                    ind + @printNumber x
                  else if t is "string"
                    if x.length > 8 and /\n/.test x
                      l = x.split("\n")
                      l = (x.replace /\"\"\"/g, '\"\"\"' for x in l)
                      l.unshift ind + '"""'
                      l.push     ind + '"""'
                      l.join(ind + "\n")
                    else
                      ind + '"' + x.replace(/\"/g, "\\\"") + '"'
                  else if t is "function"
                    ni = ind + "  "
                    if x.coffee?
                      # YAY a reflective function!!!
                      s = x.coffee
                      if depth is 1 or /\n/.test s
                        lines = s.split "\n"
                        if lines.length > 1
                          if (mn = lines[1].match(/^[ \t]+/))?
                            mn = mn[0].length
                            id = mn - ni.length
                            if id > 0
                              x = new @RegExp("[ \\t]{#{id}}")
                              lines = (line.replace x, "" for line in lines)
                            else if id < 0
                              ni = @Array(-id + 1).join(" ")
                              lines = (ni + line for line in lines)                
                        lines.join("\n")
                      else
                        ind + "(" + s + ")"
                    else
                      ind + x.toString().replace(/\n/g, '\n' + ni)
                  else if (c = (do (p = prev, c = 1)-> (return c if p.x == x; p = p.prev; c++) while p?; 0))
                    # Report cyclic structures
                    "<cycle-#{c}+#{depth - c - 1}>"
                  else if t isnt "object"
                    # print object of odd type
                    "<#{t}>"
                  else if @Array.isArray x
                    if x.length is 0
                      "[ ]"
                    else
                      cl = 2
                      hasLines = false
                      xxxx = for xx in x
                        break unless @newline()
                        xx = print xx
                        hasLines = true if /\n/.test xx
                        cl += 2 + xx.length
                        xx
                      if not hasLines and depth * 2 + cl + 1 < @columns
                        "[ " + xxxx.join(", ") + " ]"
                      else
                        ni = ind + "  "
                        l = [ ind + "[" ]
                        for xx in xxxx
                          l.push ni + clean(xx).replace(/\n/g, '\n' + ni)
                        l.push ind + "]"
                        l.join "\n"
                  else
                    l = [ ]
                    @window?.document?   and   x.id?   and   typeof x.id is "string"   and   x is @window.document.getElementById x.id   then
                      return "#{ind}window.document.getElementById '#{ x.id.replace(/\'/, "\\'") }'"
                    @symbolicPackages and depth > 1 and (packageVersion = x.pkgInfo?.version)? then
                      return ind + "dynmodArchive.load '" + packageVersion.replace(/\ .*/, "") + "'"
                    ind = ""
                    if x instanceof @Date
                      return "new Date(\"#{x.toISOString()}\")"
                    keys = (k for k of x)
                    if keys.length is 0
                      return "{ }"
                    unless (!prev? or typeof prev.x is "object" and !@Array.isArray prev.x)
                      l = [ "do->" ]
                      ind = "  "
                    ni = ind + "  "
                    # keys = (h)@> (x for x of h).sort()
                    for k in keys
                      break unless @newline()
                      v = x[k]
                      if @global[k] is v
                        # l.push ind + k + ": eval " + "'" + k + "'"
                        l.push "#{ind}#{k}: #{@globalName}.#{k}"
                      else
                        v = clean(print v).replace(/\n/g, '\n' + ni)
                        if !/\n/.test(v) and  ind.length + k.toString().length + 2 + v.length < @columns
                          l.push ind + k + ": " + v
                        else
                          l.push ind + k + ":"
                          l.push ni + v
                    if l.length
                      l.join "\n"
                    else
                      "{ }"
            printNumber:
              (x)@> "#{x}"
          htmlcup:
            # compileAndRun: (x)->
            #   c = @compileLib
            #   x.call x
            __proto__:
              pkgInfo:
                version: "HtmlCup 0.2.1"
                title: "HTML-generating lingo"
                copyright: "Copyright (c) 2013,2014 Michele Bini"
                notes: "This is a port of htmlcup as a dynmod package"
                license: "GPL3"
              # This is an abstract method yet: printHtml: (t) @> @process.stdout.write t
              quoteTagText: (str) @>
                  str.replace /[&<]/g, (c) ->
                    if c is '<' then '&lt;' else '&amp;'
              quoteText: (str) @>
                  str.replace /[&<"]/g, (c) ->              # "
                    if c is '<' then '&lt;'
                    else if c is '&'
                    then '&amp;'
                    else '&quot;'
              docType: @> @printHtml "<!DOCTYPE html>\n"
              voidElements: @>
                  # References:
                  #  http://www.w3.org/TR/html5/syntax.html
                  #  http://www.w3.org/TR/html-markup/elements.html
                  "area, base, br, col, command, embed, hr, img, input, keygen, link, meta, param, source, track, wbr"
              foreignElements: @> 'math, svg'
              rawTextElements: @> 'script, style'
              allElements: @>
                """
                a, abbr, address, area, article, aside, audio, b, base, bdi, bdo,
                blockquote, body, br, button, button, button, button, canvas, caption,
                cite, code, col, colgroup, command, command, command, command,
                datalist, dd, del, details, dfn, div, dl, dt, em, embed, fieldset,
                figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head,
                header, hgroup, hr, html, i, iframe, img, input, ins, kbd, keygen,
                label, legend, li, link, map, mark, menu, meta, meta, meta, meta,
                meta, meta, meter, nav, noscript, object, ol, optgroup, option,
                output, p, param, pre, progress, q, rp, rt, ruby, s, samp, script,
                section, select, small, source, span, strong, style, sub, summary,
                sup, table, tbody, td, textarea, tfoot, th, thead, time, title, tr,
                track, u, ul, var, video, wbr
                """
              compileTag: (tagName, isVoid, isRawText) @> (args...) ->
                  @printHtml "<#{tagName}"
                  for arg in args
                    if typeof arg is 'function'
                      f = arg
                      break
                    if typeof arg is 'string'
                      s = arg
                      break
                    for x,y of arg
                      if y?
                        @printHtml " #{x}=\"#{@quoteText y}\""
                      else
                        @printHtml " #{x}"
                  @printHtml '>'
                  return if isVoid
                  f.apply @     if f
                  if s
                    if isRawText
                      @printHtml s
                    else
                      @printHtml @quoteTagText s
                  @printHtml '</' + tagName + '>'
              compileLib: @>
                  isArray = [].constructor.isArray
                  makeset = (l) ->
                    if typeof l is 'function'
                      l = l.call @
                    if typeof l is 'string'
                      l = l.split ","
                    if isArray l
                      r = { }
                      for x in l
                        x = x.replace(/[^a-z0-9]+/g, "")
                        r[x] = 1
                      return r
                    else
                      return l
                  h = __proto__: @
                  if @voidElements is 'function'
                    h.sourceFunctions = { @voidElements, @rawTextElements, @allElements }
                  h.voidElements = makeset @voidElements
                  h.rawTextElements = makeset @rawTextElements
                  h.allElements = makeset @allElements
                  h[x] = @compileTag(x, ((h.voidElements[x])?), ((h.rawTextElements[x])?)) for x of h.allElements
                  h
              pkgExpand: @> @compileLib()
              modRecmopile: @> @compileLib()
              pkgCompress: @>
                  isArray = [].constructor.isArray
                  h = @sourceFunctions or { }
                  h = @modMixin.call h, @
                  h = @modStrip.call h, @allElements
                  h
              html5Page:
                (args...) @>
                  @docType 5
                  @html.apply @, args
            capturedTokens: []
            printHtml: (t)@> @capturedTokens.push t
            captureHtml: (f)@>
              o = @capturedTokens
              @capturedTokens = []
              f.apply @
              p = @capturedTokens
              @capturedTokens = o
              r = p.join ""
              @printHtml r
              r
            namedObjects:
              document: document
            captureFirstTag: (f)@>
              { document } = @namedObjects
              div = document.createElement "div"
              div.innerHTML = @captureHtml f
              div.firstChild
            stripOuter: (x)@>
              x.replace(/^<[^>]*>/, "").replace(/<[^>]*>$/, "")
            capturedParts: {}
            capturePart: (tagName, stripOuter = @stripOuter)@> ->
              x = arguments
              @capturedParts[tagName] =
                stripOuter (@captureHtml ->
                  @originalLib[tagName].apply @, x
                )
            body: @> (@capturePart "body").apply @, arguments 
            head: @>
              lib = @.extendObject
                title: -> (@capturePart "title").apply @, arguments
                headStyles: []
                style: ->
                  @headStyles.push (@capturePart "style").apply @, arguments
              r = (lib.capturePart "head").apply lib, arguments
              @capturedParts.headStyles = lib.headStyles
              @capturedParts.headTitle = lib.capturedParts.title
              r
            # script: ->
            #  scripts = (@capturedParts.scripts or= [])
            #  push scripts, ((@capturePart "script").apply @, arguments)
            html5Page: @>
              x = arguments
              @captureHtml -> @originalLib.html5Page.apply @, x
              r = @capturedParts
              @capturedParts = {}
              r
        assert: (c, msg)@> { alert } = @lib; alert msg unless c
        jsLoad: (sym, src, callback)@>
          charnia = @
          { window, document, deleteNode } = @lib
          if sym and window[sym]?
            callback() if callback?
            return
          x = document.createElement('script')
          x.type = 'text/javascript'
          x.src = src
          y = 1
          x.onload = x.onreadystatechange = ()->
            charnia.assert(window[sym]?, "Symbol #{sym} was not defined after loading library") if sym
            if y and not @readyState or @readyState is 'complete'
              y = 0
              deleteNode x
              callback() if callback
          document.getElementsByTagName('head')[0].appendChild x
          
        coffeecharniaLayout: ({ cssClass, header, body, footer, minheight, minwidth, style, innerStyle, htmlcup })@>
          # return @div "foobar"
          # This seems rather complex, but it appears to be the simplest effective way to get what I want, flex isn't working as expected
          # @printHtml "<!DOCTYPE html>\n"
          htmlcup.div class:cssClass, style:"#{style}", ->
              @div style:"height:100%;display:table;width:100%;max-width:100%;table-layout:fixed", ->
                    innerStyle? then @style innerStyle
                    if false
                      header.call @, style:"display:table-row;min-height:1em;overflow:auto;max-height:5em", class:"consoleHeader"
                    else if false
                      @div style:"display:table-row;min-height:1em;background:pink", ->
                        @div style:"max-height:5em;overflow-y:scroll;overflow-x:hidden;position:relative;display:block", ->
                          @div style:"float:left;width:100%", contentEditable:"true", ->
                            @div "x" for x in [ 0 .. 25 ]
                    else
                      @div style:"display:table-row;min-height:1em", ->
                        @div style:"max-height:5em;overflow:hidden;position:relative;display:block", ->
                          @div style:"float:left;width:100%", ->
                            header?.call @, class:"consoleHeader"
                    if false then @div style:"position:relative;height:100%;overflow:hidden;display:table-row", ->
                      @div style:"position:relative;width:100%;height:100%;min-height:#{minheight}", ->
                        @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:auto", ->
                          # x (container width)  y (contained width)
                          
                          # 2000 px              2000 px
                          # 1500 px              1500 px
                          # 1000 px              1000 px
                          # 800 px               1000 px
                          # 500 px               1000 px
                          # 300 px               600 px
                          # 200 px               400 px
                          # 150 px               300 px
                          # 100 px               200 px
                          
                          # y = ((x * 2) ^ 1000 px) _ x
                          #      min-width width     max-width
                          # This part does not seem to work on my firefox
                          @div style:"width:200%;max-width:50em;min-width:100%;height:100%;overflow:hidden", ->
                            @div style:"position:relative;width:100%;height:100%;display:table", ->
                            # @div style:"position:relative;width:100%;max-width:100%;height:100%;overflow:auto", ->
                            #  @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:auto", ->
                            #    @div style:"position:relative;max-width:200%;min-width:60em;display:table;background:black", ->
                              body.call @
                    else @div style:"position:relative;height:100%;overflow:hidden;display:table-row", ->
                        @div style:"position:relative;width:100%;height:100%;min-height:#{minheight}", ->
                            @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:auto", ->
                                body.call @
                      #
                    footer.call @, style:"display:table-row"
        aceUrl: "https://github.com/ajaxorg/ace-builds/raw/master/src-min-noconflict/ace.js"
        start: @>
          charnia = @
          { coffeescriptUrl } = @config
          { aceUrl, coffeecharniaBase } = @
          { document, window, DynmodPrinter, Error, camelcapBookmarklet, HtmlGizmo, htmlcup } = @lib
          htmlcup = htmlcup.compileLib()

          htmlgizmo =
            cssPrefix: "coffeecharnia_"
            make: (htmlcup)->
              cssClass = (name)=> @cssClass name
              homeEvent = (name)=> @homeEvent name
              containerClass = cssClass 'container'
              charnia.coffeecharniaLayout
                cssClass: containerClass
                htmlcup: htmlcup
                style: coffeecharniaBase.inlineStyle()
                innerStyle:
                  """
                  .#{containerClass} pre { background:none; color:inherit; }
                  .#{containerClass} div, .#{containerClass} pre { padding: 0; margin:0; text-align:inherit; }
                  .#{containerClass} a { color: #ffb }
                  .#{containerClass} a:visited { color: #eec }
                  .#{containerClass} a:hover { color: white }
                  """
                minheight: "7em",
                minwidth: "60em",
                head: ->
                  @meta charset:"utf-8"
                  @style """
                    .#{containerClass} { background:black; color: #ddd; }
                    .#{containerClass} a { color:#5af; }
                    .#{containerClass} a:visited { color:#49f; }
                    .#{containerClass} a:hover { color:#6cf; }
                    .#{containerClass} select, textarea { border: 1px solid #555; }
                    """
                header: (opts)->
                  @style """
                      div.thisHeader, .thisHeader div { text-align:center; }
                      """
                  @div opts, ->
                    @style """
                      /* .#{containerClass} select { min-width:5em; max-width:30%; width:18em; } */
                      .#{containerClass} select, .#{containerClass} button { font-size:inherit; text-align:center;   }
                      .#{containerClass} .button { display:inline-block; }
                      .#{containerClass} button, .#{containerClass} .button, .#{containerClass} input, .#{containerClass} select:not(:focus):not(:hover) { color:white; background:black; }
                      /* select option:not(:checked) { color:red !important; background:black !important; } */
                      /* option:active, option[selected], option:checked, option:hover, option:focus { background:#248 !important; } */
                      .#{containerClass} button, .#{containerClass} .button { min-width:5%; font-size:220%; border: 2px outset grey; }
                      .#{containerClass} button:active, .#{containerClass} .button.button-on { border: 2px inset grey; background:#248; }
                      .#{containerClass} .button input[type="checkbox"] { display:none; }
                      .#{containerClass} .arrow { font-weight:bold;  }
                      .#{containerClass} .editArea { height:100%;width:100%;box-sizing:border-box; }
                      """
                body: (opts)->
                    @style """
                      .#{containerClass} textarea { background: black; color: #ddd; }
                      .#{containerClass} button { opacity: 0.22; }
                      .#{containerClass} button:hover, .#{containerClass} button:focus, .#{containerClass} button:active { opacity: 1; }
                      """
                    @div style:"font-size:12px;position:absolute;top:0;right:0;left:0;bottom:0;overflow:hidden", ->
                        px = 44;
                        w = "width:#{px}px;max-width:#{px}px;min-width:#{px}px"
                        i = 1
                        @button class:cssClass("runButton"),      style:"#{w};right:0;top:0;position:absolute;z-index:1000000", "▶"
                        @button class:cssClass("enlargeButton"),  style:"#{w};right:#{px*(i++)}px;top:0;position:absolute;z-index:1000000", "⬜"
                        @button class:cssClass("dragButton"),     style:"#{w};right:#{px*(i++)}px;top:0;position:absolute;z-index:1000000", "⛶"
                        @button class:cssClass("shrinkButton"),   style:"#{w};right:#{px*(i++)}px;top:0;position:absolute;z-index:1000000", "▫"
                        @button class:cssClass("killButton"),     style:"#{w};right:#{px*(i++)}px;top:0;position:absolute;z-index:1000000", "⨯"
                        @textarea class:"#{cssClass("coffeeArea")} editArea",
                          """
                          # Welcome to CoffeeCharnia!
                          """
                        ####
                          # Press return twice after a statement to execute it!
              
                          
                footer: (opts)->
                  @style """
                      .#{containerClass} div.#{cssClass 'thisFooter'}, .#{containerClass} .#{cssClass 'thisFooter'} div { text-align:center; }
                      """
                  @div class:cssClass('thisFooter'), opts, ->
                    @style """
                      .#{containerClass} div.#{cssClass 'thisFooter'} div.#{cssClass 'resultFooter'} {
                        /* overflow:auto; */
                        vertical-align: middle;
                      }
                      .#{containerClass} div.#{cssClass 'thisFooter'} div.#{cssClass 'resultDatum'} {
                        text-align:initial;
                        vertical-align:initial;
                        display:inline-block;
                      }
                      """
                    @div class:cssClass("resultFooter"), style:"display:none", ->
                      @div class:cssClass("resultDatum"), ->
                    @div class:cssClass("introFooter"), ->
                      @b "CoffeeCharnia"
                      @span ->
                        @span ": "
                        @i "A Reflective Coffescript Console/Editor!"
                      @printHtml " &bull; "
                      @a href:"https://github.com/rev22/reflective-coffeescript", "Reflective Coffeescript"
            __proto__: HtmlGizmo

          element = htmlcup.captureFirstTag -> htmlgizmo.make @
          htmlgizmo.setElement(element)
          document.body.appendChild element
          
          withAce = (cb)-> charnia.jsLoad 'ace', aceUrl, cb
          withCoffee = (cb)-> charnia.jsLoad 'CoffeeScript', coffeescriptUrl, cb
          withAce -> withCoffee ->
            globalLibs =
              aceRefcoffeeMode:
                setup: ({ace, console, CoffeeScript})@>
                      ace.define "ace/mode/refcoffee_highlight_rules", [
                        "require"
                        "exports"
                        "module"
                        "ace/mode/coffee_highlight_rules"
                      ], (req, exports, module)->
                        RefcoffeeHighlightRules = ->
                          @$rules.start = [
                              {
                                stateName: "litdoc"
                                token: "string"
                                regex: "''''"
                              }
                          ].concat @$rules.start
          
                          @$rules.start = for x in @$rules.start
                            if x?.regex? and typeof x.regex is 'string'
                              x.regex = x.regex.replace /\[\\-=\]>/, "[\\-=@]>"
                            x
                          
                          @normalizeRules()
                          return
                        "use strict"
                        makeClass = (p)-> c = p.constructor; c:: = p; c
                        CoffeeHighlightRules = req("./coffee_highlight_rules").CoffeeHighlightRules
                        exports.RefcoffeeHighlightRules = makeClass
                          constructor: ->
                            CoffeeHighlightRules.call @
                            RefcoffeeHighlightRules.call @
                            return
                          __proto__: CoffeeHighlightRules::
                        return
                        
                      ace.define "ace/mode/refcoffee", [
                        "require"
                        "exports"
                        "module"
                        "ace/mode/coffee"
                        "ace/mode/refcoffee_highlight_rules"
                      ], (req, exports, module)->
                        WorkerClient = undefined
                        CoffeeMode = req("ace/mode/coffee").Mode
                        makeClass = (p)-> c = p.constructor; c:: = p; c
                        Rules = req("./refcoffee_highlight_rules").RefcoffeeHighlightRules
                        Mode = makeClass
                          __proto__: CoffeeMode::
                          constructor: ->
                            CoffeeMode.call @
                            @HighlightRules = Rules
                            # @$outdent = new Outdent()
                            # @foldingRules = new FoldMode()
                            return
                        "use strict"
                        (->
                          @$id = "ace/mode/refcoffee"
                          @createWorker = (session)-> null
                          return
                        ).call Mode::
                        exports.Mode = Mode
                        return
            
            window.coffeecharnia = app =
              libs:
                CoffeeScript: window.CoffeeScript
                aceRefcoffeeMode: globalLibs.aceRefcoffeeMode
                ace: window.ace
                DynmodPrinter: DynmodPrinter
                camelcapBookmarklet: camelcapBookmarklet
              
              eval: window.eval
              setTimeout: window.setTimeout
              getInputSelection: window.getInputSelection
              global: window.eval 'window'
              window: window
          
              view: ((x)-> r = {}; r[v] = htmlgizmo.getElement(v) for v in x.split(","); r.coffeecharniaConsole = element; r ) "coffeeArea,runButton,enlargeButton,dragButton,shrinkButton,killButton,introFooter,resultFooter,resultDatum"
                       
              # ace: ace ? null
              # setupAce: @> @ace.edit(@view.coffeeArea)
          
              Error: Error
          
              files: { }
          
              __proto__: coffeecharniaBase
          
            app.setup()
          
            
            # Some sane defaults!  However, this code does not seem to effect any change
            ###
            false then ace?.options =
                mode:             "coffee"
                theme:            "cobalt"
                gutter:           "true"
                # fontSize:         "10px"
                # softWrap:         "off"
                # keybindings:      "ace"
                # showPrintMargin:  "true"
                # useSoftTabs:      "true"
                # showInvisibles:   "false"
            ###
            inject = (options, callback) ->
              baseUrl = options.baseUrl or "../../src-noconflict"
              load = (path, callback) ->
                head = document.getElementsByTagName("head")[0]
                s = document.createElement("script")
                s.src = baseUrl + "/" + path
                head.appendChild s
                s.onload = s.onreadystatechange = (_, isAbort) ->
                  if isAbort or not s.readyState or s.readyState is "loaded" or s.readyState is "complete"
                    s = s.onload = s.onreadystatechange = null
                    callback()  unless isAbort
                  return
          
                return
          
              if window.ace?
                
                # load("ace.js", function() {
                window.ace.config.loadModule "ace/ext/textarea", ->
                  if false
                    event = window.ace.require("ace/lib/event")
                    areas = document.getElementsByTagName("textarea")
                    i = 0
          
                    while i < areas.length
                      event.addListener areas[i], "click", (e) ->
                        window.ace.transformTextarea e.target, options.ace  if e.detail is 3
                        return
          
                      i++
                  callback and callback()
                  return
          
              return
          
            # });
          
            window.ace? then camelcapBookmarklet.setup(window.ace)
          
            # Call the inject function to load the ace files.
            inject {}, do (ace = window.ace)-> ->
              
              # Transform the textarea on the page into an ace editor.
              for a in [ app.view.coffeeArea ] # (x for x in document.getElementsByClassName("editArea")).reverse()
                do (a, e = ace.require("ace/ext/textarea").transformTextarea(a))->
                  e = ace.require("ace/ext/textarea").transformTextarea(a)
                  e.navigateFileEnd()
                  a.setupTransform(e)
                  a.onchange = ->
                    # alert "a onchange " + x
                    e.setValue @value, -1
                    return
          
                  e.on "change", ->
                    # alert "e change " + x
                    a.value = e.getValue()
                    a.oninput?()
                    return
          
                  e.on "blur", ->
                    # alert "e blur " + x
                    a.value = e.getValue()
                    a.onblur?()
                    return
          
                  e.on "focus", ->
                    a.onfocus?()
                    return
              return      

window.coffeecharniaLoader.start()
