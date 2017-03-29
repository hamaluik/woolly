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
import glm.Mat4;
import glm.Vec2;
import mammoth.utilities.Colour;
import mammoth.utilities.Colours;

enum ProjectionMode {
    Orthographic(size:Float);
    Perspective(fieldOfView:Float);
}

class Camera implements IComponent {
    public var pDirty:Bool = true;

    public var near:Float = 0.1;
    public var far:Float = 100;
    public var aspect:Float = 16/9;
    public var projection:ProjectionMode = ProjectionMode.Perspective(60);
    public var viewportMin:Vec2 = new Vec2(0, 0);
    public var viewportMax:Vec2 = new Vec2(1, 1);
    public var clearColour:Colour = Colours.Black;

    public var v:Mat4 = new Mat4(1.0);
    public var p:Mat4 = new Mat4(1.0);
    public var vp:Mat4 = new Mat4(1.0);

    public function new() {}

    public function setNearFar(near:Float, far:Float):Camera {
        this.near = near;
        this.far = far;
        pDirty = true;
        return this;
    }

    public function setProjection(projection:ProjectionMode):Camera {
        this.projection = projection;
        pDirty = true;
        return this;
    }

    public function setViewport(min:Vec2, max:Vec2):Camera {
        this.viewportMin = min;
        this.viewportMax = max;
        return this;
    }

    public function setClearColour(colour:Colour):Camera {
        this.clearColour = colour;
        return this;
    }
}
