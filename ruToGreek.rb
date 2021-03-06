#!/usr/bin/env ruby
table = { 
  "А" => "Α",
  "Б" => "Β",
  "В" => "ν",
  "Г" => "Γ",
  "Д" => "Δ",
  "Е" => "",
  "Ж" => "",
  "З" => "",
  "И" => "",
  "К" => "",
  "Л" => "",
  "М" => "Μ",
  "Н" => "",
  "О" => "",
  "П" => "",
  "Р" => "Ρ",
  "С" => "Σ",
  "Т" => "",
  "У" => "Υ",
  "Ф" => "",
  "Х" => "",
  "Ц" => "",
  "Ч" => "",
  "Ш" => "",
  "Щ" => "",
  "Э" => "",
  "Ю" => "",
  "Я" => "",
  "а" => "α",
  "б" => "β",
  "в" => "Β",
  "г" => "γ",
  "д" => "δ",
  "е" => "ε",
  "ж" => "ψ",
  "з" => "ζ",
  "и" => "ι",
  "к" => "κ",
  "л" => "λ",
  "м" => "μ",
  "н" => "η",
  "о" => "ο",
  "п" => "π",
  "р" => "ρ",
  "с" => "σ",
  "т" => "τ",
  "у" => "γ",
  "ф" => "φ",
  "х" => "χ",
  "ц" => "ζ",
  "ч" => "χ",
  "ш" => "ω",
  "щ" => "ω",
  "э" => "ξ",
  "ю" => "ψ",
  "я" => "α",
}

table = table.reject { |ruChar, greekChar|
  greekChar == ""
}

STDOUT.write(STDIN.read.split("").map { |char| table[char] or char }.join(""))