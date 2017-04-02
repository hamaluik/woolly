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
import mammoth.components.DirectionalLight;

class DirectionalLightSystem implements ISystem {
    private static var zDir:Vec4 = new Vec4(0, 0, 1, 1);
    
    public function update(transform:Transform, light:DirectionalLight) {
        transform.m.multVec(zDir, light.direction);
    }
}