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

import edge.Engine;
import edge.Phase;
import mammoth.gl.Graphics;
import mammoth.platform.Assets;
import mammoth.Resources;
import mammoth.platform.Input;
import mammoth.platform.Timing;
import mammoth.debug.DebugView;
import tusk.Tusk;

@:expose
class Mammoth {
	// parts of our system
    public static var engine:Engine;
    public static var preUpdatePhase:Phase;
    public static var updatePhase:Phase;
    public static var postUpdatePhase:Phase;
    public static var renderPhase:Phase;

    public static var timing:Timing = new Timing();
    public static var gl:Graphics = new Graphics();
    public static var assets:Assets = new Assets();
    public static var resources:Resources = new Resources();
    public static var input:Input = new Input();
    public static var stats:Stats = new Stats();
    private static var debugView:DebugView;

    // public timing variables
    public static var time(get, never):Float;
    private inline static function get_time():Float return timing.time;
    public static var alpha(get, never):Float;
    private inline static function get_alpha():Float return timing.alpha;

    // public size variables
    public static var width(get, never):Float;
    private inline static function get_width():Float return gl.width;
    public static var height(get, never):Float;
    private inline static function get_height():Float return gl.height;
    public static var aspectRatio(get, never):Float;
    private inline static function get_aspectRatio():Float return gl.aspectRatio;

    static macro function getDefine(key:String):Expr return macro $v{Context.definedValue(key)};
    static macro function isDefined(key:String):Expr return macro $v{Context.defined(key)};
    
    public static function init(?onReady:Void->Void, updateRate:Float=60):Void {
        // initialize our subsystems
        gl.init();
        input.init();
        debugView = new DebugView();

        // calculate the clock period
        timing.dt = 1 / updateRate;

        // initialize the ECS
        engine = new Engine();
        preUpdatePhase = engine.createPhase();
        updatePhase = engine.createPhase();
        postUpdatePhase = engine.createPhase();
        renderPhase = engine.createPhase();

        // initialize our pre- and post- systems
        preUpdatePhase.add(new mammoth.systems.PreTransformSystem());

        // initialize our rendering
        renderPhase.add(new mammoth.systems.ModelMatrixSystem());
        renderPhase.add(new mammoth.systems.CameraSystem());
        renderPhase.add(new mammoth.systems.DirectionalLightSystem());
        renderPhase.add(new mammoth.systems.DirectionalShadowSystem());
        renderPhase.add(new mammoth.systems.RenderSystem());

        if(onReady != null)
            onReady();
    }

    public static function begin() {
        timing.onUpdate = onUpdate;
        timing.onRender = onRender;
        timing.start();
    }

    public static function end() {
        timing.stop();
    }

    private static function onUpdate(dt:Float):Void {
        Tusk.draw.newFrame();
        Tusk.updateInput(input.mouseX, input.mouseY, input.mouseDown);

        preUpdatePhase.update(dt);
        updatePhase.update(dt);
        postUpdatePhase.update(dt);

        Tusk.window(tusk.Control.uuid(), Mammoth.width - 160, 10, 150, 75, 'Stats');
        Tusk.label('Render t: ' + Math.fround(stats.renderTime * 1000 * 10) / 10 + 'ms');
        Tusk.label('FPS: ' + Math.fround(stats.fps * 10) / 10);
        Tusk.label('Draw calls: ' + stats.drawCalls);
        Tusk.label('Triangles: ' + stats.triangles);
    }

    private static function onRender(dt:Float, alpha:Float):Void {
        stats.drawCalls = 0;
        stats.triangles = 0;

        stats.startRenderTimer();
        gl.checkWindowSize();
        renderPhase.update(dt);
        stats.endRenderTimer();

        debugView.draw();
    }
}
