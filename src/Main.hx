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
package;

import mammoth.Mammoth;
import mammoth.AssetList;
import mammoth.Log;
import mammoth.Component;

class Main {
    public static function main() {
        Mammoth.init(onReady);
    }

    private static function onReady():Void {
        Log.info("Loading...");
        Mammoth.assets.loadJSON('assets/demo.json')
            .then(function(data:Dynamic) {
                mammoth.filetypes.MammothJSON.load('assets', data, function(type:String, data:Dynamic):Component {
                    return switch(type) {
                        case 'Bounce': {
                            var c:components.Bounce = new components.Bounce();
                            c.x = Reflect.field(data, 'x');
                            c.vx = Reflect.field(data, 'vx');
                            c.xMax = Reflect.field(data, 'xMax');
                            c.xMin = Reflect.field(data, 'xMin');
                            c;
                        }
                        case 'MouseLook': {
                            var c:components.MouseLook = new components.MouseLook();
                            c.direction = Reflect.field(data, 'direction');
                            c.elevation = Reflect.field(data, 'elevation');
                            c.sensitivity = Reflect.field(data, 'sensitivity');
                            c.smoothing = Reflect.field(data, 'smoothing');
                            c;
                        }
                        case 'Spin': {
                            var c:components.Spin = new components.Spin();
                            c.angle = Reflect.field(data, 'angle');
                            c.speed = Reflect.field(data, 'speed');
                            c;
                        }
                        case _: null;
                    }
                });
                Log.info("Done!");

                Mammoth.updatePhase.add(new systems.BounceSystem());
                Mammoth.updatePhase.add(new systems.SpinSystem());
                Mammoth.updatePhase.add(new systems.MouseLookSystem());

                Mammoth.begin();
            })
            .catchError(function(e:Dynamic) {
                Log.error(e);
            });
        Mammoth.begin();
    }
}
