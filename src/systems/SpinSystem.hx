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
package systems;

import edge.ISystem;
import mammoth.components.Transform;
import components.Spin;
import mammoth.Timing;

class SpinSystem implements ISystem {
    private var axis:Vec3 = new Vec3(0, 0, 1);

    public function update(transform:Transform, spin:Spin) {
        spin.angle += spin.speed * Timing.dt;
        Quat.axisAngle(axis, spin.angle, transform.rotation);
    }
}