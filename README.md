# moonbit-playground


```sh
cd engine
moon check
moon build --target wasm

cd ..
find . -name "*.wasm"
cp engine/target/wasm/release/build/src/main/main.wasm web/engine.wasm

cd web
python -m http.server 8000
```
