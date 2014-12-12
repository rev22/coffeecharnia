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

fs = require 'fs'
datauri = (t,x)-> "data:#{t};base64,#{new Buffer(fs.readFileSync(x)).toString("
datauriicon = (x)-> datauri "image/x-icon", x

htmlcup.html lang:"en", manifest:"coffeecharnia.appcache", style:"height:100%", ->
  @head ->
    @meta charset:"utf-8"
    @title "CoffeeCharnia"
    @meta id:"meta", name:"viewport", content:"width=device-width, user-scalable=no, initial-scale=1"
    @meta name:"apple-mobile-web-app-capable", content:"yes"
    @meta name:"mobile-web-app-capable", content:"yes"
    @link rel:"shortcut icon", href:datauriicon("favicon.ico")
  @body ->
    @script src:"coffeecharnia.js"
    @script "( { sizePercentage: 100, __proto__: coffeecharnia } ).spawn()"
    @coffeeScript ->
      window.addEventListener('load', ((e)->
        if (window.applicationCache)
          window.applicationCache.addEventListener('updateready', ((e)->
              # if (window.applicationCache.status == window.applicationCache.UPDATEREADY)
                # Browser downloaded a new app cache.
                # Swap it in and reload the page to get the new hotness.               window.applicationCache.swapCache()
                if (confirm('A new version of this site is available. Load it?'))
                  window.location.reload()
              # else
                # Manifest didn't changed. Nothing new to server.
          ), false)
      ), false)
