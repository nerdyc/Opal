# Opal XML Pull Parser

Opal is an XML pull parser written in Objective-C 2.0. XML pull parsers have a simpler interface than event-driven
parsers like NSXMLParser or SAX parsers, while avoiding the large memory and parsing overhead of DOM parsers. While
pull parsers can be extremely performant as well as easy, Opal's current focus is to provide a simple API so I don't
have to write any more annoying state machine parsers.

## Status

Opal is still very alpha software. It provides support for the most commonly used XML features, but does no validation
and currently has little error handling. It's a work in progress, basically, though the following are tested and working
(for valid XML documents):

* XML Declarations
* Elements &amp; Attributes
* Comments
* Text

Specifically NOT supported right now:

* DOCTYPEs
* DTDs
* Processing Instructions
* Namespaces
* Validation
* Everything else

## License

Opal is provided under an MIT-style License:

Copyright (c) 2010 Christian Niles (christian@nerdyc.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.