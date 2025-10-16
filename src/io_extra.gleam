import gleam/io
import gleam/string

pub fn debug(thing) {
  string.inspect(thing)
  |> io.println
}
