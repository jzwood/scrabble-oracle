import gleam/io
import gleam/string

pub fn debug(thing, label: String) -> thing {
  { label <> ": " <> string.inspect(thing) } |> io.println
  thing
}
