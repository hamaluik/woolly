package mammoth.defaults;

import mammoth.types.Material;
import mammoth.gl.types.TShader;
import mammoth.gl.types.TVertexAttribute;
import mammoth.gl.types.TShaderUniform;
import mammoth.gl.types.TCullMode;
import mammoth.gl.types.TBlendFactor;
import tusk.Tusk;

class Materials {
    public static function shadow():Material {
        var material:Material = new Material('shadow');

        var vertexSrc:String = mammoth.macros.FileContents.contents('mammoth/assets/shadow.vert.glsl');
        var fragSrc:String = mammoth.macros.FileContents.contents('mammoth/assets/shadow.frag.glsl');

        material.setShaderSource(vertexSrc, TShader.Vertex);
        material.setShaderSource(fragSrc, TShader.Fragment);
        material.compile();

        material.registerAttribute('position', TVertexAttribute.Vec3);
        material.registerUniform('MVP', TShaderUniform.Matrix4);

        return material;
    }
    
    public static function tusk():Material {
        var material:Material = new Material('tusk');

        material.setShaderSource(Tusk.vertexShaderSrc, TShader.Vertex);
        material.setShaderSource(Tusk.fragmentShaderSrc, TShader.Fragment);
        material.compile();

        material.registerAttribute('position', TVertexAttribute.Vec2);
        material.registerAttribute('uv', TVertexAttribute.Vec2);
        material.registerAttribute('colour', TVertexAttribute.Vec4);

        material.registerUniform('VP', TShaderUniform.Matrix4);
        material.registerUniform('texture', TShaderUniform.TextureSlot);

        material.cullMode = TCullMode.None;
        material.depthTest = false;
        material.depthWrite = false;
        material.blend = true;
        material.srcBlend = TBlendFactor.SrcAlpha;
        material.dstBlend = TBlendFactor.OneMinusSrcAlpha;

        return material;
    }

    public static function standard(directionalLights:Int, pointLights:Int):Material {
        var material:Material = new Material('standard_${directionalLights}_${pointLights}');

        var vertexSrc:String = mammoth.macros.FileContents.contents('mammoth/assets/standard.vert.glsl');
        var fragSrc:String = mammoth.macros.FileContents.contents('mammoth/assets/standard.frag.glsl');

        var vertexPre:Array<String> = new Array<String>();
        var fragmentPre:Array<String> = new Array<String>();

        if(directionalLights > 0) {
            fragmentPre.push('#define UNIFORM_DIRECTIONAL_LIGHTS');
            fragmentPre.push('#define NUMBER_DIRECTIONAL_LIGHTS ${directionalLights}');
        }
        if(pointLights > 0) {
            fragmentPre.push('#define UNIFORM_POINT_LIGHTS');
            fragmentPre.push('#define NUMBER_POINT_LIGHTS ${pointLights}');
        }

        vertexSrc = vertexPre.join('\n') + '\n' + vertexSrc;
        fragSrc = fragmentPre.join('\n') + '\n' + fragSrc;

        material.setShaderSource(vertexSrc, TShader.Vertex);
        material.setShaderSource(fragSrc, TShader.Fragment);
        material.compile();

        material.registerAttribute('position', TVertexAttribute.Vec3);
        material.registerAttribute('normal', TVertexAttribute.Vec3);

        material.registerUniform('MVP', TShaderUniform.Matrix4);
        material.registerUniform('M', TShaderUniform.Matrix4);

        material.registerUniform('albedoColour', TShaderUniform.Vector3);
        material.registerUniform('ambientColour', TShaderUniform.Vector3);

        for(i in 0...directionalLights) {
            material.registerUniform('directionalLights[${i}].direction', TShaderUniform.Vector3);
            material.registerUniform('directionalLights[${i}].colour', TShaderUniform.Vector3);
        }
        for(i in 0...pointLights) {
            material.registerUniform('pointLights[${i}].position', TShaderUniform.Vector3);
            material.registerUniform('pointLights[${i}].colour', TShaderUniform.Vector3);
            material.registerUniform('pointLights[${i}].distance', TShaderUniform.Float);
        }

        return material;
    }
}