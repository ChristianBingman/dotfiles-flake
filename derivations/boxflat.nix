{ pkgs, lib, python3Packages }:

python3Packages.buildPythonApplication {
  pname = "boxflat";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Lawstorant";
    repo = "boxflat";
    rev = "1.8.0";
    hash = pkgs.lib.fakeHash;
  };

  pyproject = true;

  buildInputs = with pkgs; [ libadwaita gtk4 ];

  propagatedBuildInputs = [
    python3Packages.pyyaml
    python3Packages.pygobject3
    python3Packages.pycairo
    python3Packages.pyserial
  ];

}
