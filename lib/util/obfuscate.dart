String obfuscateMobile(String value, [int visibleLength = 4]) {
  int hiddenLength = value.length - visibleLength;
  return value.replaceRange(0, hiddenLength, "".padLeft(hiddenLength, "X"));
}
