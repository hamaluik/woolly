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

typedef Transform = {
    /**
     *  3-component array corresponding to x, y, and z positions
     */
    var translation:Array<Float>;

    /**
     *  4-component array corresponding to x, y, z, and w components of rotation
     */
    var rotation:Array<Float>;

    /**
     *  3-component array corresponding to x, y, and z scale
     */
    var scale:Array<Float>;
}

typedef Render = {
    var mesh:String;
    @:optional var shader:String;
}

typedef Object = {
    var name:String;

    @:optional var children:Array<Object>;
    
    @:optional var transform:Transform;

    /**
     *  The component-system components applied to this object
     */
    @:optional var components:Dynamic;

    @:optional var render:Render;

    /**
     *  The name of a camera used by this object, indicating it is a camera
     */
    @:optional var camera:String;

    /**
     *  The name of a light used by this object, indicating it is a light
     */
    @:optional var light:String;
}