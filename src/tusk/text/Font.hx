package tusk.text;

import haxe.ds.IntMap;
import haxe.Json;

class Font {
    public var glyphs:IntMap<Glyph> = new IntMap<Glyph>();

    public var base(default, null):Float;
    public var lineHeight(default, null):Float;
    public var spaceWidth(default, null):Float;
    public var ascent(default, null):Float;
    public var descent(default, null):Float;

    private var unknownGlyph:Glyph;

    public static function fromFontSrc(src:String):Font {
        return new Font(Json.parse(src));
    }

    public function new(bmFont:BMFont) {
        base = bmFont.common.base;
        lineHeight = bmFont.common.lineHeight;
        descent = lineHeight - base;
        ascent = 0;

        var imSize:Vec2 = new Vec2(bmFont.common.scaleW, bmFont.common.scaleH);
        for(char in bmFont.chars) {
            var g:Glyph = new Glyph(char, imSize);
            glyphs.set(char.id, g);

            // find the maximum ascent
            var a:Float = base - g.size.y;
            if(a > ascent) {
                ascent = a;
            }
        }

        unknownGlyph = glyphs.get('?'.charCodeAt(0));
        spaceWidth = glyphs.get(' '.charCodeAt(0)).xAdvance;
    }

    public function textWidth(text:String):Float {
        var width:Float = 0, maxWidth:Float = 0;

        for(i in 0...text.length) {
            var idx:Int = text.charCodeAt(i);
            if(idx == null) continue;

            // deal with special characters
            width += switch(idx) {
                case 32: { // ' '
                    spaceWidth;
                }

                case 10: { // '\n'
                    if(width > maxWidth)
                        maxWidth = width;
                    -1 * width;
                }

                case 13: { // '\r'
                    if(width > maxWidth)
                        maxWidth = width;
                    -1 * width;
                }

                case 9: { // '\t'
                    4 * spaceWidth;
                }

                case 0x1B: { // escape
                    0;
                }

                case _: {
                    var g:Glyph = glyphs.get(idx);
                    if(g == null) g = unknownGlyph;
                    g.xAdvance;
                }
            }
        }

        if(width > maxWidth)
            maxWidth = width;

        return maxWidth;
    }

    public function print(x:Float, y:Float, text:String, addVertex:AddVertexFunc):Void {
        var _x:Float = x;
        var _y:Float = y;

        var i:Int = 0;
        var colour:Vec4 = null;
        while(i < text.length) {
            var idx:Int = text.charCodeAt(i);
            if(idx == null) continue;

            // deal with special characters
            if(idx == ' '.charCodeAt(0)) {
                _x += spaceWidth;
                continue;
            }
            else if(idx == '\n'.charCodeAt(0)) {
                _x = x;
                _y += lineHeight;
                continue;
            }
            else if(idx == '\r'.charCodeAt(0)) {
                _x = x;
                continue;
            }
            else if(idx == '\t'.charCodeAt(0)) {
                _x += (spaceWidth * 4);
                continue;
            }
            else if(idx == 0x1B) {
                if(i + 1 >= text.length) return;
                colour = switch(text.charCodeAt(i + 1)) {
                    case 0x72: colour = new Vec4(1, 0, 0, 1); // 'r'
                    case 0x67: colour = new Vec4(0, 1, 0, 1); // 'g'
                    case 0x62: colour = new Vec4(0, 0, 1, 1); // 'b'
                    case 0x63: colour = new Vec4(0, 1, 1, 1); // 'c'
                    case 0x79: colour = new Vec4(1, 1, 0, 1); // 'y'
                    case 0x6d: colour = new Vec4(1, 0, 1, 1); // 'm'
                    case 0x6b: colour = new Vec4(0, 0, 0, 1); // 'k'
                    case _: null;
                };
                i += 2;
                continue;
            }

            // draw a glyph
            var g:Glyph = glyphs.get(idx);
            if(g == null) g = unknownGlyph;

            var x0:Float = _x + g.offset.x;
            var x1:Float = x0 + g.size.x;
            var y0:Float = _y + g.offset.y - base;
            var y1:Float = y0 + g.size.y;

            addVertex(x0, y0, g.uvMin.x, g.uvMin.y);
            addVertex(x1, y0, g.uvMax.x, g.uvMin.y);
            addVertex(x0, y1, g.uvMin.x, g.uvMax.y);

            addVertex(x0, y1, g.uvMin.x, g.uvMax.y);
            addVertex(x1, y0, g.uvMax.x, g.uvMin.y);
            addVertex(x1, y1, g.uvMax.x, g.uvMax.y);

            _x += g.xAdvance;
            i++;
        }
    }
}