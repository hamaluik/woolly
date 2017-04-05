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
package mammoth.gl.types;

import mammoth.gl.GL;

@:enum
abstract TTextureFilter(Int) {
    var Nearest = GL.NEAREST;
    var Linear = GL.LINEAR;
    var NearestMipMapNearest = GL.NEAREST_MIPMAP_NEAREST;
    var NearestMipMapLinear = GL.NEAREST_MIPMAP_LINEAR;
    var LinearMipMapNearest = GL.LINEAR_MIPMAP_NEAREST;
    var LinearMipMapLinear = GL.LINEAR_MIPMAP_LINEAR;
}