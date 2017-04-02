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
abstract TBlendFactor(Int) {
    var Zero = GL.ZERO;
    var One = GL.ONE;
    var SrcColour = GL.SRC_COLOR;
    var OneMinusSrcColour = GL.ONE_MINUS_SRC_COLOR;
    var DstColour = GL.DST_COLOR;
    var OneMinusDstColour = GL.ONE_MINUS_DST_COLOR;
    var SrcAlpha = GL.SRC_ALPHA;
    var OneMinusSrcAlpha = GL.ONE_MINUS_SRC_ALPHA;
    var DstAlpha = GL.DST_ALPHA;
    var OneMinusDstAlpha = GL.ONE_MINUS_DST_ALPHA;
    var ConstantColour = GL.CONSTANT_COLOR;
    var OneMinusConstantColour = GL.ONE_MINUS_CONSTANT_COLOR;
    var ConstantAlpha = GL.CONSTANT_ALPHA;
    var OneMinusConstantAlpha = GL.ONE_MINUS_CONSTANT_ALPHA;
    var SrcAlphaSaturate = GL.SRC_ALPHA_SATURATE;
}