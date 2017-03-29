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

import js.html.Float32Array;
import js.html.Int16Array;
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import mammoth.gl.Graphics;
import mammoth.gl.GL;

class Mesh {
	private var context:RenderingContext;

	@:allow(mammoth.systems.RenderSystem)
	private var vertexBuffer:Buffer;
	@:allow(mammoth.systems.RenderSystem)
	private var indexBuffer:Buffer;

	@:allow(mammoth.systems.RenderSystem)
	private var vertexCount:Int;

	public var name(default, null):String;
	public var attributeNames(default, null):Array<String>;

	public function new(name:String, graphics:Graphics, attributeNames:Array<String>) {
		this.name = name;
		this.context = graphics.context;
		this.attributeNames = attributeNames;

		vertexBuffer = context.createBuffer();
		indexBuffer = context.createBuffer();
	}

	public function setVertexData(data:Array<Float>) {
		context.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		context.bufferData(GL.ARRAY_BUFFER, new Float32Array(data), GL.STATIC_DRAW);
		context.bindBuffer(GL.ARRAY_BUFFER, null);
	}

	public function setIndexData(data:Array<Int>) {
		context.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		context.bufferData(GL.ELEMENT_ARRAY_BUFFER, new Int16Array(data), GL.STATIC_DRAW);
		context.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		vertexCount = data.length;
	}
}