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
package mammoth.systems;

import edge.ISystem;
import glm.GLM;
import glm.Quat;
import glm.Vec3;
import glm.Mat4;
import mammoth.components.Transform;

class ModelMatrixSystem implements ISystem {
    private var position:Vec3 = new Vec3();
    private var rotation:Quat = new Quat();
    private var scale:Vec3 = new Vec3();

    private function calculateModelMatrix(transform:Transform) {
        // interpolate based on timing
        Vec3.lerp(transform.lastPosition, transform.position, Mammoth.timing.alpha, position);
        Quat.slerp(transform.lastRotation, transform.rotation, Mammoth.timing.alpha, rotation);
        Vec3.lerp(transform.lastScale, transform.scale, Mammoth.timing.alpha, scale);

        // calculate the full transformation matrix
        GLM.transform(position, rotation, scale, transform.m);

        if(transform.parent != null) {
            calculateModelMatrix(transform.parent);
            Mat4.multMat(transform.parent.m, transform.m, transform.m);
        }
    }

    public function update(transform:Transform) {
        calculateModelMatrix(transform);
    }
}

