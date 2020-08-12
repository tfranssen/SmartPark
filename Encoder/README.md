# Manual en/decoder

## How I use it:

* Clone dir using `Git clone`
* Open Dir in VS Code
* Edit settings in `createjson.py` as you like
* Run `python createjson.py` in terminal to create a valid JSON file. Its written to `settings.json`

### For encoding:
* Run `node encoder.js`. Output is printed in terminal in Hex and Base64

### For decoding
* In `decoder.js`:
  * Paste Base64 using `console.log(Decoder(Base64strToHexBuffer(<PayloadBase64>),12));` on line `170`
  * Paste Hex using `console.log(Decoder(<PayloadHex>));` on line `170`
* Run `node decoder.js`
* Output is printed to console


