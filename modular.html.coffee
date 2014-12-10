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
  
htmlcup.html lang:"en", manifest:"coffeecharnia.appcache", style:"height:100%", ->
  @head ->
    @meta charset:"utf-8"
  @body ->
    @div "This demo lets you start multiple consoles."
    @script src:"coffeecharnia.js"
    @button onclick:"javascript:coffeecharnia.spawn()", "Start!"
