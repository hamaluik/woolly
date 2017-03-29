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
import mammoth.components.Transform;
import mammoth.components.Camera;
import glm.GLM;

using glm.Mat4;

class CameraSystem implements ISystem {
    public function update(transform:Transform, camera:Camera) {
        // calculate the updated model matrix
        camera.v = transform.m.copy(camera.v);
        camera.v.invert(camera.v);

        // check for aspect ratio changes
        var aspect:Float = Mammoth.aspectRatio;
        /*if(aspect != camera.aspect) {
            camera.pDirty = true;
        }*/
        camera.pDirty = true;

        if(camera.pDirty) {
            camera.p = switch (camera.projection) {
                case ProjectionMode.Perspective(fov): GLM.perspective(fov, aspect, camera.near, camera.far, camera.p);
                case ProjectionMode.Orthographic(size): {
                    var halfX:Float = size * 0.5;
                    var halfY:Float = halfX / aspect;
                    GLM.orthographic(-halfX, halfX, -halfY, halfY, camera.near, camera.far, camera.p);
                }
            };

            camera.vp = Mat4.multMat(camera.p, camera.v, camera.vp);
            camera.pDirty = false;
        }
    }
}

