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

import mammoth.gl.AttributeLocation;
import mammoth.gl.types.TVertexAttribute;

@:allow(mammoth.types.Material)
class MaterialAttribute {
    public var name(default, null):String;
    public var type(default, null):TVertexAttribute;

    public var location(default, null):AttributeLocation;

    public function new(name:String, type:TVertexAttribute) {
        this.name = name;
        this.type = type;
    }
}