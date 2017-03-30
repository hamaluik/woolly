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
package mammoth.loader;

import mammoth.Log;
import edge.Entity;
import glm.Vec2;
import glm.Mat4;

import mammoth.Mammoth;
import mammoth.components.DirectionalLight;
import mammoth.components.PointLight;
import mammoth.components.MeshRenderer;
import mammoth.defaults.StandardShader;
import mammoth.defaults.StandardShader.StandardAttributes;
import mammoth.defaults.StandardShader.StandardUniforms;
import mammoth.render.Attribute;
import mammoth.render.TAttribute;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.ds.StringMap;

using StringTools;

class Loader {
    private static var cameras:StringMap<mammoth.components.Camera> = new StringMap<mammoth.components.Camera>();
    private static var lights:StringMap<edge.IComponent> = new StringMap<edge.IComponent>();
    private static var shaders:StringMap<StandardShader> = new StringMap<StandardShader>();
    private static var meshes:StringMap<mammoth.render.Mesh> = new StringMap<mammoth.render.Mesh>();

    private function new(){}

    private static function toColour(colour:Colour):mammoth.utilities.Colour {
        var c:mammoth.utilities.Colour = new mammoth.utilities.Colour();
        c.r = colour[0];
        c.g = colour[1];
        c.b = colour[2];
        if(colour.length > 3)
            c.a = colour[3];
        return c;
    }

    private static function loadCamera(camera:mammoth.loader.Camera):Void {
        var cam:mammoth.components.Camera = new mammoth.components.Camera();
        cam.setNearFar(camera.near, camera.far);
        cam.setClearColour(toColour(camera.clearColour));
        cam.setProjection(switch(camera.type) {
            case mammoth.loader.Camera.CameraType.Orthographic:
                mammoth.components.Camera.ProjectionMode.Orthographic(camera.ortho_size);
            case mammoth.loader.Camera.CameraType.Perspective:
                mammoth.components.Camera.ProjectionMode.Perspective(camera.fov);
        });
        cam.setViewport(new Vec2(0, 0), new Vec2(1, 1));

        cameras.set(camera.name, cam);
    }

    private static function loadLight(light:mammoth.loader.Light):Void {
        lights.set(light.name, switch(light.type) {
            case mammoth.loader.Light.LightType.Directional: {
                var dirLight:DirectionalLight = new DirectionalLight();
                dirLight.setColour(toColour(light.colour));
                dirLight;
            }
            case mammoth.loader.Light.LightType.Point: {
                var pointLight:PointLight = new PointLight();
                pointLight.setColour(toColour(light.colour));
                pointLight.setDistance(Math.sqrt(light.distance));
                pointLight;
            }
        });
    }

    private static function loadShader(shad:mammoth.loader.Shader):Void {
        var shader:StandardShader = new StandardShader();

        if(shad.unlit != null) {
            shader.albedoColour = toColour(shad.unlit.colour);
        }
        else if(shad.diffuse != null) {
            shader.setUniform(StandardUniforms.DirectionalLights);
            shader.setUniform(StandardUniforms.PointLights);

            shader.albedoColour = toColour(shad.diffuse.colour);
            shader.ambientColour = toColour(shad.diffuse.ambient);
        }

        if(shad.textures.length > 0) {
            shader.setUniform(StandardUniforms.Texture);
        }

        shaders.set(shad.name, shader);
    }

    private static function loadMesh(me:mammoth.loader.Mesh):Void {
        var mesh:mammoth.render.Mesh = new mammoth.render.Mesh(me.name, me.vlayout);

        mesh.setVertexData(parseFloatArrayURI(me.vertices));
        mesh.setIndexData(parseIntArrayURI(me.indices));

        meshes.set(me.name, mesh);
    }

    private static function loadObject(parentTransform:mammoth.components.Transform, object:mammoth.loader.Object):Void {
        var entity:Entity = Mammoth.engine.create([]);
        if(object.transform != null) {
            var transform:mammoth.components.Transform = new mammoth.components.Transform();
            transform.position = cast(object.transform.translation);
            transform.rotation = cast(object.transform.rotation);
            transform.scale = cast(object.transform.scale);
            transform.name = object.name;
            transform.parent = parentTransform;

            // load all children recursively
            if(object.children != null) {
                for(child in object.children) {
                    loadObject(transform, child);
                }
            }

            entity.add(transform);
        }

        if(object.render != null && object.render.shader != null) {
            var renderer:MeshRenderer = new MeshRenderer()
                .setMesh(meshes.get(object.render.mesh));

            // create a material for this renderer
            var material:mammoth.render.Material = new mammoth.render.Material(
                object.render.mesh + "->" + object.render.shader
            );
            material.setStandardShader(shaders.get(object.render.shader));

            // apply the attributes according to the mesh
            for(attribute in renderer.mesh.attributeNames) {
                switch(attribute) {
                    case 'position': {};
                    case 'normal': {};
                    case 'uv': material.standardShader.setAttribute(StandardAttributes.UV);
                    case 'colour': material.standardShader.setAttribute(StandardAttributes.Colour);
                    case _: throw new mammoth.debug.Exception('Unknown vertex attribute \'${attribute}\'!', false, 'UnknownAttribute');
                }
            }

            // compile it
            material.compile();

            // set attributes
            var offset:Int = 0;
            var attributes:Array<Attribute> = new Array<Attribute>();
            for(attribute in renderer.mesh.attributeNames) {
                switch(attribute) {
                    case 'position': {
                        attributes.push(new Attribute('position', TAttribute.Vec3, 0, offset));
                        offset += 3 * 4;
                    };
                    case 'normal': {
                        attributes.push(new Attribute('normal', TAttribute.Vec3, 0, offset));
                        offset += 3 * 4;
                    };
                    case 'uv': {
                        attributes.push(new Attribute('uv', TAttribute.Vec2, 0, offset));
                        offset += 2 * 4;
                    };
                    case 'colour': {
                        attributes.push(new Attribute('colour', TAttribute.Vec3, 0, offset));
                        offset += 3 * 4;
                    };
                }
            }
            // adjust the stride and apply it to the material
            for(attribute in attributes) {
                attribute.stride = offset;
                material.registerAttribute(attribute.name, attribute);
            }

            // apply the uniforms
            material.setUniform('albedoColour', TUniform.RGB(material.standardShader.albedoColour));
            material.setUniform('ambientColour', TUniform.RGB(material.standardShader.ambientColour));

            material.setUniform('MVP', TUniform.Mat4(Mat4.identity(new Mat4())));
            material.setUniform('M', TUniform.Mat4(Mat4.identity(new Mat4())));

            // set 'empty' light uniforms
            if(material.standardShader.hasUniform(StandardUniforms.DirectionalLights)) {
                material.setUniform('directionalLights[0].direction', TUniform.Vec3(new Vec3()));
                material.setUniform('directionalLights[0].colour', TUniform.RGB(mammoth.utilities.Colours.Black));
            }
            if(material.standardShader.hasUniform(StandardUniforms.PointLights)) {
                material.setUniform('pointLights[0].position', TUniform.Vec3(new Vec3()));
                material.setUniform('pointLights[0].colour', TUniform.RGB(mammoth.utilities.Colours.Black));
                material.setUniform('pointLights[0].distance', TUniform.Float(0.0));
            }
            
            // TODO..?

            // apply the material
            renderer.setMaterial(material);
            entity.add(renderer);
        }

        if(object.camera != null) {
            entity.add(cameras.get(object.camera));
        }

        if(object.light != null) {
            entity.add(lights.get(object.light));
        }
    }

    public static function load(file:MammothFile):Void {
        Log.info('Loading data from ${file.meta.file}..');

        // load cameras
        cameras = new StringMap<mammoth.components.Camera>();
        for(camera in file.cameras) {
            loadCamera(camera);
        }

        // load lights
        lights = new StringMap<edge.IComponent>();
        for(light in file.lights) {
            loadLight(light);
        }

        // load shaders
        shaders = new StringMap<StandardShader>();
        for(shad in file.shaders) {
            loadShader(shad);
        }

        // load meshes
        meshes = new StringMap<mammoth.render.Mesh>();
        for(me in file.meshes) {
            loadMesh(me);
        }
        
        // load actual objects
        for(object in file.objects) {
            loadObject(null, object);
        }
    }

    private static function parseFloatArrayURI(uri:String):Array<Float> {
        if(!uri.startsWith('data:text/plain;base64,')) {
            return new Array<Float>();
        }

        var data:Bytes = Base64.decode(uri.substr('data:text/plain;base64,'.length));
        var arr:haxe.io.Float32Array = haxe.io.Float32Array.fromBytes(data);

        var ret:Array<Float> = new Array<Float>();
        for(i in 0...arr.length) {
            ret.push(arr.get(i));
        }
        return ret;
    }

    private static function parseIntArrayURI(uri:String):Array<Int> {
        if(!uri.startsWith('data:text/plain;base64,')) {
            return new Array<Int>();
        }

        var data:Bytes = Base64.decode(uri.substr('data:text/plain;base64,'.length));
        var arr:haxe.io.Int32Array = haxe.io.Int32Array.fromBytes(data);

        var ret:Array<Int> = new Array<Int>();
        for(i in 0...arr.length) {
            ret.push(arr.get(i));
        }
        return ret;
    }
}