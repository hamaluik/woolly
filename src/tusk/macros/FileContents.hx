package tusk.macros;

import haxe.macro.Expr;
import haxe.io.Path;
import haxe.io.Bytes;
import haxe.crypto.Base64;

class FileContents {
    macro public static function contents(path:String):ExprOf<String> {
        var parts:Array<String> = path.split('/');
        parts.insert(0, 'src');
        #if sys
        parts.insert(0, Sys.getCwd());
        #end
        var assetFilename:String = Path.join(parts);

        var source:String = sys.io.File.getContent(assetFilename);
        return macro $v{source};
    }

    macro public static function base64contents(path:String):ExprOf<String> {
        var parts:Array<String> = path.split('/');
        parts.insert(0, 'src');
        #if sys
        parts.insert(0, Sys.getCwd());
        #end
        var assetFilename:String = Path.join(parts);

        var source:Bytes = sys.io.File.getBytes(assetFilename);
        var srcString:String = Base64.encode(source);
        return macro $v{srcString};
    }
}