import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import simplifile

const input_path = "./inputs/day_01.txt"

type CalibrationError {
  NoTwoDigitsError
  ParseIntError
  DigitsNotFound
}

fn is_string_non_empty(input: String) -> Bool {
  bool.negate(string.is_empty(input))
}

pub fn main() {
  let assert Ok(input) = simplifile.read(from: input_path)

  let calibration_value = compute_calibration_value(input)

  case calibration_value {
    Ok(value) -> io.println(int.to_string(value))
    Error(error) -> io.println(string.inspect(error))
  }
}

fn compute_calibration_value(input: String) -> Result(Int, CalibrationError) {
  input
  |> split_input_by_line
  |> list.filter(is_string_non_empty)
  |> list.map(get_calibration_value_for_line)
  |> result.all
  |> result.map(int.sum)
}

fn split_input_by_line(input: String) -> List(String) {
  string.split(input, on: "\n")
}

fn get_calibration_value_for_line(line: String) -> Result(Int, CalibrationError) {
  line
  |> get_digits
  |> get_first_and_last_digits
  |> combine_first_and_last_digits
}

fn get_digits(line: String) -> List(Int) {
  line
  |> string.to_graphemes
  |> list.map(int.parse)
  |> result.values
}

fn get_first_and_last_digits(
  digits: List(Int),
) -> Result(List(Int), CalibrationError) {
  [list.first(digits), list.last(digits)]
  |> result.all
  |> result.replace_error(DigitsNotFound)
  |> result.try(assert_have_two_digits)
}

fn assert_have_two_digits(
  digits: List(Int),
) -> Result(List(Int), CalibrationError) {
  case list.length(digits) {
    2 -> Ok(digits)
    _ -> Error(NoTwoDigitsError)
  }
}

fn combine_first_and_last_digits(
  digits: Result(List(Int), CalibrationError),
) -> Result(Int, CalibrationError) {
  digits
  |> result.try(combine_digits)
}

fn combine_digits(digits: List(Int)) -> Result(Int, CalibrationError) {
  digits
  |> list.map(int.to_string)
  |> string.concat
  |> int.parse
  |> result.replace_error(ParseIntError)
}
