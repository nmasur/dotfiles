{ pkgs, writeShellApplication }:

writeShellApplication {
  name = "ocr";
  runtimeInputs = [ pkgs.tesseract ];
  text = builtins.readFile ./ocr.sh;
}
