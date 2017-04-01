package mammoth.defaults;

import mammoth.render.Material;
import mammoth.render.Attribute;
import mammoth.render.TAttribute;
import mammoth.render.TUniform;

class Materials {
    public static function shadow():Material {
        var mat:Material = new Material('shadow');

        var vertexSrc:String = mammoth.macros.FileContents.contents('mammoth/assets/shadow.vert.glsl');
        var fragSrc:String = mammoth.macros.FileContents.contents('mammoth/assets/shadow.frag.glsl');

        mat.setVertexShader(vertexSrc);
        mat.setFragmentShader(fragSrc);

        mat.registerAttribute('position', new Attribute('position', TAttribute.Vec3, 6*3, 0));
        mat.registerAttribute('normal', new Attribute('normal', TAttribute.Vec3, 6*3, 3*3));

        mat.compile();

        var m4:Mat4 = glm.Mat4.identity(new glm.Mat4());
        mat.setUniform('MVP', TUniform.Mat4(m4));

        return mat;
    }
}