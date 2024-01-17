import vertexShaderSrc from '../assets/shaders/vertexShader.glsl';
import fragmentShaderSrc from '../assets/shaders/fragmentShader.glsl';

const shaderVariables = {
    ["resolution"]: "vec2",
    ["angle"]: "vec2",
    ["time"]: "float",
};

export default function Renderer() {
    const { gl, program } = createGraphics();

    this.setShaderVariable = (name, value) => {
        const location = gl.getUniformLocation(program, name);

        switch (shaderVariables[name]) {
            case "vec2":
                gl.uniform2fv(location, new Float32Array(value));
                break;
            case "float":
                gl.uniform1f(location, value);
                break;
            default:
                throw new Error("Unknown Uniform type: " + type);
        }
    }

    this.draw = () => {
        gl.drawArrays(gl.TRIANGLES, 0, 6);
    }
}

function createGraphics() {
    const canvas = document.createElement("canvas");

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    document.body.appendChild(canvas);

    canvas.onclick = () => canvas.requestPointerLock();

    const gl = canvas.getContext("webgl2");

    function compileShader(src, type) {
        const shader = gl.createShader(type);

        gl.shaderSource(shader, src);
        gl.compileShader(shader);
        
        if (gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            return shader;
        }

        throw new Error('Shader compile failed with: ' + gl.getShaderInfoLog(shader));
    }

    const program = gl.createProgram();

    gl.attachShader(program, compileShader(vertexShaderSrc, gl.VERTEX_SHADER));
    gl.attachShader(program, compileShader(fragmentShaderSrc, gl.FRAGMENT_SHADER));

    gl.linkProgram(program);
    gl.useProgram(program);

    const positionBuffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, -1, 1, 1, 1, 1, 1, 1, -1, -1, -1]), gl.STATIC_DRAW);

    const positionAttribLocation = gl.getAttribLocation(program, "inputPosition");
    const vertexArray = gl.createVertexArray();

    gl.bindVertexArray(vertexArray);
    gl.enableVertexAttribArray(positionAttribLocation);
    gl.vertexAttribPointer(positionAttribLocation, 2, gl.FLOAT, false, 0, 0);

    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    return { gl, program };
}