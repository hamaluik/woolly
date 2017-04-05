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

import mammoth.gl.Texture;
import mammoth.gl.types.TTextureFilter;
import mammoth.gl.types.TTextureWrap;

class Texture2D {
    public var tex:Texture;
    public var minFilter:TTextureFilter;
    public var magFilter:TTextureFilter;
    public var wrapMode:TTextureWrap;

    public function new() {
    }

    public static function fromURI(uri:String, minFilter:TTextureFilter = TTextureFilter.Nearest, magFilter:TTextureFilter = TTextureFilter.Nearest, wrapMode:TTextureWrap = TTextureWrap.Repeat):Texture2D {
        var texture2D:Texture2D = new Texture2D();
        texture2D.minFilter = minFilter;
        texture2D.magFilter = magFilter;
        texture2D.wrapMode = wrapMode;
        texture2D.tex = Mammoth.gl.loadTexture(uri, minFilter, magFilter, wrapMode);
        return texture2D;
    }
}