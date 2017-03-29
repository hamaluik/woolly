package tusk;

import haxe.macro.Context;
import haxe.macro.Expr;

class Control {
    private static var i:Int = 0;
    macro public static function uuid():ExprOf<Int> {
        return macro $v{i++};
    }

    public var clicked:Bool = false;
    public var state:InputState = InputState.Normal;

    public function new() {}
}