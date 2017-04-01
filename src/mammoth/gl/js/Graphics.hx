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

import haxe.ds.StringMap;

import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.RenderingContext;

import mammoth.platform.ArrayBufferView;
import mammoth.platform.Float32Array;
import mammoth.platform.Int32Array;
import mammoth.utilities.Colour;

@:allow(mammoth.Mammoth)
class Graphics {
    public var context:RenderingContext;

    /*private var halfFloat:Dynamic;
    private var depthTexture:Dynamic;
    private var anisotropicFilter:Dynamic;
    private var drawBuffers:Dynamic;*/

    private var width(get, never):Float;
    private inline function get_width():Float return context.drawingBufferWidth;

    private var height(get, never):Float;
    private inline function get_height():Float return context.drawingBufferHeight;

    private var aspectRatio(get, never):Float;
    private inline function get_aspectRatio():Float
        return (context.canvas.clientWidth / context.canvas.clientHeight);

	private var extensions:StringMap<Dynamic> = new StringMap<Dynamic>();

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
            extensions.set('texture_float', context.getExtension("OES_texture_float"));
            extensions.set('texture_float_linear', context.getExtension("OES_texture_float_linear"));
            extensions.set('texture_half_float', context.getExtension("OES_texture_half_float"));
            extensions.set('texture_half_float_linear', context.getExtension("OES_texture_half_float_linear"));
			extensions.set('frag_depth', context.getExtension("EXT_frag_depth"));
            extensions.set('depth_texture', context.getExtension("WEBGL_depth_texture"));
            extensions.set('shader_texture_lod', context.getExtension("EXT_shader_texture_lod"));
            extensions.set('standard_derivatives', context.getExtension("OES_standard_derivatives"));
            extensions.set('texture_filter_anisotropic', context.getExtension("EXT_texture_filter_anisotropic"));
            if(extensions.get('texture_filter_anisotropic') == null)
                extensions.set('texture_filter_anisotropic', context.getExtension("WEBKIT_EXT_texture_filter_anisotropic"));
            extensions.set('draw_buffers', context.getExtension("WEBGL_draw_buffers"));
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
        }
    }

	public inline function getExtension(name:String):Dynamic return context.getExtension(name);
	public inline function activeTexture(texture:Int):Void context.activeTexture(texture);
	public inline function attachShader(program:Program, shader:Shader):Void context.attachShader(program, shader);
	public inline function bindAttribLocation(program:Program, index:Int, name:String):Void context.bindAttribLocation(program, index, name);
	public inline function bindBuffer(target:Int, buffer:Buffer):Void context.bindBuffer(target, buffer);
	public inline function bindFramebuffer(target:Int, framebuffer:Framebuffer):Void context.bindFramebuffer(target, framebuffer);
	public inline function bindRenderbuffer(target:Int, renderbuffer:Renderbuffer):Void context.bindRenderbuffer(target, renderbuffer);
	public inline function bindTexture(target:Int, texture:Texture):Void context.bindTexture(target, texture);
	public inline function blendColor(colour:Colour):Void context.blendColor(colour.r, colour.g, colour.b, colour.a);
	public inline function blendEquation(mode:Int):Void context.blendEquation(mode);
	public inline function blendEquationSeparate(modeRGB:Int, modeAlpha:Int):Void context.blendEquationSeparate(modeRGB, modeAlpha);
	public inline function blendFunc(sfactor:Int, dfactor:Int):Void context.blendFunc(sfactor, dfactor);
	public inline function blendFuncSeparate(srcRGB:Int, dstRGB:Int, srcAlpha:Int, dstAlpha:Int):Void context.blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
	/*@:overload(function(target:Int, size:Int, usage:Int):Void {})
	// @:overload(function(target:Int, data:js.html.ArrayBufferView, usage:Int):Void {})
	// @:overload(function(target:Int, data:js.html.ArrayBuffer, usage:Int):Void {})*/
	public inline function bufferData(target:Int, data:Dynamic, usage:Int):Void context.bufferData(target, data, usage);
	/*@:overload(function(target:Int, offset:Int, data:js.html.ArrayBufferView):Void {})
	// @:overload(function(target:Int, offset:Int, data:js.html.ArrayBuffer):Void {})*/
	// public inline function bufferSubData(target:Int, offset:Int, data:Dynamic):Void context.bufferSubData(target, offset, data);
	// public inline function checkFramebufferStatus(target:Int):Int return context.checkFrameBufferStatus(target);
	public inline function clear(mask:Int):Void context.clear(mask);
	public inline function clearColor(colour:Colour):Void context.clearColor(colour.r, colour.g, colour.b, colour.a);
	// public inline function clearDepth(depth:Float):Void;
	// public inline function clearStencil(s:Int):Void;
	// public inline function colorMask(red:Bool, green:Bool, blue:Bool, alpha:Bool):Void;
	public inline function compileShader(shader:Shader):Void context.compileShader(shader);
	// public inline function compressedTexImage2D(target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, data:js.html.ArrayBufferView):Void;
	// public inline function compressedTexSubImage2D(target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, data:js.html.ArrayBufferView):Void;
	// public inline function copyTexImage2D(target:Int, level:Int, internalformat:Int, x:Int, y:Int, width:Int, height:Int, border:Int):Void;
	// public inline function copyTexSubImage2D(target:Int, level:Int, xoffset:Int, yoffset:Int, x:Int, y:Int, width:Int, height:Int):Void;
	public inline function createBuffer():Buffer return context.createBuffer();
	public inline function createFramebuffer():Framebuffer return context.createFramebuffer();
	public inline function createProgram():Program return context.createProgram();
	public inline function createRenderbuffer():Renderbuffer return context.createRenderbuffer();
	public inline function createShader(type:Int):Shader return context.createShader(type);
	public inline function createTexture():Texture return context.createTexture();
	public inline function cullFace(mode:Int):Void context.cullFace(mode);
	public inline function deleteBuffer(buffer:Buffer):Void context.deleteBuffer(buffer);
	public inline function deleteFramebuffer(framebuffer:Framebuffer):Void context.deleteFramebuffer(framebuffer);
	public inline function deleteProgram(program:Program):Void context.deleteProgram(program);
	public inline function deleteRenderbuffer(renderbuffer:Renderbuffer):Void context.deleteRenderbuffer(renderbuffer);
	public inline function deleteShader(shader:Shader):Void context.deleteShader(shader);
	public inline function deleteTexture(texture:Texture):Void context.deleteTexture(texture);
	public inline function depthFunc(func:Int):Void context.depthFunc(func);
	public inline function depthMask(flag:Bool):Void return context.depthMask(flag);
	// public inline function depthRange(zNear:Float, zFar:Float):Void;
	// public inline function detachShader(program:Program, shader:Shader):Void;
	public inline function disable(cap:Int):Void context.disable(cap);
	// public inline function disableVertexAttribArray(index:Int):Void;
	public inline function drawArrays(mode:Int, first:Int, count:Int):Void context.drawArrays(mode, first, count);
	public inline function drawElements(mode:Int, count:Int, type:Int, offset:Int):Void context.drawElements(mode, count, type, offset);
	public inline function enable(cap:Int):Void context.enable(cap);
	public inline function enableVertexAttribArray(index:Int):Void context.enableVertexAttribArray(index);
	public inline function finish():Void context.finish();
	public inline function flush():Void context.flush();
	public inline function framebufferRenderbuffer(target:Int, attachment:Int, renderbuffertarget:Int, renderbuffer:Renderbuffer):Void
		context.framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
	public inline function framebufferTexture2D(target:Int, attachment:Int, textarget:Int, texture:Texture, level:Int):Void
		context.framebufferTexture2D(target, attachment, textarget, texture, level);
	public inline function frontFace(mode:Int):Void context.frontFace(mode);
	public inline function generateMipmap(target:Int):Void context.generateMipmap(target);
	// public inline function getActiveAttrib(program:Program, index:Int):ActiveInfo;
	// public inline function getActiveUniform(program:Program, index:Int):ActiveInfo;
	// public inline function getAttachedShaders(program:Program):Array<Shader>;
	public inline function getAttribLocation(program:Program, name:String):Int return context.getAttribLocation(program, name);
	// public inline function getBufferParameter(target:Int, pname:Int):Dynamic;
	// public inline function getParameter(pname:Int):Dynamic;
	// public inline function getError():Int;
	// public inline function getFramebufferAttachmentParameter(target:Int, attachment:Int, pname:Int):Dynamic;
	public inline function getProgramParameter(program:Program, pname:Int):Dynamic return context.getProgramParameter(program, pname);
	public inline function getProgramInfoLog(program:Program):String return context.getProgramInfoLog(program);
	// public inline function getRenderbufferParameter(target:Int, pname:Int):Dynamic;
	public inline function getShaderParameter(shader:Shader, pname:Int):Dynamic return context.getShaderParameter(shader, pname);
	// public inline function getShaderPrecisionFormat(shadertype:Int, precisiontype:Int):ShaderPrecisionFormat;
	public inline function getShaderInfoLog(shader:Shader):String return context.getShaderInfoLog(shader);
	// public inline function getShaderSource(shader:Shader):String;
	// public inline function getTexParameter(target:Int, pname:Int):Dynamic;
	public inline function getUniform(program:Program, location:UniformLocation):Dynamic return context.getUniform(program, location);
	public inline function getUniformLocation(program:Program, name:String):UniformLocation return context.getUniformLocation(program, name);
	public inline function getVertexAttrib(index:Int, pname:Int):Dynamic return context.getVertexAttrib(index, pname);
	// public inline function getVertexAttribOffset(index:Int, pname:Int):Int;
	// public inline function hint(target:Int, mode:Int):Void;
	// public inline function isBuffer(buffer:Buffer):Bool;
	// public inline function isEnabled(cap:Int):Bool;
	// public inline function isFramebuffer(framebuffer:Framebuffer):Bool;
	// public inline function isProgram(program:Program):Bool;
	// public inline function isRenderbuffer(renderbuffer:Renderbuffer):Bool;
	// public inline function isShader(shader:Shader):Bool;
	// public inline function isTexture(texture:Texture):Bool;
	// public inline function lineWidth(width:Float):Void;
	public inline function linkProgram(program:Program):Void return context.linkProgram(program);
	public inline function pixelStorei(pname:Int, param:Int):Void context.pixelStorei(pname, param);
	// public inline function polygonOffset(factor:Float, units:Float):Void;
	// public inline function readPixels(x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, pixels:js.html.ArrayBufferView):Void;
	// public inline function renderbufferStorage(target:Int, internalformat:Int, width:Int, height:Int):Void;
	// public inline function sampleCoverage(value:Float, invert:Bool):Void;
	public inline function scissor(x:Int, y:Int, width:Int, height:Int):Void context.scissor(x, y, width, height);
	public inline function shaderSource(shader:Shader, source:String):Void context.shaderSource(shader, source);
	// public inline function stencilFunc(func:Int, ref:Int, mask:Int):Void;
	// public inline function stencilFuncSeparate(face:Int, func:Int, ref:Int, mask:Int):Void;
	// public inline function stencilMask(mask:Int):Void;
	// public inline function stencilMaskSeparate(face:Int, mask:Int):Void;
	// public inline function stencilOp(fail:Int, zfail:Int, zpass:Int):Void;
	// public inline function stencilOpSeparate(face:Int, fail:Int, zfail:Int, zpass:Int):Void;
	// @:overload(function(target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:js.html.ArrayBufferView):Void {})
	// @:overload(function(target:Int, level:Int, internalformat:Int, format:Int, type:Int, pixels:js.html.ImageData):Void {})
	// @:overload(function(target:Int, level:Int, internalformat:Int, format:Int, type:Int, image:js.html.ImageElement):Void {})
	// @:overload(function(target:Int, level:Int, internalformat:Int, format:Int, type:Int, canvas:js.html.CanvasElement):Void {})
	// public inline function texImage2D(target:Int, level:Int, internalformat:Int, format:Int, type:Int, video:js.html.VideoElement):Void;
	public inline function texImage2D(target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:ArrayBufferView):Void
		context.texImage2D(target, level, internalformat, width, height, border, format, type, pixels);
	// public inline function texParameterf(target:Int, pname:Int, param:Float):Void;
	public inline function texParameteri(target:Int, pname:Int, param:Int):Void context.texParameteri(target, pname, param);
	// @:overload(function(target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:js.html.ArrayBufferView):Void {})
	// @:overload(function(target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, pixels:js.html.ImageData):Void {})
	// @:overload(function(target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, image:js.html.ImageElement):Void {})
	// @:overload(function(target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, canvas:js.html.CanvasElement):Void {})
	// public inline function texSubImage2D(target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, video:js.html.VideoElement):Void;
	public inline function uniform1f(location:UniformLocation, x:Float):Void context.uniform1f(location, x);
    public inline function uniform1fv(location:UniformLocation, v:Float32Array) context.uniform1fv(location, v);
	public inline function uniform1i(location:UniformLocation, x:Int):Void context.uniform1i(location, x);
    public inline function uniform1iv(location:UniformLocation, v:Int32Array) context.uniform1iv(location, v);
	public inline function uniform2f(location:UniformLocation, x:Float, y:Float):Void context.uniform2f(location, x, y);
	public inline function uniform2fv(location:UniformLocation, v:Float32Array):Void context.uniform2fv(location, v);
    public inline function uniform2i(location:UniformLocation, x:Int, y:Int):Void context.uniform2i(location, x, y);
    public inline function uniform2iv(location:UniformLocation, v:Int32Array):Void context.uniform2iv(location, v);
    public inline function uniform3f(location:UniformLocation, x:Float, y:Float, z:Float):Void context.uniform3f(location, x, y, z);
    public inline function uniform3fv(location:UniformLocation, v:Float32Array):Void context.uniform3fv(location, v);
    public inline function uniform3i(location:UniformLocation, x:Int, y:Int, z:Int):Void context.uniform3i(location, x, y, z);
    public inline function uniform3iv(location:UniformLocation, v:Int32Array):Void context.uniform3iv(location, v);
    public inline function uniform4f(location:UniformLocation, x:Float, y:Float, z:Float, w:Float):Void context.uniform4f(location, x, y, z, w);
    public inline function uniform4fv(location:UniformLocation, v:Float32Array):Void context.uniform4fv(location, v);
    public inline function uniform4i(location:UniformLocation, x:Int, y:Int, z:Int, w:Int):Void context.uniform4i(location, x, y, z, w);
    public inline function uniform4iv(location:UniformLocation, v:Int32Array):Void context.uniform4iv(location, v);
    public inline function uniformMatrix2fv(location:UniformLocation, v:Float32Array):Void context.uniformMatrix2fv(location, false, v);
    public inline function uniformMatrix3fv(location:UniformLocation, v:Float32Array):Void context.uniformMatrix3fv(location, false, v);
    public inline function uniformMatrix4fv(location:UniformLocation, v:Float32Array):Void context.uniformMatrix4fv(location, false, v);
	public inline function useProgram(program:Program):Void return context.useProgram(program);
	// public inline function validateProgram(program:Program):Void;
	// public inline function vertexAttrib1f(indx:Int, x:Float):Void;
	// @:overload(function(indx:Int, values:js.html.Float32Array):Void {})
	// public inline function vertexAttrib1fv(indx:Int, values:Array<Float>):Void;
	// public inline function vertexAttrib2f(indx:Int, x:Float, y:Float):Void;
	// @:overload(function(indx:Int, values:js.html.Float32Array):Void {})
	// public inline function vertexAttrib2fv(indx:Int, values:Array<Float>):Void;
	// public inline function vertexAttrib3f(indx:Int, x:Float, y:Float, z:Float):Void;
	// @:overload(function(indx:Int, values:js.html.Float32Array):Void {})
	// public inline function vertexAttrib3fv(indx:Int, values:Array<Float>):Void;
	// public inline function vertexAttrib4f(indx:Int, x:Float, y:Float, z:Float, w:Float):Void;
	// @:overload(function(indx:Int, values:js.html.Float32Array):Void {})
	// public inline function vertexAttrib4fv(indx:Int, values:Array<Float>):Void;
	public inline function vertexAttribPointer(indx:Int, size:Int, type:Int, normalized:Bool, stride:Int, offset:Int):Void context.vertexAttribPointer(indx, size, type, normalized, stride, offset);
	public inline function viewport(x:Int, y:Int, width:Int, height:Int):Void context.viewport(x, y, width, height);
}