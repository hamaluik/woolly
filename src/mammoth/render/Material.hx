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
package mammoth.render;

import haxe.ds.StringMap;
import js.html.webgl.Program;
import js.html.webgl.RenderingContext;
import js.html.webgl.Shader;
import mammoth.debug.Exception;
import mammoth.gl.Graphics;
import mammoth.gl.GL;
import mammoth.defaults.StandardShader;
import mammoth.render.Attribute;
import mammoth.render.CullMode;
import mammoth.render.DepthCompareMode;
import mammoth.render.TUniform;
import mammoth.render.Uniform;

// TODO: generalize for cross-compatibility?
class Material {
	private var context:RenderingContext;
	private var program:Program;
	private var vertexShader:String;
	private var fragmentShader:String;

	public var standardShader:StandardShader;

	public var name(default, null):String;
	public var attributes(default, null):StringMap<Attribute>;
	public var uniforms(default, null):StringMap<Uniform>;

	public var cullMode:CullMode = CullMode.Back;
	public var depthWrite:Bool = true;
	public var depthMode:DepthCompareMode = DepthCompareMode.LessOrEqual;

	public function new(name:String, graphics:Graphics) {
		this.name = name;
		this.context = graphics.context;
		this.attributes = new StringMap<Attribute>();
		this.uniforms = new StringMap<Uniform>();
	}

	private function compileShader(type:TShaderType, source:String):Shader {
		var shader:Shader = context.createShader(cast(type));
		context.shaderSource(shader, source);
		context.compileShader(shader);
		if(!context.getShaderParameter(shader, GL.COMPILE_STATUS)) {
			var info:String = context.getShaderInfoLog(shader);
			var typeStr:String = type == TShaderType.Vertex ? 'Vertex' : 'Fragment';
			throw new Exception(info, true, 'Compile${typeStr}Shader');
		}
		return shader;
	}

	public function setStandardShader(shader:StandardShader):Material {
		standardShader = new StandardShader(shader);
		return this;
	}

	public function setVertexShader(source:String):Material {
		vertexShader = source;
		return this;
	}

	public function setFragmentShader(source:String):Material {
		fragmentShader = source;
		return this;
	}

	public function compile():Material {
		// compile the shaders first
		var vertex:Shader = compileShader(TShaderType.Vertex, standardShader == null ? vertexShader : standardShader.vertex);
		var fragment:Shader = compileShader(TShaderType.Fragment, standardShader == null ? fragmentShader : standardShader.fragment);

		// and link them together
		program = context.createProgram();
		context.attachShader(program, vertex);
		context.attachShader(program, fragment);

		context.linkProgram(program);
		if(!context.getProgramParameter(program, GL.LINK_STATUS)) {
			var info:String = context.getProgramInfoLog(program);
			throw new Exception(info, true, 'LinkProgram');
		}
		return this;
	}

	public function registerAttribute(name:String, attribute:Attribute):Material {
		attributes.set(name, attribute);
		return this;
	}

	public function setUniform(name:String, value:TUniform):Material {
		if(uniforms.exists(name)) {
			uniforms.get(name).value = value;
		}
		else {
			var uniform:Uniform = new Uniform();
			uniform.value = value;
			uniforms.set(name, uniform);
		}
		return this;
	}

	public function setCullMode(cullMode:CullMode):Material {
		this.cullMode = cullMode;
		return this;
	}

	public function bindAttributes() {
		for(name in attributes.keys()) {
			var attribute:Attribute = attributes.get(name);
			if(attribute.bound) continue;
			attribute.location = context.getAttribLocation(program, name);
			attribute.bound = true;
		}
	}

	public function bindUniforms() {
		for(name in uniforms.keys()) {
			var uniform:Uniform = uniforms.get(name);
			if(uniform.bound) continue;

			uniform.location = switch(uniform.value) {
				// TODO
				//case Texture2D(_): TLocation.Texture(pipeline.getConstantLocation(name), pipeline.getTextureUnit(name));
				case _: TLocation.Uniform(context.getUniformLocation(program, name));
			}
			uniform.bound = true;
		}
	}

	private function applyCullMode() {
		switch(cullMode) {
			case None:
				context.disable(GL.CULL_FACE);
			case Back:
				context.enable(GL.CULL_FACE);
				context.cullFace(GL.BACK);
			case Front:
				context.enable(GL.CULL_FACE);
				context.cullFace(GL.FRONT);
			case Both:
				context.enable(GL.CULL_FACE);
				context.cullFace(GL.FRONT_AND_BACK);
		}
	}

	private function applyDepthMode() {
		if(depthWrite)
			context.enable(GL.DEPTH_TEST);
		else
			context.disable(GL.DEPTH_TEST);
		context.depthFunc(switch(depthMode) {
			case Never: GL.NEVER;
			case Less: GL.LESS;
			case Equal: GL.EQUAL;
			case LessOrEqual: GL.LEQUAL;
			case Greater: GL.GREATER;
			case NotEqual: GL.NOTEQUAL;
			case GreaterOrEqual: GL.GEQUAL;
			case Always: GL.ALWAYS;
		});
		context.depthMask(depthWrite);

	}

	private function applyStencilMode() {
		// TODO
	}

	private function applyBlendingMode() {
		// TODO
	}

	@:allow(mammoth.systems.RenderSystem)
	private function apply() {
		// apply our state variables
		applyCullMode();
		applyDepthMode();
		applyStencilMode();
		applyBlendingMode();

		// use our program
		context.useProgram(program);

		// set all the uniforms
		bindUniforms();
		for(uniform in uniforms) {
			switch(uniform.location) {
				case Uniform(location): {
					switch(uniform.value) {
						case Bool(b): context.uniform1i(location, b ? 1 : 0);
						case Int(i): context.uniform1i(location, i);
						case Float(x): context.uniform1f(location, x);
						case Float2(x, y): context.uniform2f(location, x, y);
						case Float3(x, y, z): context.uniform3f(location, x, y, z);
						case Float4(x, y, z, w): context.uniform4f(location, x, y, z, w);
						case Floats(x): context.uniform1fv(location, cast x);
						case Vec2(v): context.uniform2f(location, v.x, v.y);
						case Vec3(v): context.uniform3f(location, v.x, v.y, v.z);
						case Vec4(v): context.uniform4f(location, v.x, v.y, v.z, v.w);
						case Mat4(m): context.uniformMatrix4fv(location, false, cast(m));
						case RGB(c): context.uniform3f(location, c.r, c.g, c.b);
						case RGBA(c): context.uniform4f(location, c.r, c.g, c.b, c.a);
						case _: throw 'Unhandled uniform type ${uniform.value}!';
					}
				}
				// TODO: implement textures
				/*case Texture(location, unit): {
					switch(uniform.value) {
						case Texture2D(t, slot): {
							g.setInt(location, slot);
							g.setTexture(unit, t);
						}
						case _: throw 'Unhandled texture type ${uniform.value}!';
					}
				}*/
			}
		}

		// prepare for render data
		bindAttributes();
	}
}