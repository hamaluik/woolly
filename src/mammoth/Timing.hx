/*
 * Copyright (c) 2017 Kenton Hamaluik
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
package mammoth;

import js.Browser;

@:allow(mammoth.Mammoth)
class Timing {
    private static var animationFrameID:Int = 0;
    private static var time:Float = 0;
    private static var lastTime:Float = 0;
    private static var accumulator:Float = 0;

    public static var dt(default, null):Float = 1 / 30;
    public static var alpha(default, null):Float = 0;

    private static var onUpdate:Float->Void;
    private static var onRender:Float->Float->Void;

    private static function onRenderFrame(ts:Float):Void {
        time = ts / 1000;

        // figure out how long since we last ran
        var delta:Float = time - lastTime;
        lastTime = time;

        // updates
        accumulator += delta;
        while(accumulator >= dt) {
            onUpdate(dt);
            accumulator -= dt;
        }

        // renders
        alpha = accumulator / dt;
        onRender(delta, alpha);

        // go on to the next frame
        requestFrame();
    }

    private static inline function requestFrame() {
        animationFrameID = Browser.window.requestAnimationFrame(onRenderFrame);
    }

    private static function start() {
        requestFrame();
    }

    private static function stop() {
        Browser.window.cancelAnimationFrame(animationFrameID);
    }
}