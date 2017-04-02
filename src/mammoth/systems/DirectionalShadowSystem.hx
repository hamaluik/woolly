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

import mammoth.gl.AttributeLocation;
import mammoth.types.Mesh;
import edge.ISystem;
import edge.View;
import mammoth.components.MeshRenderer;
import mammoth.components.Transform;
import mammoth.components.DirectionalLight;
import mammoth.types.Material;
import mammoth.gl.GL;
import mammoth.defaults.Materials;
import mammoth.gl.types.TCullMode;
import mammoth.gl.types.TDepthFunction;
import mammoth.defaults.Colours;

class DirectionalShadowSystem implements ISystem {
    private var viewMatrix:Mat4 = Mat4.identity(new Mat4());
    private var projectionMatrix:Mat4 = Mat4.identity(new Mat4());
    private var viewProjectionMatrix:Mat4 = Mat4.identity(new Mat4());
    private var MVP:Mat4 = Mat4.identity(new Mat4());
    private var shadowMaterial:Material;

    var shadowCasters:View<{ transform:Transform, renderer:MeshRenderer }>;

    public function update(transform:Transform, light:DirectionalLight) {
        // create a shadow material if one doesn't exist yet
        if(shadowMaterial == null) {
            shadowMaterial = Materials.shadow();
        }

        // create a framebuffer if one doesn't exist yet
        if(light.shadowFramebuffer == null) {
            // create the framebuffer
            light.shadowFramebuffer = Mammoth.gl.createFramebuffer();
        }

        // switch to the framebuffer
        Mammoth.gl.bindFramebuffer(GL.FRAMEBUFFER, light.shadowFramebuffer);

        // give the framebuffer a colour image
        if(light.colourmap == null) {
            light.colourmap = Mammoth.gl.createTexture();
            Mammoth.gl.bindTexture(GL.TEXTURE_2D, light.colourmap);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1024, 1024, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);
            Mammoth.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, light.colourmap, 0);
        }

        // give the framebuffer a depth image
        if(light.shadowmap == null) {
            light.shadowmap = Mammoth.gl.createTexture();
            Mammoth.gl.bindTexture(GL.TEXTURE_2D, light.shadowmap);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texImage2D(GL.TEXTURE_2D, 0, GL.DEPTH_COMPONENT, 1024, 1024, 0, GL.DEPTH_COMPONENT, GL.UNSIGNED_SHORT, null);
            Mammoth.gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.TEXTURE_2D, light.shadowmap, 0);
        }

        if(Mammoth.gl.checkFramebufferStatus(GL.FRAMEBUFFER) != GL.FRAMEBUFFER_COMPLETE) {
            Log.error('Framebuffer isn\'t complete!');
        }

        // calculate the VP matrix for the light
        // TODO: calculate this smarter
        GLM.orthographic(-10, 10, -10, 10, -10, 20, projectionMatrix);
        transform.m.invert(viewMatrix);
        Mat4.multMat(projectionMatrix, viewMatrix, viewProjectionMatrix);

        // render to the framebuffer!
        Mammoth.gl.viewport(0, 0, 1024, 1024);
        Mammoth.gl.scissor(0, 0, 1024, 1024);
        Mammoth.gl.clearColor(Colours.Black);
        Mammoth.gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

        // setup the state
        Mammoth.gl.enable(GL.CULL_FACE);
        Mammoth.gl.cullFace(cast(TCullMode.Back));
        Mammoth.gl.depthMask(true);
        Mammoth.gl.enable(GL.DEPTH_TEST);
        Mammoth.gl.depthFunc(cast(TDepthFunction.LessOrEqual));

        // use our shadow program
        Mammoth.gl.useProgram(shadowMaterial.program);
        Mammoth.gl.uniformMatrix4fv(shadowMaterial.uniformLocation('MVP'), cast(MVP));

        // get the position location
        var positionLocation:AttributeLocation = shadowMaterial.attributeLocation('position');
        Mammoth.gl.enableVertexAttribArray(positionLocation);

        // now actually render
        for(shadowCaster in shadowCasters) {
            // cache the things we care about
            var transform:Transform = shadowCaster.data.transform;
            var renderer:MeshRenderer = shadowCaster.data.renderer;
            var mesh:Mesh = renderer.mesh;

            // skip any meshes that doesn't have position data which is the minimum that we need!
            if(!mesh.hasAttribute('position')) {
                continue;
            }

            // calculate the MVP!
            Mat4.multMat(viewProjectionMatrix, transform.m, MVP);

            // setup the vertex attribution pointer!
            var positionAttribute = mesh.getAttribute('position');
            Mammoth.gl.vertexAttribPointer(positionLocation, 3, GL.FLOAT, false, positionAttribute.stride, positionAttribute.offset);

            // bind the index buffer to the vertices for triangles
            Mammoth.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);

            // and draw those suckers!
            Mammoth.gl.drawElements(GL.TRIANGLES, mesh.indexCount, GL.UNSIGNED_SHORT, 0);
            Mammoth.stats.drawCalls++;
            Mammoth.stats.triangles += Std.int(mesh.indexCount / 3);
        }

        // re-disable vertex attrib array
        Mammoth.gl.disableVertexAttribArray(positionLocation);

        // switch back to the main framebuffer
        Mammoth.gl.bindFramebuffer(GL.FRAMEBUFFER, null);
    }
}

