package mammoth;

import haxe.Timer;

class Stats {
    public var drawCalls:Int = 0;
    public var triangles:Int = 0;

    public var renderTime:Float = 0;
    public var fps(get, never):Float;
    private function get_fps():Float {
        if(Math.abs(renderTime) <= 0.00000001) return -1;
        return 1 / renderTime;
    }

    private var renderFrameCount:Int = 0;
    private var renderStart:Float = 0;
    private var renderEnd:Float = 0;

    public function new() {}

    public function startRenderTimer():Void {
        if(renderFrameCount == 0) {
            renderStart = Timer.stamp();
        }
    }

    public function endRenderTimer():Void {
        renderFrameCount++;
        if(renderFrameCount == 120) {
            renderEnd = Timer.stamp();
            renderTime = (renderEnd - renderStart) / 120;
            renderFrameCount = 0;
        }
    }
}