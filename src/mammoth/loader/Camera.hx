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
package mammoth.loader;

@:enum
abstract CameraType(String) {
	var Orthographic = "orthographic";
	var Perspective = "perspective";
}

typedef Camera = {
    var name:String;
    var type:CameraType;
    var near:Float;
    var far:Float;
    var clearColour:Colour;
    @:optional var aspect:Float;
    @:optional var fov:Float;
    @:optional var ortho_size:Float;
}