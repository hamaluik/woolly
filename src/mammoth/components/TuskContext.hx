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
package mammoth.components;

import mammoth.gl.types.TTextureWrap;
import mammoth.gl.types.TTextureFilter;
import edge.IComponent;
import mammoth.types.Material;
import mammoth.defaults.Materials;
import mammoth.gl.Buffer;
import mammoth.types.MaterialData;
import mammoth.types.Texture2D;

class TuskContext implements IComponent {
    public var material:Material = null;
    public var buffer:Buffer = null;
    public var data:MaterialData = null;

    public function new() {
        // TODO: somewhere else?
        material = Materials.tusk();
        buffer = Mammoth.gl.createBuffer();
        data = new MaterialData();
        data.textures.push(Texture2D.fromURI(tusk.Tusk.fontTextureSrc, TTextureFilter.Nearest, TTextureFilter.Nearest, TTextureWrap.Clamp));
    }
}