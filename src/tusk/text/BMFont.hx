package tusk.text;

typedef Page = String;

typedef Char = {
    var id:Int;
    var x:Float;
    var y:Float;
    var width:Float;
    var height:Float;
    var xoffset:Float;
    var yoffset:Float;
    var xadvance:Float;
    var page:Int;
    var chnl:Int;
}

typedef Kerning = {
    var first:Float;
    var second:Float;
    var amount:Float;
}

typedef Info = {
    var face:String;
    var size:Float;
    var bold:Int;
    var italic:Int;
    var charset:String;
    var unicode:Int;
    var stretchH:Float;
    var smooth:Int;
    var aa:Int;
    var padding:Array<Float>;
    var spacing:Array<Float>;
}

typedef Common = {
    var lineHeight:Float;
    var base:Float;
    var scaleW:Float;
    var scaleH:Float;
    var pages:Int;
    var packed:Int;
    var redChnl:Int;
    var greenChnl:Int;
    var blueChnl:Int;
    var alphaChnl:Int;
}

typedef BMFont = {
    var pages:Array<Page>;
    var chars:Array<Char>;
    var kernings:Array<Kerning>;
    var info:Info;
    var common:Common;
}