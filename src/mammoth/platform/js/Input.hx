package mammoth.platform.js;

import mammoth.Mammoth;
import js.html.MouseEvent;
import js.html.DOMRect;

class Input {
    private var lastMouseX:Float = 0;
    private var lastMouseY:Float = 0;
    public var mouseX(default, null):Float = 0;
    public var mouseY(default, null):Float = 0;
    public var mouseDeltaX(default, null):Float = 0;
    public var mouseDeltaY(default, null):Float = 0;
    public var mouseDown(default, null):Bool = false;
    public var pointerLocked(default, null):Bool = false;

    public function new() {}

    public function init():Void {
        Mammoth.gl.context.canvas.addEventListener('mousemove', updateMousePosition);
        Mammoth.gl.context.canvas.addEventListener('mousedown', updateMouseDown);
        Mammoth.gl.context.canvas.addEventListener('mouseup', updateMouseUp);
        js.Browser.document.addEventListener('pointerlockchange', pointerLockChanged);
    }

    public function lockPointer():Void {
        Mammoth.gl.context.canvas.onclick = requestPointerLock;
    }

    private function requestPointerLock():Void {
        Mammoth.gl.context.canvas.requestPointerLock();
    }

    public function unlockPointer():Void {
        js.Browser.document.exitPointerLock();
    }

    public function poll():Void {
        mouseDeltaX = mouseX - lastMouseX;
        mouseDeltaY = mouseY - lastMouseY;
        lastMouseX = mouseX;
        lastMouseY = mouseY;
    }

    private function updateMousePosition(evt:MouseEvent):Void {
        var rect:DOMRect = Mammoth.gl.context.canvas.getBoundingClientRect();
        if(pointerLocked) {
            mouseX += evt.movementX;
            mouseY += evt.movementY;
        }
        else {
            mouseX = Math.ffloor((evt.clientX - rect.left) / (rect.right - rect.left) * Mammoth.gl.context.canvas.width);
            mouseY = Math.ffloor((evt.clientY - rect.top) / (rect.bottom - rect.top) * Mammoth.gl.context.canvas.height);
        }
        //mouseDeltaX = evt.movementX;
        //mouseDeltaY = evt.movementY;
    }

    private function updateMouseDown(evt:MouseEvent):Void {
        if(evt.button == 0) mouseDown = true;
    }

    private function updateMouseUp(evt:MouseEvent):Void {
        if(evt.button == 0) mouseDown = false;
    }

    private function pointerLockChanged():Void {
        pointerLocked = js.Browser.document.pointerLockElement == Mammoth.gl.context.canvas;
        if(pointerLocked)
            Mammoth.gl.context.canvas.onclick = null;
        else
            Mammoth.gl.context.canvas.onclick = requestPointerLock;
        //Log.debug('Pointer locked: ${pointerLocked}');
    }
}