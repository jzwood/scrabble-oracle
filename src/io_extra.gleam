import gleam/io
import gleam/string

pub fn debug(thing) -> thing {
  string.inspect(thing) |> io.println
  thing
}
