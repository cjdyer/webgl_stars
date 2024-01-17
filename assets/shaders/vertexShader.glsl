#version 300 es

in vec4 inputPosition;
out vec4 vertexPosition;

void main() {
    vertexPosition = inputPosition;
    // Set the position for rasterization in the graphics pipeline
    gl_Position = inputPosition;
}
