package components;

import mammoth.Component;

class MouseLook implements Component {
    public var sensitivity:Float = 1;
    public var smoothing:Float = 3;

    public var elevation:Float = Math.PI / 2;
    public var direction:Float = 0;

    @noExport public var smoothX:Float = 0;
    @noExport public var smoothY:Float = 0;

    public function new() {}
}