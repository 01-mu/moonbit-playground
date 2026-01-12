// Export thin wrappers for the web demo.

pub fn tl_init() -> Int {
  initPacked()
}

pub fn tl_step(state: Int, dtMs: Int) -> Int {
  stepPacked(state, dtMs)
}

pub fn tl_light(state: Int) -> Int {
  lightOf(state)
}

// Dummy main (required because is-main = true)
fn main { () }
