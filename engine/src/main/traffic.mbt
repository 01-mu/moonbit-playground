// Deterministic traffic light state machine.
// Packed state: (elapsedMs << 2) | light
// light: 0=Red, 1=Yellow, 2=Green

const RED: Int = 0
const YELLOW: Int = 1
const GREEN: Int = 2

const RED_MS: Int = 5000
const YELLOW_MS: Int = 2000
const GREEN_MS: Int = 5000

fn pack(light: Int, elapsedMs: Int) -> Int {
  (elapsedMs << 2) | (light & 3)
}

fn unpackLight(state: Int) -> Int {
  state & 3
}

fn unpackElapsed(state: Int) -> Int {
  state >> 2
}

fn durationMs(light: Int) -> Int {
  if light == RED { RED_MS }
  else if light == YELLOW { YELLOW_MS }
  else { GREEN_MS }
}

fn nextLight(light: Int) -> Int {
  if light == GREEN { YELLOW }
  else if light == YELLOW { RED }
  else { GREEN }
}

// Step by dtMs milliseconds (dtMs >= 0 assumed).
pub fn stepPacked(state: Int, dtMs: Int) -> Int {
  let mut light = unpackLight(state)
  let mut elapsed = unpackElapsed(state) + dtMs

  // Allow large dtMs: advance multiple phases if needed.
  while elapsed >= durationMs(light) {
    elapsed = elapsed - durationMs(light)
    light = nextLight(light)
  }

  pack(light, elapsed)
}

pub fn initPacked() -> Int {
  pack(RED, 0)
}

pub fn lightOf(state: Int) -> Int {
  unpackLight(state)
}
