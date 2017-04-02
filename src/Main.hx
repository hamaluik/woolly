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

class Main {
    public static function main() {
        Mammoth.init(onReady);
    }

    private static function onReady():Void {
        Log.info("Loading...");
        Mammoth.assets.loadJSON(AssetList.asset___iso__json)
            .then(function(data:Dynamic) {
                mammoth.filetypes.MammothJSON.load(data);
                Log.info("Done!");

                // print all the objects
                for(entity in Mammoth.engine.entities()) {
                    var t:mammoth.components.Transform = entity.get(mammoth.components.Transform);
                    if(t != null) {
                        if(t.name == 'Cube') {
                            mammoth.Log.info('Adding spin to "Cube"!');
                            var spin:components.Spin = new components.Spin();
                            spin.angle = 0;
                            spin.speed = Math.PI / 10;
                            entity.add(spin);
                        }
                    }
                }

                Mammoth.updatePhase.add(new systems.SpinSystem());

                Mammoth.begin();
            })
            .catchError(function(e:Dynamic) {
                Log.error(e);
            });
        Mammoth.begin();
    }
}
