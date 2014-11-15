# Copyright (c) 2014 Michele Bini <michele.bini@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the version 3 of the GNU General Public License
# as published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

{ htmlcup } = require 'htmlcup'
  
rootLayout = ({ head, header, body, footer, tail, minheight, minwidth })->
      # This seems rather complex, but it appears to be the simplest effective way to get what I want, flex isn't working as expected
      @printHtml "<!DOCTYPE html>\n"
      @html lang:"en", manifest:"coffeeconsole.appcache", style:"height:100%", ->
        head.call @
        @body style:"height:100%;margin:0;overflow:auto", ->
            @div id:"console", tabindex:"0", style:"height:100%;display:table;width:100%;max-width:100%;table-layout:fixed", ->
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
                footer.call @, id:"footer", style:"display:table-row"
            tail.call @

rootLayout.call htmlcup,
  minheight: "7em",
  minwidth: "60em",
  head: ->
    @meta charset:"utf-8"
    @coffeeScript ->
      window.console.log.msgRing or do (parent = window.console)->
        log = ->
          arguments[0]? then arguments.callee.msgRing.push arguments[0]
          parent.log.apply @, arguments
        log.msgRing = [ ]
        window.console = { log, __proto__: parent }
    @coffeeScript -> window.console.log "Loading CoffeeCharnia page"
    @title "CoffeeCharnia"
    @meta id:"meta", name:"viewport", content:"width=device-width, user-scalable=no, initial-scale=1"
    @style """
      div,pre { padding: 0; margin:0; }
      body { background:black; color: #ddd; }
      a { color:#5af; }
      a:visited { color:#49f; }
      a:hover { color:#6cf; }
      select, textarea { border: 1px solid #555; }
      """
  header: (opts)->
    @style """
        div.thisHeader, .thisHeader div { text-align:center; }
        """
    @div opts, ->
      @style """
        select { min-width:5em; max-width:30%; width:18em; }
        select, button { font-size:inherit; text-align:center;   }
        .button { display:inline-block; }
        button, .button, input, select:not(:focus):not(:hover) { color:white; background:black; }
        /* select option:not(:checked) { color:red !important; background:black !important; } */
        /* option:active, option[selected], option:checked, option:hover, option:focus { background:#248 !important; } */
        button, .button { min-width:5%; font-size:220%; border: 2px outset grey; }
        button:active, .button.button-on { border: 2px inset grey; background:#248; }
        .button input[type="checkbox"] { display:none; }
        .arrow { font-weight:bold;  }
        .editArea { height:100%;width:100%;box-sizing:border-box; }
        """
      false then @div class:"thisHeader", ->
        return @div ->
          @span "CoffeeCharnia"
          @button id:"runButton", "▶"
        @select disabled:"1", ->
          @option "HTML"
          @option "PHP"
        @button id:"fromButton", class:"arrow", "«"
        @label id:"autoButton", class:"button button-on", ->
          @input type:"checkbox", checked:"1", onchange:'this.parentNode.setAttribute("class", "button button-" + (this.checked ? "on" : "off"))'
          @span id:"autoButtonText", "Auto"
        @button id:"toButton", class:"arrow", "»"
        @select disabled:"1", ->
          @option "CoffeeScript (htmlcup)"
          @option "Reflective CoffeeScript (htmlcup)"
  body: (opts)->
      @style """
        textarea { background: black; color: #ddd; }
        button { opacity: 0.4; }
        button:hover, button:focus, button:active { opacity: 1; }
        """
      @div style:"position:absolute;top:0;right:0;left:0;bottom:0;overflow:hidden", ->
          @button id:"runButton", style:"right:0;top:0;position:absolute;z-index:1000000", "▶"
          @textarea id:"coffeeArea", class:"editArea",
            ''''
            # Welcome to CoffeeCharnia!

          ####
            # Press return twice after a statement to execute it!

            
  footer: (opts)->
    @style """
        div.thisFooter, .thisFooter div { text-align:center; }
        """
    @div class:"thisFooter", opts, ->
      @style
        ''''
        #resultFooter {
          /* overflow:auto; */
          vertical-align: middle;
        }
        #resultDatum {
          text-align:initial;
          vertical-align:initial;
          display:inline-block;
        }
      @div id:"resultFooter", style:"display:none", ->
        @div id:"resultDatum", ->
      @div id:"introFooter", ->
        @b "CoffeeCharnia"
        @span ->
          @span ": "
          @i "A Reflective Coffescript Console/Editor!"
        @printHtml " &bull; "
        @a href:"https://github.com/rev22/reflective-coffeescript", "Reflective Coffeescript"
  tail: ->
    @script src:"https://github.com/ajaxorg/ace-builds/raw/master/src-min-noconflict/ace.js", type:"text/javascript", charset:"utf-8"
    # @script src:"https://github.com/ajaxorg/ace-builds/raw/master/src-min-noconflict/mode-coffee.js", type:"text/javascript", charset:"utf-8"
    @script src:"coffee-script.js", type:"text/javascript"
    @coffeeScript ->
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

      window.DynmodPrinter =
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
      
      window.app = window.coffeecharnia = app =
        libs:
          CoffeeScript: window.CoffeeScript
          aceRefcoffeeMode: globalLibs.aceRefcoffeeMode
          ace: window.ace
          DynmodPrinter: DynmodPrinter
        
        eval: window.eval
        setTimeout: window.setTimeout
        getInputSelection: window.getInputSelection
        global: window.eval 'window'
        window: window

        view: ((x)-> r = {}; r[v] = document.getElementById(v) for v in x.split(","); r ) "coffeeArea,runButton,introFooter,resultFooter,resultDatum,console"

        accumulator: [ ]

        printHtml: (s)@>
          @accumulator.push s

        isConverting: false

        evalCoffeescript: (x)@>
          @eval(@libs.CoffeeScript.compile x, bare:true)

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
          { console, introFooter, resultFooter, resultDatum } = @view
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
          @view.runButton.onclick = => @runButtonClick()
          area = @view.coffeeArea
          area.focus()
          (pos = area.value.length)? then area.setSelectionRange?(pos, pos)
          area.setupTransform = (editor)->
            area.transformed = editor
            app.aceRefcoffeeMode (mode)->
              editor.getSession().setMode(mode)
            editor.setTheme("ace/theme/merbivore")
          window.onkeydown = (event)->
            return app.handleEnterKey?(event) if event.keyCode and event.keyCode is 13
            true

        getSelection: @>
          (t = @view.coffeeArea.transformed)? then
            t.getSelection()
          else
            @getInputSelection(@view)

        aceEditor: @>
          @view.coffeeArea.transformed
  
        handleEnterKey: (event)@>
          app.captured = event
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

        # ace: ace ? null
        # setupAce: @> @ace.edit(@view.coffeeArea)

        Error: Error

        files: { }

      app.setup()

      
      # Some sane defaults!  However, this code does not seem to effect any change
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

        if ace?
          
          # load("ace.js", function() {
          ace.config.loadModule "ace/ext/textarea", ->
            if false
              event = ace.require("ace/lib/event")
              areas = document.getElementsByTagName("textarea")
              i = 0

              while i < areas.length
                event.addListener areas[i], "click", (e) ->
                  ace.transformTextarea e.target, options.ace  if e.detail is 3
                  return

                i++
            callback and callback()
            return

        return

      # });

      camelcapBookmarklet = (ace)->
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
      ace? then camelcapBookmarklet(ace)

      # Call the inject function to load the ace files.
      inject {}, ->
        
        # Transform the textarea on the page into an ace editor.
        for a in (x for x in document.getElementsByClassName("editArea")).reverse()
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
