// These are relative paths
const RELEASE_DIR = '%__RELEASE_UUID__%'; // set by build_www.sh
const PACKS_DIR = RELEASE_DIR + '/packs';

const rtCSS = `
body {
  font-family: Calibri, arial, sans-serif;
  margin: 0;
  padding: none;
  background-color: black;
}

.emscripten {
  color: #aaaaaa;
  padding-right: 0;
  margin-left: auto;
  margin-right: auto;
  display: block;
}

div.emscripten {
  text-align: center;
  width: 100%;
}

/* the canvas *must not* have any border or padding, or mouse coords will be wrong */
canvas.emscripten {
  border: 0px none;
  background-color: black;
}

#progress {
  height: 45px;
  width: 300px;
}

#controls {
  display: inline-block;
  vertical-align: top;
  height: 25px;
}

#controls > *:first-child {
  border-top-left-radius: 6px;
  border-bottom-left-radius: 6px;
}

#controls > *:last-child {
  border-right-width: 1px;
  border-top-right-radius: 6px;
  border-bottom-right-radius: 6px;
}

select, input {
  height: 22px;
  padding: 1px 5px 1px 5px;
  margin: 1px 0;
  font-family: Calibri, sans-serif, sans;
  font-weight: 600;
  outline: 0;
  cursor: pointer;
  border: 1px solid;
  border-radius: 6px;
  color: #c9d1d9;
  background-color: #21262d;
  border-color: rgba(240,246,252,0.1);
  box-shadow: rgba(27, 31, 35, 0.04) 0px 1px 0px 0px, rgba(255, 255, 255, 0.25) 0px 1px 0px 0px inset;
  transition: 0.2s cubic-bezier(0.3, 0, 0.5, 1);
  transition-property: color, background-color, border-color;
  position: relative;
  display: inline-block;
  float: left;
  border-radius: 0;
}

select:hover, input:hover {
  background-color: #30363d;
  border-color: #8b949e;
  transition-duration: 0.1s;
}

#output {
  width: 100%;
  height: 200px;
  margin: 0 auto;
  margin-top: 0px;
  border-left: 0px;
  border-right: 0px;
  padding-left: 0px;
  padding-right: 0px;
  display: block;
  background-color: black;
  color: white;
  font-family: 'Lucida Console', Monaco, monospace;
  outline: none;
}

.launchbutton {
    position: absolute;
    width: 300px;
    height: 120px;
    z-index: 10;
    font-size: 20pt;
    border-radius: 6px;
}
`;

const rtHTML = `
  <div id="header">

  <div class="emscripten">
    <span id="controls">
        <select id="resolution" onchange="fixGeometry()">
          <option value="high">High Res</option>
          <option value="medium">Medium</option>
          <option value="low">Low Res</option>
        </select>
        <select id="aspectRatio" onchange="fixGeometry()">
          <option value="any">Fit Screen</option>
          <option value="4:3">4:3</option>
          <option value="16:9">16:9</option>
          <option value="5:4">5:4</option>
          <option value="21:9">21:9</option>
          <option value="32:9">32:9</option>
          <option value="1:1">1:1</option>
        </select>
      <!-- <input type="button" value="Toggle Fullscreen" onclick="fullscreen_button()"> -->
<input id="console_button" type="button" value="Show Console" onclick="toggle_console()">
    </span>
    <span>F11 Full Screen</span>
  </div>

  <div class="emscripten">
    <progress value="0" max="100" id="progress" hidden=1></progress>
  </div>

  </div>

  <div class="emscripten">
    <canvas class="emscripten" id="canvas" oncontextmenu="event.preventDefault()" onclick="doLaunch()" tabindex=-1 width="1024" height="600">
    </canvas>
  </div>

  <div id="footer">
    <textarea id="output" rows="8" style="display: none;"></textarea>
  </div>
`;

const extraCSS = document.createElement("style");
extraCSS.innerText = rtCSS;
document.head.appendChild(extraCSS);
document.body.innerHTML = rtHTML;

var progressElement = document.getElementById('progress');

function toggle_console() {
    var button = document.getElementById('console_button');
    var element = document.getElementById('output');
    element.style.display = (element.style.display == 'block') ? 'none' : 'block';
    button.value = (element.style.display == 'none') ? 'Show Console' : 'Hide Console';
    fixGeometry();
}

var consoleElement = document.getElementById('output');
var enableTracing = false;
var consoleText = [];
var consoleLengthMax = 1000;
var consoleTextLast = 0;
var wasmReady = false;
var invokedMain = false;
var packsReady = false;
var packs = [];

// Called by MainLoop when the wasm module is ready
function emloop_ready() {
    wasmReady = true;
    emloop_invoke_main = cwrap("emloop_invoke_main", null, ["number", "number"]);
    emloop_install_pack = cwrap("emloop_install_pack", null, ["number", "number", "number"]);
    irrlicht_want_pointerlock = cwrap("irrlicht_want_pointerlock", "number");
    irrlicht_resize = cwrap("irrlicht_resize", null, ["number", "number"]);
    maybeStart();
}

function all_packs_ready() {
    packsReady = true;
    maybeStart();
}

function maybeStart() {
    if (!wasmReady || !packsReady) return;
    if (packs.length > 0) {
        for (const [name, data] of packs) {
            installPack(name, data);
        }
        packs = [];
    }
    showLaunchButton();
}

var launchButton;
function showLaunchButton() {
    if (launchButton) return;
    launchButton = document.createElement('button');
    launchButton.className = 'launchbutton';
    launchButton.innerText = 'Click to Launch';
    launchButton.addEventListener('click', doLaunch);
    document.body.appendChild(launchButton);
    fixGeometry();
}

function makeArgv(args) {
    // Assuming 4-byte pointers
    const argv = _malloc((args.length + 1) * 4);
    let i;
    for (i = 0; i < args.length; i++) {
        HEAPU32[(argv >> 2) + i] = allocateUTF8(args[i]);
    }
    HEAPU32[(argv >> 2) + i] = 0; // argv[argc] == NULL
    return [i, argv];
}

function fetchPacks() {
    const params = new URLSearchParams(window.location.search);
    fetchPack('base');
    if (params.has('gameid')) {
        const gameid = params.get('gameid');
        if (gameid != 'minetest_game' && gameid != 'devtest') {
            fetchPack(params.get('gameid'));
        }
    }
}

var pendingPacks = 0;
function fetchPack(name) {
    pendingPacks += 1;
    const xhr = new XMLHttpRequest();
    xhr.open('GET', PACKS_DIR + '/' + name + '.pack', true);
    xhr.responseType = 'arraybuffer';
    xhr.onprogress = (event) => {
        console.log(`Fetched ${event.loaded} of ${event.total}`);
    };
    xhr.onload = (event) => {
        if (xhr.status == 200 || xhr.status == 304 || xhr.status == 206 || (xhr.status == 0 && xhr.response)) {
            packs.push([name, xhr.response]);
            pendingPacks -= 1;
            if (pendingPacks == 0) {
                all_packs_ready();
            }
        } else {
            throw new Error(xhr.statusText + " : " + xhr.responseURL);
        }
    };
    xhr.send(null);
}

function installPack(name, arrayBuffer) {
    const arr = new Uint8Array(arrayBuffer);
    const data = _malloc(arr.length * arr.BYTES_PER_ELEMENT);
    HEAP8.set(arr, data);
    emloop_install_pack(allocateUTF8(name), data, arr.length);
    _free(data);
}

function parseQueryArgs() {
    const args = ['./minetest'];
    const params = new URLSearchParams(window.location.search);
    const keyList0 = ['go', 'server'];
    const keyList1 = ['name', 'gameid', 'address', 'address', 'port'];
    for (const key of keyList0) {
        if (params.has(key)) {
            args.push('--' + key);
        }
    }
    for (const key of keyList1) {
        if (params.has(key)) {
            args.push('--' + key);
            args.push(params.get(key));
        }
    }
    return args;
}

function doLaunch() {
    if (launchButton) {
        launchButton.remove();
        launchButton = null;
    }

    if (!invokedMain && wasmReady) {
        invokedMain = true;
        const args = parseQueryArgs();
        const [argc, argv] = makeArgv(args);
        emloop_invoke_main(argc, argv);
        // irrlicht initialization resets the width/height
        fixGeometry();
    }
}

var consoleDirty = false;
function consoleUpdate() {
    if (consoleDirty) {
        if (consoleText.length > consoleLengthMax) {
            consoleText = consoleText.slice(-consoleLengthMax);
        }
        consoleElement.value = consoleText.join('');
        consoleElement.scrollTop = consoleElement.scrollHeight; // focus on bottom
        consoleDirty = false;
    }
    window.requestAnimationFrame(consoleUpdate);
}
consoleUpdate();

var Module = {
    preRun: [],
    postRun: [],
    print: (function() {
        return function(text) {
            if (enableTracing) {
                console.trace(text);
            }
            consoleText.push(text + "\n");
            consoleDirty = true;
          };
    })(),
    canvas: (function() {
        var canvas = document.getElementById('canvas');

        // As a default initial behavior, pop up an alert when webgl context is lost. To make your
        // application robust, you may want to override this behavior before shipping!
        // See http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2
        canvas.addEventListener("webglcontextlost", function(e) { alert('WebGL context lost. You will need to reload the page.'); e.preventDefault(); }, false);

        return canvas;
    })(),
    setStatus: function(text) {
        if (!Module.setStatus.last) Module.setStatus.last = { time: Date.now(), text: '' };
        if (text === Module.setStatus.last.text) return;
        if (text) Module.print('[status] ' + text);

        var m = text.match(/([^(]+)\((\d+(\.\d+)?)\/(\d+)\)/);
        var now = Date.now();
        if (m && now - Module.setStatus.last.time < 30) return; // if this is a progress update, skip it if too soon
        Module.setStatus.last.time = now;
        Module.setStatus.last.text = text;
        if (m) {
          text = m[1];
          progressElement.value = parseInt(m[2])*100;
          progressElement.max = parseInt(m[4])*100;
          progressElement.hidden = false;
        } else {
          progressElement.value = null;
          progressElement.max = null;
          progressElement.hidden = true;
        }
    },
    totalDependencies: 0,
    monitorRunDependencies: function(left) {
        this.totalDependencies = Math.max(this.totalDependencies, left);
        Module.setStatus(left ? 'Preparing... (' + (this.totalDependencies-left) + '/' + this.totalDependencies + ')' : 'All downloads complete.');
    }
};

Module['printErr'] = Module['print'];
Module['onFullScreen'] = () => { fixGeometry(); };
Module.setStatus('Downloading...');
window.onerror = function(event) {
    // TODO: do not warn on ok events like simulating an infinite loop or exitStatus
    Module.print('Exception thrown, see JavaScript console');
    Module.setStatus = function(text) {
        if (text) Module.print('[status] ' + text);
    };
};
var pointerlock_pending = false;
var emloop_invoke_main;
var irrlicht_want_pointerlock;
var irrlicht_resize;

function fullscreen_button() {
    var canvas = document.getElementById('canvas');
    if (wasmReady) {
        var alsoLockPointer = irrlicht_want_pointerlock();
        // This calls Module['onFullScreen'] when finished, which calls fixGeometry.
        Module.requestFullscreen(alsoLockPointer, false);
    }
}

function resizeCanvas(width, height) {
    var canvas = document.getElementById('canvas');
    if (canvas.width != width || canvas.height != height) {
        canvas.width = width;
        canvas.height = height;
        canvas.widthNative = width;
        canvas.heightNative = height;
    }
    // Trigger SDL window resize.
    // This should happen automatically, it's disappointing that it doesn't.
    if (wasmReady) {
        irrlicht_resize(width, height);
    }
}

var resolutionSelect = document.getElementById('resolution');
var aspectRatioSelect = document.getElementById('aspectRatio');

function now() {
    return (new Date()).getTime();
}

// Only allow fixGeometry to be called every 250ms
// Firefox calls this way too often, causing flicker.
var fixGeometryPause = 0;
function fixGeometry(override) {
    if (!override && now() < fixGeometryPause) {
        return;
    }

    var canvas = document.getElementById('canvas');
    var resolution = resolutionSelect.value;
    var aspectRatio = aspectRatioSelect.value;
    var screenX;
    var screenY;

    // Prevent the controls from getting focus
    canvas.focus();

    var isFullScreen = document.fullscreenElement ? true : false;
    if (isFullScreen) {
        screenX = screen.width;
        screenY = screen.height;
    } else {
        // F11-style full screen
        var controls = document.getElementById('controls');
        var maximized = !window.screenTop && !window.screenY;
        controls.style = maximized ? 'display: none' : '';

        var headerHeight = document.getElementById('header').offsetHeight;
        var footerHeight = document.getElementById('footer').offsetHeight;
        screenX = document.documentElement.clientWidth - 6;
        screenY = document.documentElement.clientHeight - headerHeight - footerHeight - 6;
    }

    // Size of the viewport (after scaling)
    var realX;
    var realY;
    if (aspectRatio == 'any') {
        realX = screenX;
        realY = screenY;
    } else {
        var ar = aspectRatio.split(':');
        var innerRatio = parseInt(ar[0]) / parseInt(ar[1]);
        var outerRatio = screenX / screenY;
        if (innerRatio <= outerRatio) {
            realX = Math.floor(innerRatio * screenY);
            realY = screenY;
        } else {
            realX = screenX;
            realY = Math.floor(screenX / innerRatio);
        }
    }

    // Native canvas resolution
    var resX;
    var resY;
    var scale = false;
    if (resolution == 'high') {
        resX = realX;
        resY = realY;
    } else if (resolution == 'medium') {
        resX = Math.floor(realX / 1.5);
        resY = Math.floor(realY / 1.5);
        scale = true;
    } else {
        resX = Math.floor(realX / 2.0);
        resY = Math.floor(realY / 2.0);
        scale = true;
    }
    resizeCanvas(resX, resY);

    if (scale) {
        var styleWidth = realX + "px";
        var styleHeight = realY + "px";
        canvas.style.setProperty("width", styleWidth, "important");
        canvas.style.setProperty("height", styleHeight, "important");
    } else {
        canvas.style.removeProperty("width");
        canvas.style.removeProperty("height");
    }

    if (launchButton) {
        var canvasRect = canvas.getBoundingClientRect();
        var midX = Math.floor((canvasRect.top + canvasRect.bottom) / 2);
        var midY = Math.floor((canvasRect.left + canvasRect.right) / 2);
        launchButton.style.left = (midY - 300/2) + 'px';
        launchButton.style.top = (midX - 120/2) + 'px';
    }
}

window.addEventListener('load', () => { fixGeometry(); });
window.addEventListener('resize', () => { fixGeometry(); });

// Needed to prevent special keys from triggering browser actions, like
// F5 causing page reload.
document.addEventListener('keydown', (e) => {
    // Allow F11 to go full screen
    if (e.code == "F11") {
        // On Firefox, F11 is animated. The window smoothly grows to
        // full screen over several seconds. During this transition, the 'resize'
        // event is triggered hundreds of times. To prevent flickering, have
        // fixGeometry ignore repeated calls, and instead resize every 500ms
        // for 2.5 seconds. By then it should be finished.
        fixGeometryPause = now() + 2000;
        for (var delay = 100; delay <= 2600; delay += 500) {
            setTimeout(() => { fixGeometry(true); }, delay);
        }
    }
});

// Start fetching data packs
fetchPacks();

// Start loading the wasm module
const mtModuleScript = document.createElement("script");
mtModuleScript.type = "text/javascript";
mtModuleScript.src = RELEASE_DIR + "/minetest.js";
mtModuleScript.async = true;
document.body.appendChild(mtModuleScript);
