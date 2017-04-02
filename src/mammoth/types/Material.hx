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
import mammoth.debug.Exception;
import mammoth.gl.AttributeLocation;
import mammoth.gl.UniformLocation;
import mammoth.gl.GL;
import mammoth.gl.Shader;
import mammoth.gl.Program;
import mammoth.gl.types.TCullMode;
import mammoth.gl.types.TDepthFunction;
import mammoth.gl.types.TShader;
import mammoth.gl.types.TVertexAttribute;
import mammoth.gl.types.TShaderUniform;
import mammoth.types.MaterialAttribute;
import mammoth.types.ShaderUniform;

class Material {
    public var program(default, null):Program;
    private var vertexShaderSource:String;
    public var vertexShader(default, null):Shader;
    private var fragmentShaderSource:String;
    public var fragmentShader(default, null):Shader;

    public var name(default, null):String;
    public var attributes(default, null):StringMap<MaterialAttribute>;
    public var uniforms(default, null):StringMap<ShaderUniform>;

    public var cullMode:TCullMode = TCullMode.Back;
    public var depthWrite:Bool = true;
    public var depthTest:Bool = true;
    public var depthFunction:TDepthFunction = TDepthFunction.LessOrEqual;

    public function new(name:String) {
        this.name = name;
        attributes = new StringMap<MaterialAttribute>();
        uniforms = new StringMap<ShaderUniform>();
    }

    public function toString():String {
        var h:String = 'Material: ${name}\n';
        h += 'Attributes:\n';
        for(attribute in attributes) {
            h += '  ${attribute.name} (${attribute.type}) at ${attribute.location}\n';
        }
        h += 'Uniforms:\n';
        for(uniform in uniforms) {
            h += '  ${uniform.name} (${uniform.type})\n';
        }
        return h;
    }

    public function setShaderSource(source:String, type:TShader):Material {
        switch(type) {
            case TShader.Vertex: vertexShaderSource = source;
            case TShader.Fragment: fragmentShaderSource = source;
        }
        return this;
    }

    private function compileShader(source:String, type:TShader):Shader {
        var shader:Shader = Mammoth.gl.createShader(cast(type));
        Mammoth.gl.shaderSource(shader, source);
        Mammoth.gl.compileShader(shader);
		if(!Mammoth.gl.getShaderParameter(shader, GL.COMPILE_STATUS)) {
			var info:String = Mammoth.gl.getShaderInfoLog(shader);
			var typeStr:String = type == TShader.Vertex ? 'Vertex' : 'Fragment';
			throw new Exception(info, true, 'Compile${typeStr}Shader');
		}
		return shader;
    }

    public function compile():Material {
        if(vertexShaderSource == null || fragmentShaderSource == null)
            throw new Exception('Can\'t compile material ${name}, shaders are missing!', true);
        
        vertexShader = compileShader(vertexShaderSource, TShader.Vertex);
        fragmentShader = compileShader(fragmentShaderSource, TShader.Fragment);

        program = Mammoth.gl.createProgram();
        Mammoth.gl.attachShader(program, vertexShader);
        Mammoth.gl.attachShader(program, fragmentShader);

        Mammoth.gl.linkProgram(program);
		if(!Mammoth.gl.getProgramParameter(program, GL.LINK_STATUS)) {
			var info:String = Mammoth.gl.getProgramInfoLog(program);
			throw new Exception(info, true, 'LinkProgram');
		}

        return this;
    }

    public function registerAttribute(name:String, type:TVertexAttribute):Material {
        var attribute:MaterialAttribute = new MaterialAttribute(name, type);

        // to locate the attribute, we need to get GL to use the program first
        Mammoth.gl.useProgram(program);
        attribute.location = Mammoth.gl.getAttribLocation(program, name);

        attributes.set(name, attribute);
        return this;
    }

    public function registerUniform(name:String, type:TShaderUniform):Material {
        var uniform:ShaderUniform = new ShaderUniform(name, type);

        Mammoth.gl.useProgram(program);
        uniform.location = Mammoth.gl.getUniformLocation(program, name);

        uniforms.set(name, uniform);
        return this;
    }

    public inline function hasAttribute(name:String):Bool {
        return attributes.exists(name);
    }

    public inline function attributeLocation(name:String):AttributeLocation {
        return attributes.get(name).location;
    }

    public inline function hasUniform(name:String):Bool {
        return uniforms.exists(name);
    }

    public inline function uniformLocation(name:String):UniformLocation {
        return uniforms.get(name).location;
    }
}