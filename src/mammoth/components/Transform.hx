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
import glm.Vec3;
import glm.Quat;

@:allow(mammoth.systems.ModelMatrixSystem)
@:allow(mammoth.systems.PreTransformSystem)
@:allow(mammoth.systems.PostTransformSystem)
class Transform implements IComponent {
    public var name:String = '';
	public var parent(default, set):Transform = null;

	public var position(default, set):Vec3 = new Vec3();
	public var rotation(default, set):Quat = Quat.identity(new Quat());
	public var scale(default, set):Vec3 = new Vec3(1, 1, 1);

    private var lastPosition:Vec3 = new Vec3();
    private var lastRotation:Quat = new Quat();
    private var lastScale:Vec3 = new Vec3();
    
    public var m:Mat4 = Mat4.identity(new Mat4());

    public function new() {}

    private inline function set_parent(newParent:Transform):Transform {
        // don't let us parent ourselves!
        if(newParent == this) return parent;

        parent = newParent;
        return parent;
    }

    private inline function set_position(newPosition:Vec3):Vec3 {
        position.x = newPosition.x;
        position.y = newPosition.y;
        position.z = newPosition.z;
        return position;
    }

    private inline function set_rotation(rot:Quat):Quat {
        rotation.x = rot.x;
        rotation.y = rot.y;
        rotation.z = rot.z;
        rotation.w = rot.w;
        return rotation;
    }

    private inline function set_scale(newScale:Vec3):Vec3 {
        scale.x = newScale.x;
        scale.y = newScale.y;
        scale.z = newScale.z;
        return scale;
    }
}
