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

import mammoth.render.TAttribute;

@:allow(mammoth.render.Material)
class Attribute {
	public var name(default, null):String;
	public var location(default, null):Int;
	public var bound(default, null):Bool = false;
	public var type:TAttribute;
	public var stride:Int;
	public var offset:Int;

	public function new(name:String, type:TAttribute, stride:Int, offset:Int) {
		this.name = name;
		this.type = type;
		this.stride = stride;
		this.offset = offset;
	}
}