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
package mammoth.gl.js;

import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.RenderingContext;
import mammoth.utilities.Colour;

@:allow(mammoth.Mammoth)
class Graphics {
    public var context:RenderingContext;

    private var halfFloat:Dynamic;
    private var depthTexture:Dynamic;
    private var anisotropicFilter:Dynamic;
    private var drawBuffers:Dynamic;

    private var width(get, never):Float;
    private inline function get_width():Float return context.drawingBufferWidth;

    private var height(get, never):Float;
    private inline function get_height():Float return context.drawingBufferHeight;

    private var aspectRatio(get, never):Float;
    private inline function get_aspectRatio():Float
        return (context.canvas.clientWidth / context.canvas.clientHeight);

    private function new() {}

    private function init() {
        // create our canvas
        var canvas:CanvasElement = Browser.document.createCanvasElement();
        context = canvas.getContextWebGL({
            alpha: false,
            antialias: false,
            depth: true,
            premultipliedAlpha: false,
            preserveDrawingBuffer: true,
            stencil: true,
        });

        // add the GL extensions
        if(context != null) {
            //context.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
            context.getExtension("OES_texture_float");
            context.getExtension("OES_texture_float_linear");
            halfFloat = context.getExtension("OES_texture_half_float");
            context.getExtension("OES_texture_half_float_linear");
            depthTexture = context.getExtension("WEBGL_depth_texture");
            context.getExtension("EXT_shader_texture_lod");
            context.getExtension("OES_standard_derivatives");
            anisotropicFilter = context.getExtension("EXT_texture_filter_anisotropic");
            if(anisotropicFilter == null)
                anisotropicFilter = context.getExtension("WEBKIT_EXT_texture_filter_anisotropic");
            drawBuffers = context.getExtension("WEBGL_draw_buffers");
        }

        // add the canvas to the body
        Browser.document.body.appendChild(canvas);
    }

    public function checkWindowSize() {
        var displayWidth:Int  = Math.floor(context.canvas.clientWidth  * Browser.window.devicePixelRatio);
        var displayHeight:Int = Math.floor(context.canvas.clientHeight * Browser.window.devicePixelRatio);

        if(context.canvas.width != displayWidth || context.canvas.height != displayHeight) {
            context.canvas.width = displayWidth;
            context.canvas.height = displayHeight;

            Log.debug('Resized canvas to ${displayWidth}x${displayHeight}');
            Log.debug('Mammoth size: ${width}x${height}');
        }
    }

    inline public function clearColour(colour:Colour)
        context.clearColor(colour.r, colour.g, colour.b, colour.a);
}