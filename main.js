import { default as seagulls } from './seagulls/seagulls.js';
import { default as Video    } from './seagulls/video.js';

import { Pane } from 'https://cdn.jsdelivr.net/npm/tweakpane@4.0.1/dist/tweakpane.min.js';

const sg = await seagulls.init(),
    frag = await seagulls.import( './frag.wgsl' ),
    shader = seagulls.constants.vertex + frag;

await Video.init();

const resolution = [window.innerWidth, window.innerHeight];
const mouseState = [0, 0, 0];

let timeSoFar = 0;

// tweakpane stuff
const tpParams = {
    steps: 5,
    depth: 0.0015,
    lightDirection: 0.65,
    brightness: 0.2,
    contrast: 1.0
};

const pane = new Pane();
pane.addBinding(tpParams, 'steps', {step: 1, min: 1, max: 20 }).on('change',  e => {sg.uniforms.steps = e.value;});
pane.addBinding(tpParams, 'depth', {min: 0, max: 0.005 }).on('change',  e => {sg.uniforms.depth = e.value;});
pane.addBinding(tpParams, 'lightDirection', {min: 0, max: 1 }).on('change',  e => {sg.uniforms.lightDirection = e.value;});
pane.addBinding(tpParams, 'brightness', {min: 0, max: 1 }).on('change',  e => {sg.uniforms.brightness = e.value;});
pane.addBinding(tpParams, 'contrast', {min: 0, max: 3 }).on('change',  e => {sg.uniforms.contrast = e.value;});

sg
    .uniforms({
        t: timeSoFar,
        res: resolution,
        mse: mouseState,
        steps: tpParams.steps,
        depth: tpParams.depth,
        lightDirection: tpParams.lightDirection,
        brightness: tpParams.brightness,
        contrast: tpParams.contrast
    })
    .onframe(
        () => {
            timeSoFar += 0.1;

            sg.uniforms.t = timeSoFar;
            sg.uniforms.mse = mouseState;
        }
    )
    .textures([ Video.element ])
    .render( shader )
    .run();