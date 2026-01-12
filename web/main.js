const out = document.getElementById("out");
const btn = document.getElementById("run");

btn.addEventListener("click", async () => {
  const res = await fetch("./engine.wasm");
  const bytes = await res.arrayBuffer();
  const { instance } = await WebAssembly.instantiate(bytes);

  // MoonBit 側で link.wasm.exports に ["add"] を指定している前提
  const add = instance.exports.add;
  if (typeof add !== "function") {
    out.textContent = `Export "add" not found. Exports: ${Object.keys(instance.exports).join(", ")}`;
    return;
  }

  out.textContent = `add(2, 3) => ${add(2, 3)}`;
});

