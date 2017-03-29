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
import components.Bounce;
import mammoth.Timing;

class BounceSystem implements ISystem {
    public function update(transform:Transform, bounce:Bounce) {
        bounce.x += bounce.vx * Timing.dt;
        if(bounce.x > bounce.xMax) {
            bounce.x = bounce.xMax;
            bounce.vx *= -1;
        }
        else if(bounce.x < bounce.xMin) {
            bounce.x = bounce.xMin;
            bounce.vx *= -1;
        }

        transform.position.x = bounce.x;
    }
}