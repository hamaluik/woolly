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
package mammoth.platform.js;

import js.Browser;

@:allow(mammoth.Mammoth)
class Timing {
    public function new() {}

    private var animationFrameID:Int = 0;
    private var time:Float = 0;
    private var lastTime:Float = 0;
    private var accumulator:Float = 0;

    public var dt(default, null):Float = 1 / 30;
    public var alpha(default, null):Float = 0;

    private var onUpdate:Float->Void;
    private var onRender:Float->Float->Void;

    private function onRenderFrame(ts:Float):Void {
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

    private inline function requestFrame() {
        animationFrameID = Browser.window.requestAnimationFrame(onRenderFrame);
    }

    private function start() {
        requestFrame();
    }

    private function stop() {
        Browser.window.cancelAnimationFrame(animationFrameID);
    }
}