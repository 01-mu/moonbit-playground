const { instance } = await WebAssembly.instantiateStreaming(
  fetch("engine.wasm"),
  {}
)

let state = instance.exports.tl_init()

setInterval(() => {
  state = instance.exports.tl_step(state, 100) // dt = 100ms
  const light = instance.exports.tl_light(state)
  console.log("light =", light) // 0/1/2
}, 100)
