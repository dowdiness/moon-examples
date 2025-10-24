// https://nodejs.org/ja/learn/getting-started/nodejs-with-webassembly
// https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Understanding_the_text_format

// Assume add.wasm file exists that contains a single function adding 2 provided arguments
import fs from 'node:fs/promises';
// Use readFile to read contents of the "add.wasm" file
const wasmBuffer = await fs.readFile('./add.wasm');
// Use the WebAssembly.instantiate method to instantiate the WebAssembly module
const wasmModule = await WebAssembly.instantiate(wasmBuffer);
// Exported function lives under instance.exports object
const { add } = wasmModule.instance.exports;
const sum = add(5, 6);
console.log(sum); // Outputs: 11
