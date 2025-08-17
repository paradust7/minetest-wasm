var Module = typeof Module != "undefined" ? Module : {};

Module['print'] = (text) => {
    postMessage({cmd: 'callHandler', handler: 'print', args: [text]});
};

Module['printErr'] = (text) => {
  postMessage({cmd: 'callHandler', handler: 'printErr', args: [text]});
};

importScripts('minetest.js');
