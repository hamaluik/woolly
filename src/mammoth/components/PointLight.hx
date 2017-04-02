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
package mammoth.components;

import edge.IComponent;
import mammoth.types.Colour;
import mammoth.defaults.Colours;

class PointLight implements IComponent {
    public var colour:Colour = Colours.White;
    public var distance:Float = 25;

    public function new() {}

    public function setColour(colour:Colour):PointLight {
        this.colour = colour;
        return this;
    }

    public function setDistance(distance:Float):PointLight {
        this.distance = distance;
        return this;
    }
}