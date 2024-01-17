import Renderer from './renderer';

const mouseSensitivity = 1 / 1000;
const maxFramesPerSecond = 20;
const maxSecondsPerFrame = 1 / maxFramesPerSecond;
const halfPI = Math.PI / 2; 

const angle = [0, 0];

onmousemove = (event) => {
    angle[0] += event.movementX * mouseSensitivity;
    angle[1] -= event.movementY * mouseSensitivity;

    if (angle[1] >= halfPI) {
        angle[1] = halfPI;
    }
    if (angle[1] <= -halfPI) {
        angle[1] = -halfPI;
    }
}

const renderer = new Renderer();

renderer.setShaderVariable("resolution", [window.innerWidth, window.innerHeight]);

let time = performance.now() / 1000;
let secondsPerFrame = maxSecondsPerFrame;


function update(){
    try{
        secondsPerFrame = performance.now() / 1000 - time;

        if(secondsPerFrame > maxSecondsPerFrame) {
            secondsPerFrame = maxSecondsPerFrame;
        }
    
        time = performance.now() / 1000;

        renderer.setShaderVariable("angle", angle);
        renderer.setShaderVariable("time", time);

        renderer.draw();
        
        requestAnimationFrame(update);
    } catch(error) {
        console.error(error);
    }
}

update();