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
import mammoth.components.TuskContext;
import tusk.Tusk;
import mammoth.gl.GL;
import mammoth.gl.AttributeLocation;

class StatsDisplaySystem implements ISystem {
    public function update(context:TuskContext) {
        Mammoth.gl.viewport(0, 0, Std.int(Mammoth.width), Std.int(Mammoth.height));
        Mammoth.gl.scissor(0, 0, Std.int(Mammoth.width), Std.int(Mammoth.height));

        Tusk.draw.screenWidth = mammoth.Mammoth.width;
        Tusk.draw.screenHeight = mammoth.Mammoth.height;

        if(Tusk.draw.numVertices == 0) return;
        
        Mammoth.gl.disable(GL.CULL_FACE);
        Mammoth.gl.disable(GL.DEPTH_TEST);

        Mammoth.gl.enable(GL.BLEND);
        Mammoth.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

        Mammoth.gl.useProgram(context.material.program);

        Mammoth.gl.bindBuffer(GL.ARRAY_BUFFER, context.buffer);
        Mammoth.gl.bufferData(GL.ARRAY_BUFFER, Tusk.draw.buffer, GL.DYNAMIC_DRAW);

        Mammoth.gl.uniformMatrix4fv(context.material.uniformLocation('VP'), cast(Tusk.draw.vpMatrix));
        Mammoth.gl.uniform1i(context.material.uniformLocation('texture'), 0);

        Mammoth.gl.activeTexture(GL.TEXTURE0);
        Mammoth.gl.bindTexture(GL.TEXTURE_2D, context.data.textures[0]);

        var positionLoc:AttributeLocation = context.material.attributeLocation('position');
        var uvLoc:AttributeLocation = context.material.attributeLocation('uv');
        var colourLoc:AttributeLocation = context.material.attributeLocation('colour');

        Mammoth.gl.enableVertexAttribArray(positionLoc);
        Mammoth.gl.vertexAttribPointer(positionLoc, 2, GL.FLOAT, false, 8*4, 0);
        Mammoth.gl.enableVertexAttribArray(uvLoc);
        Mammoth.gl.vertexAttribPointer(uvLoc, 2, GL.FLOAT, false, 8*4, 2*4);
        Mammoth.gl.enableVertexAttribArray(colourLoc);
        Mammoth.gl.vertexAttribPointer(colourLoc, 4, GL.FLOAT, false, 8*4, 4*4);

        Mammoth.gl.drawArrays(GL.TRIANGLES, 0, Tusk.draw.numVertices);

        Mammoth.gl.disableVertexAttribArray(positionLoc);
        Mammoth.gl.disableVertexAttribArray(uvLoc);
        Mammoth.gl.disableVertexAttribArray(colourLoc);
    }
}