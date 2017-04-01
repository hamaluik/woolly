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

import mammoth.platform.Float32Array;
import mammoth.platform.Int16Array;
import mammoth.gl.Buffer;
import mammoth.gl.GL;

class Mesh {
	public var vertexBuffer(default, null):Buffer;
	public var indexBuffer(default, null):Buffer;
	public var vertexCount(default, null):Int;

	public var name(default, null):String;
	public var attributeNames(default, null):Array<String>;

	public function new(name:String, attributeNames:Array<String>) {
		this.name = name;
		this.attributeNames = attributeNames;

		vertexBuffer = Mammoth.gl.createBuffer();
		indexBuffer = Mammoth.gl.createBuffer();
	}

	public function setVertexData(data:Array<Float>) {
		Mammoth.gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		Mammoth.gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(data), GL.STATIC_DRAW);
		Mammoth.gl.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function setIndexData(data:Array<Int>) {
		Mammoth.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		Mammoth.gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(data), GL.STATIC_DRAW);
		Mammoth.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		vertexCount = data.length;
	}
}