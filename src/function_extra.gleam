pub fn compose(f: fn(b) -> c, g: fn(a) -> b) -> fn(a) -> c {
  fn(a) { f(g(a)) }
}
