package tusk;

import haxe.ds.IntMap;
import tusk.macros.FileContents;

#if js
typedef FloatArray = js.html.Float32Array;
#else
typedef FloatArray = haxe.io.Float32Array;
#end

class Tusk {
    public static var vertexShaderSrc(default, null):String = FileContents.contents('tusk/assets/vertex.glsl');
    public static var fragmentShaderSrc(default, null):String = FileContents.contents('tusk/assets/fragment.glsl');
    public static var fontTextureSrc(default, null):String = 'data:image/png;base64,' + FileContents.base64contents('tusk/assets/coderscrux.png');
    public static var fontSrc(default, null):String = FileContents.contents('tusk/assets/coderscrux.json');

    public static var draw(default, null):Draw = new Draw();
    public static var controls(default, null):IntMap<Control> = new IntMap<Control>();

    private function new() {}

    private static var mousePos:Vec2 = new Vec2();
    private static var mousePressed:Bool = false;
    private static var mouseDown:Bool = false;
    private static var mouseReleased:Bool = false;

    private static var nextPos:Vec2 = new Vec2();
    private static var currentWidth:Float = 0;

    public static function updateInput(mx:Float, my:Float, mouseDown:Bool):Void {
        mousePos.set(mx, my);

        Tusk.mousePressed = mouseDown && !Tusk.mouseDown;
        Tusk.mouseReleased = !mouseDown && Tusk.mouseDown;
        Tusk.mouseDown = mouseDown;
    }

    private inline static function getControl(uuid:Int):Control {
        // get or create the control
        if(!controls.exists(uuid))
            controls.set(uuid, new Control());
        return controls.get(uuid);
    }

    private static function updateInputState(control:Control, x:Float, y:Float, w:Float, h:Float):Void {
        // skip all this logic if we're disabled
        if(control.state == InputState.Disabled) return;
        
        // detect hovers
        var mousedOver:Bool = mousePos.x >= x && mousePos.x <= x + w && mousePos.y >= y && mousePos.y <= y + h;
        if(mousedOver) {
            if(control.state == InputState.Normal) {
                control.state = InputState.Hovered;
            }
            if(Tusk.mousePressed) {
                control.state = InputState.Pressed;
            }
        }
        else if(control.state == InputState.Hovered) {
            control.state = InputState.Normal;
        }

        // detect clicks
        control.clicked = false;
        if(control.state == InputState.Pressed && Tusk.mouseReleased) {
            control.clicked = true;

            if(mousedOver) {
                control.state = InputState.Hovered;
            }
            else {
                control.state = InputState.Normal;
            }
        }
    }

    public static function window(uuid:Int, x:Float, y:Float, w:Float, h:Float, title:String):Void {
        // TODO
        var control:Control = getControl(uuid);

        nextPos.set(x + 2, y + 2 + TuskConfig.window_headerHeight);
        currentWidth = w - 4;
        draw.window(x, y, w, h, title);
    }

    public static function label(text:String):Void {
        draw.text(nextPos.x, nextPos.y, text);
        nextPos.y += draw.font.lineHeight + 4;
    }

    public static function button(uuid:Int, label:String):Bool {
        var control:Control = getControl(uuid);
        updateInputState(control, nextPos.x, nextPos.y, currentWidth, draw.font.lineHeight + 4);
        draw.button(nextPos.x, nextPos.y, currentWidth, draw.font.lineHeight + 4, label, control.state);
        nextPos.y += draw.font.lineHeight + 4 + 4;
        return control.clicked;
    }
}