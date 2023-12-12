#include <charconv>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <optional>
#include <string>

namespace fs = std::filesystem;

const std::size_t fence(const std::size_t val, const std::size_t fallback) {
  return val == std::string_view::npos ? fallback : val;
}

// only 12 red cubes, 13 green cubes, and 14 blue cubes
// Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
std::optional<int> processLine(std::string_view s) {
  const auto colon = s.find(':');
  auto contents = s.substr(colon + 2);
  while (true) {
    const auto semicolon = contents.find(';');  // needs fence
    auto cur_contents = contents.substr(0, fence(semicolon, contents.length()));

    while (true) {
      const auto comma = cur_contents.find(',');  // needs fence

      const auto space = cur_contents.find(' ');

      int num;
      const auto res = std::from_chars(cur_contents.data(),
                                       cur_contents.data() + space, num);
      const auto color = cur_contents.substr(
          space + 1,
          fence(comma, fence(semicolon, cur_contents.length())) - (space + 1));
      if (num > ("blue" == color ? 14 : "green" == color ? 13 : 12)) {
        return {};
      }

      if (comma == std::string_view::npos) {
        break;
      }

      cur_contents = cur_contents.substr(comma + 2);
    }

    if (semicolon == std::string_view::npos) {
      break;
    }

    contents = contents.substr(semicolon + 2);
  }

  const auto space = s.find(' ');
  int game_id{0};
  const auto res =
      std::from_chars(s.data() + space + 1, s.data() + colon, game_id);

  return game_id;
}

int main() {
  const fs::path cwd =
      fs::path{std::getenv("HOME")} / "source" / "advent-of-code-2023";

  std::ifstream infile{cwd / "day2.txt"};
  if (!infile) {
    std::cerr << "Can't find file" << std::endl;
    return 1;
  }

  std::string line;
  int sum = 0;
  while (std::getline(infile, line)) {
    const auto opt_id = processLine(line);
    if (opt_id) {
      sum += *opt_id;
    }
  }
  std::cout << "sum: " << sum << std::endl;
}
