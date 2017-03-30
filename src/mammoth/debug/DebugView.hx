package mammoth.debug;

import js.html.ImageElement;
import mammoth.gl.Shader;
import mammoth.gl.Program;
import mammoth.gl.UniformLocation;
import mammoth.gl.Buffer;
import mammoth.gl.Texture;
import tusk.Tusk;
import mammoth.gl.GL;

class DebugView {
    private var program:Program;
    private var buffer:Buffer;
    private var fontImage:ImageElement;
    private var fontTexture:Texture;

    private var positionLoc:Int = 0;
    private var uvLoc:Int = 0;
    private var colourLoc:Int = 0;

    private var vpLoc:UniformLocation;
    private var textureLoc:UniformLocation;

    public function new() {
        // compile the vertex shader
        var vert:Shader = Mammoth.gl.createShader(GL.VERTEX_SHADER);
        Mammoth.gl.shaderSource(vert, Tusk.vertexShaderSrc);
        Mammoth.gl.compileShader(vert);
		if(!Mammoth.gl.getShaderParameter(vert, GL.COMPILE_STATUS)) {
			var info:String = Mammoth.gl.getShaderInfoLog(vert);
			throw new Exception(info, true, 'CompileVertShader');
		}

        // compile the fragment shader
        var frag:Shader = Mammoth.gl.createShader(GL.FRAGMENT_SHADER);
        Mammoth.gl.shaderSource(frag, Tusk.fragmentShaderSrc);
        Mammoth.gl.compileShader(frag);
		if(!Mammoth.gl.getShaderParameter(frag, GL.COMPILE_STATUS)) {
			var info:String = Mammoth.gl.getShaderInfoLog(frag);
			throw new Exception(info, true, 'CompileFragShader');
		}

        // compile the program
        program = Mammoth.gl.createProgram();
        Mammoth.gl.attachShader(program, vert);
        Mammoth.gl.attachShader(program, frag);
        Mammoth.gl.linkProgram(program);
		if(!Mammoth.gl.getProgramParameter(program, GL.LINK_STATUS)) {
			var info:String = Mammoth.gl.getProgramInfoLog(program);
			throw new Exception(info, true, 'LinkProgram');
		}

        // bind the attributes
        Mammoth.gl.useProgram(program);
        positionLoc = Mammoth.gl.getAttribLocation(program, 'position');
        uvLoc = Mammoth.gl.getAttribLocation(program, 'uv');
        colourLoc = Mammoth.gl.getAttribLocation(program, 'colour');

        // find the uniform
        vpLoc = Mammoth.gl.getUniformLocation(program, 'VP');

        // create the texture
        fontTexture = Mammoth.gl.createTexture();
        Mammoth.gl.bindTexture(GL.TEXTURE_2D, fontTexture);

        // temporarily create a 1x1 magenta 'loading' texture
        Mammoth.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE,
              new js.html.Uint8Array([255, 0, 255, 255]));
        textureLoc = Mammoth.gl.getUniformLocation(program, 'texture');

        // load the image asynchronously
        fontImage = js.Browser.window.document.createImageElement();
        fontImage.addEventListener('load', function() {
            Mammoth.gl.bindTexture(GL.TEXTURE_2D, fontTexture);
            //Mammoth.gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
            Mammoth.gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
            //Mammoth.gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, fontImage);
            Mammoth.gl.context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, fontImage);
        });
        fontImage.src = Tusk.fontTextureSrc;

        // create the buffer
        buffer = Mammoth.gl.createBuffer();

        // finish up
        Mammoth.gl.useProgram(null);
    }

    public function draw():Void {
        Mammoth.gl.viewport(0, 0, Std.int(Mammoth.width), Std.int(Mammoth.height));
        Mammoth.gl.scissor(0, 0, Std.int(Mammoth.width), Std.int(Mammoth.height));

        Tusk.draw.screenWidth = mammoth.Mammoth.width;
        Tusk.draw.screenHeight = mammoth.Mammoth.height;

        if(Tusk.draw.numVertices == 0) return;
        
        Mammoth.gl.disable(GL.CULL_FACE);
        Mammoth.gl.disable(GL.DEPTH_TEST);

        Mammoth.gl.enable(GL.BLEND);
        Mammoth.gl.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

        Mammoth.gl.useProgram(program);

        Mammoth.gl.bindBuffer(GL.ARRAY_BUFFER, buffer);
        Mammoth.gl.bufferData(GL.ARRAY_BUFFER, Tusk.draw.buffer, GL.DYNAMIC_DRAW);

        Mammoth.gl.uniformMatrix4fv(vpLoc, cast(Tusk.draw.vpMatrix));
        Mammoth.gl.uniform1i(textureLoc, 0);

        Mammoth.gl.activeTexture(GL.TEXTURE0);
        Mammoth.gl.bindTexture(GL.TEXTURE_2D, fontTexture);

        Mammoth.gl.enableVertexAttribArray(positionLoc);
        Mammoth.gl.vertexAttribPointer(positionLoc, 2, GL.FLOAT, false, 8*4, 0);
        Mammoth.gl.enableVertexAttribArray(uvLoc);
        Mammoth.gl.vertexAttribPointer(uvLoc, 2, GL.FLOAT, false, 8*4, 2*4);
        Mammoth.gl.enableVertexAttribArray(colourLoc);
        Mammoth.gl.vertexAttribPointer(colourLoc, 4, GL.FLOAT, false, 8*4, 4*4);

        Mammoth.gl.drawArrays(GL.TRIANGLES, 0, Tusk.draw.numVertices);
    }
}