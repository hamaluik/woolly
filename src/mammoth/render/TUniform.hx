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

import haxe.ds.Vector;
import glm.Mat4;
import glm.Vec2;
import glm.Vec3;
import glm.Vec4;
import mammoth.utilities.Colour;

enum TUniform {
	Bool(x:Bool);
	Int(x:Int);
	Float(x:Float);
	Float2(x:Float, y:Float);
	Float3(x:Float, y:Float, z:Float);
	Float4(x:Float, y:Float, z:Float, w:Float);
	Floats(x:Vector<Float>);
	Vec2(x:Vec2);
	Vec3(x:Vec3);
	Vec4(x:Vec4);
	Mat4(v:Mat4);
	RGB(c:Colour);
	RGBA(c:Colour);
	// TODO: implement textures
	//Texture2D(t:Image, slot:Int);
}