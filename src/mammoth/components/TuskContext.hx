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

import edge.IComponent;
import mammoth.types.Material;
import mammoth.defaults.Materials;
import mammoth.gl.Buffer;
import mammoth.types.MaterialData;
import mammoth.gl.GL;

class TuskContext implements IComponent {
    public var material:Material = null;
    public var buffer:Buffer = null;
    public var data:MaterialData = null;

    public function new() {
        // TODO: somewhere else!
        material = Materials.tusk();
        buffer = Mammoth.gl.createBuffer();
        data = new MaterialData();

        var fontTexture = Mammoth.gl.createTexture();
        Mammoth.gl.bindTexture(GL.TEXTURE_2D, fontTexture);
        Mammoth.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE,
              new js.html.Uint8Array([255, 255, 255, 255]));
        data.textures.push(fontTexture);
        Mammoth.gl.bindTexture(GL.TEXTURE_2D, null);

        // load the image asynchronously
        var fontImage:js.html.ImageElement = js.Browser.window.document.createImageElement();
        fontImage.addEventListener('load', function() {
            Mammoth.gl.bindTexture(GL.TEXTURE_2D, fontTexture);
            //Mammoth.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
            //Mammoth.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, fontImage);
            Mammoth.gl.context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, fontImage);
        });
        fontImage.src = tusk.Tusk.fontTextureSrc;
    }
}