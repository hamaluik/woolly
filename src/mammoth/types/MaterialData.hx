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
package mammoth.types;

import haxe.ds.StringMap;
import mammoth.gl.types.TUniformData;
import mammoth.gl.Texture;

class MaterialData {
    public var uniformValues(default, null):StringMap<TUniformData>;
    public var textures(default, null):Array<Texture>;

    public function new() {
        uniformValues = new StringMap<TUniformData>();
        textures = new Array<Texture>();
    }
}