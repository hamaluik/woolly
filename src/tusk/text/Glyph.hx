package tusk.text;

class Glyph {
    public var uvMin:Vec2;
    public var uvMax:Vec2;

    public var xAdvance:Float;
    public var size:Vec2;
    public var offset:Vec2;

    public function new(char:BMFont.Char, imSize:Vec2) {
        uvMin = new Vec2(char.x / imSize.x, char.y / imSize.y);
        uvMax = new Vec2(uvMin.x + (char.width / imSize.x), uvMin.y + (char.height / imSize.y));

        xAdvance = char.xadvance;
        size = new Vec2(char.width, char.height);
        offset = new Vec2(char.xoffset, char.yoffset);
    }
}