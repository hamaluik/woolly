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
package mammoth.filetypes;

import mammoth.debug.Exception;
import mammoth.gl.types.TTextureWrap;
import mammoth.gl.types.TTextureFilter;
import mammoth.Log;
import edge.Entity;
import mammoth.Component;

import mammoth.Mammoth;
import mammoth.components.Camera;
import mammoth.components.DirectionalLight;
import mammoth.components.PointLight;
import mammoth.components.MeshRenderer;
import mammoth.components.Transform;
import mammoth.defaults.Materials;
import mammoth.types.Colour;
import mammoth.types.MaterialData;
import mammoth.types.Mesh;
import mammoth.types.Texture2D;
import mammoth.types.Image;
import mammoth.gl.types.TVertexAttribute;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.ds.StringMap;

using StringTools;

@:enum
abstract MammothCameraType(String) {
	var Orthographic = "orthographic";
	var Perspective = "perspective";
}

typedef MammothCamera = {
    var name:String;
    var type:MammothCameraType;
    var near:Float;
    var far:Float;
    var clearColour:Colour;
    @:optional var aspect:Float;
    @:optional var fov:Float;
    @:optional var ortho_size:Float;
}

@:enum
abstract MammothLightType(String) {
	var Directional = "directional";
	var Point = "point";
}

typedef MammothLight = {
    var name:String;
    var type:MammothLightType;
    var colour:Colour;
    @:optional var distance:Float;
}

typedef MammothUnlitShader = {
    var colour:Colour;
}

typedef MammothDiffuseShader = {
    var ambient:Colour;
    var colour:Colour;
}

typedef MammothShader = {
    var name:String;
    var textures:Array<String>;
    @:optional var unlit:MammothUnlitShader;
    @:optional var diffuse:MammothDiffuseShader;
}

@:enum
abstract MammothTextureFilter(String) {
    var Bilinear = "bilinear";
    var Point = "point";
}

@:enum
abstract MammothTextureWrap(String) {
    var Repeat = "repeat";
    var Clamp = "clamp";
}

typedef MammothImageTexture = {
    var name:String;
    var filter:MammothTextureFilter;
    var wrap:MammothTextureWrap;
}

typedef MammothTexture = {
    var name:String;
    var type:String; // TODO: make an enum for blender's image types?
    var image:MammothImageTexture;
}

typedef MammothImage = {
    var name:String;
    var uri:String;
    var width:Int;
    var height:Int;
}

typedef MammothMesh = {
    var name:String;
    var vertices:String;
    var vlayout:Array<String>;
    var indices:String;
}

typedef MammothTransform = {
    var translation:Array<Float>;
    var rotation:Array<Float>;
    var scale:Array<Float>;
}

typedef MammothRender = {
    var mesh:String;
    @:optional var shader:String;
}

typedef MammothObject = {
    var name:String;
    @:optional var children:Array<MammothObject>;
    @:optional var transform:MammothTransform;
    @:optional var components:Dynamic;
    @:optional var render:MammothRender;
    @:optional var camera:String;
    @:optional var light:String;
}

typedef MammothMeta = {
    var version:String;
    @:optional var file:String;
    @:optional var blender:String;
}

typedef MammothFile = {
    var meta:MammothMeta;
    
    var cameras:Array<MammothCamera>;
    var lights:Array<MammothLight>;
    var shaders:Array<MammothShader>;
    var meshes:Array<MammothMesh>;
    var objects:Array<MammothObject>;
    var images:Array<MammothImage>;
    var textures:Array<MammothTexture>;
}

class MammothJSON {
    private static var basepath:String = '';
    private static var cameras:StringMap<Camera> = new StringMap<Camera>();
    private static var lights:StringMap<Component> = new StringMap<Component>();
    private static var materialDatas:StringMap<MaterialData> = new StringMap<MaterialData>();
    private static var images:StringMap<Image> = new StringMap<Image>();
    private static var textures:StringMap<Texture2D> = new StringMap<Texture2D>();
    
    private function new(){}

    private static function loadCamera(cam:MammothCamera):Void {
        var camera:Camera = new Camera();
        camera.setNearFar(cam.near, cam.far);
        camera.setClearColour(cam.clearColour);
        camera.setProjection(switch(cam.type) {
            case MammothCameraType.Orthographic:
                ProjectionMode.Orthographic(cam.ortho_size);
            case MammothCameraType.Perspective:
                ProjectionMode.Perspective(cam.fov);
        });
        camera.setViewport(new Vec2(0, 0), new Vec2(1, 1));
        cameras.set(cam.name, camera);
    }

    private static function loadLight(light:MammothLight):Void {
        lights.set(light.name, switch(light.type) {
            case MammothLightType.Directional: {
                var dirLight:DirectionalLight = new DirectionalLight();
                dirLight.setColour(light.colour);
                dirLight;
            }
            case MammothLightType.Point: {
                var pointLight:PointLight = new PointLight();
                pointLight.setColour(light.colour);
                pointLight.setDistance(Math.sqrt(light.distance));
                pointLight;
            }
        });
    }

    private static function loadImage(im:MammothImage):Void {
        var uri:String = im.uri.replace('//', basepath + '/');
        var image:Image = new Image(uri, im.width, im.height);
        images.set(im.name, image);
    }

    private static function loadTexture(tex:MammothTexture):Void {
        var texture:Texture2D = new Texture2D();
        texture.minFilter = switch(tex.image.filter) {
            case MammothTextureFilter.Bilinear: TTextureFilter.Linear;
            case MammothTextureFilter.Point: TTextureFilter.Nearest;
        }
        texture.magFilter = texture.minFilter;
        texture.wrapMode = switch(tex.image.wrap) {
            case MammothTextureWrap.Clamp: TTextureWrap.Clamp;
            case MammothTextureWrap.Repeat: TTextureWrap.Repeat;
        }

        var image:Image = images.get(tex.image.name);
        if(image == null) throw new Exception('Can\'t find image ${tex.image.name}!', true);
        
        texture.tex = Mammoth.gl.loadTexture(image.uri, texture.minFilter, texture.magFilter, texture.wrapMode);
        textures.set(tex.name, texture);
    }

    private static function loadMaterialData(shader:MammothShader):Void {
        var data:MaterialData = new MaterialData();

        if(shader.unlit != null) {
            data.uniformValues.set('albedoColour', TUniformData.RGB(shader.unlit.colour));
        }
        else if(shader.diffuse != null) {
            data.uniformValues.set('albedoColour', TUniformData.RGB(shader.diffuse.colour));
            data.uniformValues.set('ambientColour', TUniformData.RGB(shader.diffuse.ambient));
        }

        // this somehow breaks rendering?!
        for(tex in shader.textures) {
            var texture:Texture2D = textures.get(tex);
            if(texture == null) throw new Exception('Can\'t load texture ${tex} for shader ${shader.name} as it wasn\'t found!', true);
            data.textures.push(texture);
        }

        materialDatas.set(shader.name, data);
    }

    private static function loadMesh(meshData:MammothMesh):Void {
        var mesh:Mesh = new Mesh(meshData.name);

        mesh.setVertexData(parseFloatArrayURI(meshData.vertices));
        mesh.setIndexData(parseIntArrayURI(meshData.indices));

        for(attribute in meshData.vlayout) {
            mesh.registerAttribute(attribute, switch(attribute) {
                case 'position': TVertexAttribute.Vec3;
                case 'normal': TVertexAttribute.Vec3;
                case 'colour': TVertexAttribute.Vec4;
                case 'uv': TVertexAttribute.Vec2;
                case _: null;
            });
        }

        mesh.compile();
        //meshes.set(meshData.name, mesh);
        Mammoth.resources.meshes.set(meshData.name, mesh);
    }

    private static function loadObject(parentTransform:Transform, object:MammothObject, componentFactory:String->Dynamic->Component):Void {
        var entity:Entity = Mammoth.engine.create([]);
        if(object.transform != null) {
            var transform:Transform = new Transform();
            transform.position = cast(object.transform.translation);
            transform.rotation = cast(object.transform.rotation);
            transform.scale = cast(object.transform.scale);
            transform.name = object.name;
            transform.parent = parentTransform;

            // load all children recursively
            if(object.children != null) {
                for(child in object.children) {
                    loadObject(transform, child, componentFactory);
                }
            }

            entity.add(transform);
        }

        if(object.render != null && object.render.shader != null) {
            var renderer:MeshRenderer = new MeshRenderer();
            
            renderer.mesh = Mammoth.resources.meshes.get(object.render.mesh);
            if(!Mammoth.resources.materials.exists('standard_1_6_0')) {
                Mammoth.resources.materials.set('standard_1_6_0', Materials.standard(1, 6, 0));
            }
            if(!Mammoth.resources.materials.exists('standard_1_6_1')) {
                Mammoth.resources.materials.set('standard_1_6_1', Materials.standard(1, 6, 1));
            }
            //renderer.material = Mammoth.resources.materials.get('standard_1_6_0');
            renderer.materialData = materialDatas.get(object.render.shader);
            renderer.material = switch(renderer.materialData.textures.length) {
                case 0: Mammoth.resources.materials.get('standard_1_6_0');
                case 1: Mammoth.resources.materials.get('standard_1_6_1');
                case _: null;
            }
            if(renderer.material == null) throw new Exception('Materials can only use 0 or 1 textures, not ${renderer.materialData.textures.length}!');

            entity.add(renderer);
        }

        if(object.camera != null) {
            entity.add(cameras.get(object.camera));
        }

        if(object.light != null) {
            entity.add(lights.get(object.light));
        }

        // TODO: change component factory to some clever macro
        if(object.components != null) {
            var componentTypes:Array<String> = Reflect.fields(object.components);
            for(componentType in componentTypes) {
                var comp:Dynamic = Reflect.field(object.components, componentType);
                var c:Component = componentFactory(componentType, comp);
                if(c != null) entity.add(c);
            }
        }
    }

    public static function load(basepath:String, file:MammothFile, componentFactory:String->Dynamic->Component):Void {
        MammothJSON.basepath = basepath;
        if(MammothJSON.basepath.endsWith('/')) MammothJSON.basepath = MammothJSON.basepath.substr(0, MammothJSON.basepath.length - 1);
        Log.info('Loading data from ${MammothJSON.basepath}/${file.meta.file}..');

        // load cameras
        cameras = new StringMap<Camera>();
        for(camera in file.cameras) {
            loadCamera(camera);
        }

        // load lights
        lights = new StringMap<Component>();
        for(light in file.lights) {
            loadLight(light);
        }

        // load images
        images = new StringMap<Image>();
        for(image in file.images) {
            loadImage(image);
        }

        // load textures
        textures = new StringMap<Texture2D>();
        for(texture in file.textures) {
            loadTexture(texture);
        }

        // load shaders
        materialDatas = new StringMap<MaterialData>();
        for(shad in file.shaders) {
            loadMaterialData(shad);
        }

        // load meshes
        for(me in file.meshes) {
            loadMesh(me);
        }
        
        // load actual objects
        for(object in file.objects) {
            loadObject(null, object, componentFactory);
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