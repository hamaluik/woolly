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
import edge.View;
import mammoth.components.MeshRenderer;
import mammoth.components.Transform;
import mammoth.components.Camera;
import mammoth.components.DirectionalLight;
import mammoth.components.PointLight;
import mammoth.Mammoth;
import mammoth.gl.Graphics;
import mammoth.gl.GL;
import mammoth.render.Attribute;
import mammoth.render.Material;
import mammoth.render.Mesh;

class RenderSystem implements ISystem {
    var objects:View<{ transform:Transform, renderer:MeshRenderer }>;
    var directionalLights:View<{ transform:Transform, light:DirectionalLight }>;
    var pointLights:View<{ transform:Transform, light:PointLight }>;

    public function update(camera:Camera) {
        // calculate the viewport
        var vpX:Int = Std.int(camera.viewportMin.x * Mammoth.width);
        var vpY:Int = Std.int(camera.viewportMin.y * Mammoth.height);
        var vpW:Int = Std.int((camera.viewportMax.x - camera.viewportMin.x) * Mammoth.width);
        var vpH:Int = Std.int((camera.viewportMax.y - camera.viewportMin.y) * Mammoth.height);

        // clear our region of the screen
        var g:Graphics = Mammoth.gl;
        g.context.viewport(vpX, vpY, vpW, vpH);
        g.context.scissor(vpX, vpY, vpW, vpH);
        g.clearColour(camera.clearColour);
        g.context.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

        // render each object!
        for(o in objects) {
            // cache the things we care about
            var transform:Transform = o.data.transform;
            var renderer:MeshRenderer = o.data.renderer;
            var mesh:Mesh = renderer.mesh;
            var material:Material = renderer.material;

            // calculate the MVP for this object
            renderer.MVP = Mat4.multMat(camera.vp, transform.m, renderer.MVP);

            // set the M, V, P uniforms
            if(material.uniforms.exists('MVP')) {
                material.setUniform('MVP', TUniform.Mat4(renderer.MVP));
            }
            if(material.uniforms.exists('M')) {
                material.setUniform('M', TUniform.Mat4(transform.m));
            }
            if(material.uniforms.exists('VP')) {
                material.setUniform('VP', TUniform.Mat4(camera.vp));
            }
            if(material.uniforms.exists('V')) {
                material.setUniform('V', TUniform.Mat4(camera.v));
            }
            if(material.uniforms.exists('P')) {
                material.setUniform('P', TUniform.Mat4(camera.p));
            }
        
            if(material.uniforms.exists('directionalLights[0].direction')) {
                var i:Int = 0;
                for(dl in directionalLights) {
                    // calculate the direction
                    // TODO: calculate this offline somewhere else for efficiency!
                    var dir:Vec4 = dl.data.transform.m.multVec(new Vec4(0, 0, 1, 1), new Vec4());

                    material.setUniform('directionalLights[${i}].direction', TUniform.Vec3(new Vec3(dir.x, dir.y, dir.z)));
                    material.setUniform('directionalLights[${i}].colour', TUniform.RGB(dl.data.light.colour));
                    i++;
                }
            }
            if(material.uniforms.exists('pointLights[0].position')) {
                var i:Int = 0;
                for(pl in pointLights) {
                    material.setUniform('pointLights[${i}].position', TUniform.Vec3(pl.data.transform.position));
                    material.setUniform('pointLights[${i}].colour', TUniform.RGB(pl.data.light.colour));
                    material.setUniform('pointLights[${i}].distance', TUniform.Float(pl.data.light.distance));
                    i++;
                }
            }
            // TODO: spotlights
            
            // apply the material and render!
            material.apply();

            // set up the attributes
            g.context.bindBuffer(GL.ARRAY_BUFFER, mesh.vertexBuffer);
            for(attributeName in mesh.attributeNames) {
                if(!material.attributes.exists(attributeName)) continue;
                var attribute:Attribute = material.attributes.get(attributeName);
                
                g.context.enableVertexAttribArray(attribute.location);
                g.context.vertexAttribPointer(
                    attribute.location,
                    switch(attribute.type) {
                        case Float: 1;
                        case Vec2: 2;
                        case Vec3: 3;
                        case Vec4: 4;
                    },
                    GL.FLOAT,
                    false,
                    attribute.stride,
                    attribute.offset);
            }

            // bind the index buffer to the vertices for triangles
            g.context.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);

            // and draw those suckers!
            g.context.drawElements(GL.TRIANGLES, mesh.vertexCount, GL.UNSIGNED_SHORT, 0);
            Mammoth.stats.drawCalls++;
            Mammoth.stats.triangles += Std.int(mesh.vertexCount / 3);
        }
    }
}
