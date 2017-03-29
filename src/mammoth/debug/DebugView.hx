package mammoth.debug;

import js.html.ImageElement;
import js.html.webgl.RenderingContext;
import js.html.webgl.Shader;
import js.html.webgl.Program;
import js.html.webgl.UniformLocation;
import js.html.webgl.Buffer;
import js.html.webgl.Texture;
import tusk.Tusk;
import mammoth.gl.GL;

class DebugView {
    private var context:RenderingContext;
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
        context = mammoth.Mammoth.gl.context;

        // compile the vertex shader
        var vert:Shader = context.createShader(GL.VERTEX_SHADER);
        context.shaderSource(vert, Tusk.vertexShaderSrc);
        context.compileShader(vert);
		if(!context.getShaderParameter(vert, GL.COMPILE_STATUS)) {
			var info:String = context.getShaderInfoLog(vert);
			throw new Exception(info, true, 'CompileVertShader');
		}

        // compile the fragment shader
        var frag:Shader = context.createShader(GL.FRAGMENT_SHADER);
        context.shaderSource(frag, Tusk.fragmentShaderSrc);
        context.compileShader(frag);
		if(!context.getShaderParameter(frag, GL.COMPILE_STATUS)) {
			var info:String = context.getShaderInfoLog(frag);
			throw new Exception(info, true, 'CompileFragShader');
		}

        // compile the program
        program = context.createProgram();
        context.attachShader(program, vert);
        context.attachShader(program, frag);
        context.linkProgram(program);
		if(!context.getProgramParameter(program, GL.LINK_STATUS)) {
			var info:String = context.getProgramInfoLog(program);
			throw new Exception(info, true, 'LinkProgram');
		}

        // bind the attributes
        context.useProgram(program);
        positionLoc = context.getAttribLocation(program, 'position');
        uvLoc = context.getAttribLocation(program, 'uv');
        colourLoc = context.getAttribLocation(program, 'colour');

        // find the uniform
        vpLoc = context.getUniformLocation(program, 'VP');

        // create the texture
        fontTexture = context.createTexture();
        context.bindTexture(GL.TEXTURE_2D, fontTexture);

        // temporarily create a 1x1 magenta 'loading' texture
        context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 1, 1, 0, GL.RGBA, GL.UNSIGNED_BYTE,
              new js.html.Uint8Array([255, 0, 255, 255]));
        textureLoc = context.getUniformLocation(program, 'texture');

        // load the image asynchronously
        fontImage = js.Browser.window.document.createImageElement();
        fontImage.addEventListener('load', function() {
            context.bindTexture(GL.TEXTURE_2D, fontTexture);
            //context.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
            context.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
            context.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
            context.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
            context.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
            context.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, fontImage);
        });
        fontImage.src = Tusk.fontTextureSrc;

        // create the buffer
        buffer = context.createBuffer();

        // finish up
        context.useProgram(null);
    }

    public function draw():Void {
        context.viewport(0, 0, Std.int(Mammoth.width), Std.int(Mammoth.height));
        context.scissor(0, 0, Std.int(Mammoth.width), Std.int(Mammoth.height));

        Tusk.draw.screenWidth = mammoth.Mammoth.width;
        Tusk.draw.screenHeight = mammoth.Mammoth.height;

        if(Tusk.draw.numVertices == 0) return;
        
        context.disable(GL.CULL_FACE);
        context.disable(GL.DEPTH_TEST);

        context.enable(GL.BLEND);
        context.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

        context.useProgram(program);

        context.bindBuffer(GL.ARRAY_BUFFER, buffer);
        context.bufferData(GL.ARRAY_BUFFER, Tusk.draw.buffer, GL.DYNAMIC_DRAW);

        context.uniformMatrix4fv(vpLoc, false, cast(Tusk.draw.vpMatrix));
        context.uniform1i(textureLoc, 0);

        context.activeTexture(GL.TEXTURE0);
        context.bindTexture(GL.TEXTURE_2D, fontTexture);

        context.enableVertexAttribArray(positionLoc);
        context.vertexAttribPointer(positionLoc, 2, GL.FLOAT, false, 8*4, 0);
        context.enableVertexAttribArray(uvLoc);
        context.vertexAttribPointer(uvLoc, 2, GL.FLOAT, false, 8*4, 2*4);
        context.enableVertexAttribArray(colourLoc);
        context.vertexAttribPointer(colourLoc, 4, GL.FLOAT, false, 8*4, 4*4);

        context.drawArrays(GL.TRIANGLES, 0, Tusk.draw.numVertices);
    }
}