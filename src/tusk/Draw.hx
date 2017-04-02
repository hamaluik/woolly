package tusk;

import tusk.text.Font;

class Draw {
    public var screenWidth(default, set):Float = 1;
    private function set_screenWidth(w:Float):Float {
        if(w != screenWidth) vpDirty = true;
        return screenWidth = w;
    }

    public var screenHeight(default, set):Float = 1;
    private function set_screenHeight(h:Float):Float {
        if(h != screenHeight) vpDirty = true;
        return screenHeight = h;
    }

    private var vpDirty:Bool = true;
    public var vpMatrix(get, null):Mat4 = Mat4.identity(new Mat4());
    private function get_vpMatrix():Mat4 {
        if(vpDirty) {
            GLM.orthographic(0, screenWidth, screenHeight, 0, 0, 1, vpMatrix);
            vpDirty = false;
        }
        return vpMatrix;
    }

    public var buffer(default, null):FloatArray = new FloatArray(8 * 6 * 32);
    public var numVertices(default, null):Int = 0;

    public var font:Font;

    public function new() {
        font = Font.fromFontSrc(Tusk.fontSrc);
    }

    public function newFrame():Void {
        numVertices = 0;
    }

    private function addVertex(x:Float, y:Float, u:Float, v:Float, colour:Vec4):Void {
        var i:Int = numVertices * 8;
        buffer[i + 0] = x;
        buffer[i + 1] = y;
        buffer[i + 2] = u;
        buffer[i + 3] = v;
        buffer[i + 4] = colour.r;
        buffer[i + 5] = colour.g;
        buffer[i + 6] = colour.b;
        buffer[i + 7] = colour.a;
        numVertices++;

        if((numVertices * 8) >= buffer.length) {
            // resize the buffer
            var newBuffer:FloatArray = new FloatArray(buffer.length + (8 * 6 * 32));
            for(i in 0...buffer.length)
                newBuffer[i] = buffer[i];
            buffer = newBuffer;
        }
    }

    public function text(x:Float, y:Float, text:String, ?colour:Vec4):Void {
        if(colour == null) colour = TuskConfig.text_normal;
        font.print(x, y + font.ascent, text, function(_x:Float, _y:Float, _u:Float, _v:Float, ?charColour:Vec4):Void {
            addVertex(_x, _y, _u, _v, charColour == null ? colour : charColour);
        });
    }

    public function window(x:Float, y:Float, w:Float, h:Float, title:String):Void {
        // draw the body
        addVertex(x + 0, y + TuskConfig.window_headerHeight, 1, 1, TuskConfig.window_bodyColour);
        addVertex(x + w, y + TuskConfig.window_headerHeight, 1, 1, TuskConfig.window_bodyColour);
        addVertex(x + 0, y + h, 1, 1, TuskConfig.window_bodyColour);

        addVertex(x + 0, y + h, 1, 1, TuskConfig.window_bodyColour);
        addVertex(x + w, y + TuskConfig.window_headerHeight, 1, 1, TuskConfig.window_bodyColour);
        addVertex(x + w, y + h, 1, 1, TuskConfig.window_bodyColour);
        
        // draw the header
        addVertex(x + 0, y + 0, 1, 1, TuskConfig.window_headerColour);
        addVertex(x + w, y + 0, 1, 1, TuskConfig.window_headerColour);
        addVertex(x + 0, y + TuskConfig.window_headerHeight, 1, 1, TuskConfig.window_headerColour);

        addVertex(x + 0, y + TuskConfig.window_headerHeight, 1, 1, TuskConfig.window_headerColour);
        addVertex(x + w, y + 0, 1, 1, TuskConfig.window_headerColour);
        addVertex(x + w, y + TuskConfig.window_headerHeight, 1, 1, TuskConfig.window_headerColour);

        // draw the title over the header
        text(
            Math.ffloor(x + ((w - font.textWidth(title)) * 0.5)),
            Math.ffloor(y + (TuskConfig.window_headerHeight - font.lineHeight) * 0.5),
            title, TuskConfig.window_headerTextColour);
    }

    public function button(x:Float, y:Float, w:Float, h:Float, label:String, state:InputState):Void {
        var buttonColour:Vec4 = switch(state) {
            case InputState.Normal: TuskConfig.button_normalColour;
            case InputState.Hovered: TuskConfig.button_hoveredColour;
            case InputState.Pressed: TuskConfig.button_pressedColour;
            case InputState.Disabled: TuskConfig.button_disabledColour;
        }

        // draw the body
        addVertex(x + 0, y + 0, 1, 1, buttonColour);
        addVertex(x + w, y + 0, 1, 1, buttonColour);
        addVertex(x + 0, y + h, 1, 1, buttonColour);

        addVertex(x + 0, y + h, 1, 1, buttonColour);
        addVertex(x + w, y + 0, 1, 1, buttonColour);
        addVertex(x + w, y + h, 1, 1, buttonColour);

        // draw the label
        text(Math.ffloor(x + ((w - font.textWidth(label)) * 0.5)), Math.ffloor(y + (h - font.lineHeight) * 0.5), label);
    }
}