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

import mammoth.gl.GL;
import mammoth.gl.Buffer;
import mammoth.gl.TBufferUsage;
import mammoth.platform.Float32Array;
import mammoth.platform.Int16Array;

class Mesh {
    public var vertexBuffer(default, null):Buffer;
    public var indexBuffer(default, null):Buffer;
    public var indexCount(default, null):Int;

    public var name(default, null):String;
    public var attributes(default, null):Array<MeshAttribute>;

    public function new(name:String) {
        this.name = name;

        vertexBuffer = Mammoth.gl.createBuffer();
        indexBuffer = Mammoth.gl.createBuffer();
        indexCount = 0;

        attributes = new Array<MeshAttribute>();
    }

    public function toString():String {
        var h:String = 'Mesh: ${name}\n';
        h += 'Triangles: ${indexCount / 3}\n';
        h += 'Attributes:\n';
        for(attribute in attributes) {
            h += '  ${attribute.name} (${attribute.type}) ${attribute.stride}-${attribute.offset}\n';
        }
        return h;
    }

    public function registerAttribute(name:String, type:TVertexAttribute, ?order:Int):Mesh {
        var attribute:MeshAttribute = new MeshAttribute(name, type);
        if(order == null) attributes.push(attribute);
        else attributes.insert(order, attribute);
        return this;
    }

    public function setVertexData(data:Array<Float>, usage:TBufferUsage = TBufferUsage.Static):Mesh {
        Mammoth.gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
        Mammoth.gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(data), cast(usage));
        Mammoth.gl.bindBuffer(GL.ARRAY_BUFFER, null);
        return this;
    }

    public function setIndexData(data:Array<Int>, usage:TBufferUsage = TBufferUsage.Static):Mesh {
        Mammoth.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
        Mammoth.gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(data), cast(usage));
        Mammoth.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
        indexCount = data.length;
        return this;
    }

    public function compile():Void {
        var offset:Int = 0;
        for(attribute in attributes) {
            attribute.offset = offset;
            offset += switch(attribute.type) {
                case Float: 4;
                case Vec2: 8;
                case Vec3: 12;
                case Vec4: 16;
                case _: throw new mammoth.debug.Exception('Unhandled attribute type ${attribute.type}!', true);
            }
        }

        for(attribute in attributes) {
            attribute.stride = offset;
        }
    }

    public function hasAttribute(name:String):Bool {
        for(attribute in attributes) {
            if(attribute.name == name) return true;
        }
        return false;
    }

    public function getAttribute(name:String):MeshAttribute {
        for(attribute in attributes) {
            if(attribute.name == name) return attribute;
        }
        return null;
    }
}