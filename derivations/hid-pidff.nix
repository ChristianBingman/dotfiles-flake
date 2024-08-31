{ stdenv, lib, fetchFromGitHub, linuxPackages, kernel }:

stdenv.mkDerivation {
  pname = "hid-pidff";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "JacKeTUs";
    repo = "universal-pidff";
    rev = "0.0.5";
    hash = "sha256-W30AoC42Laq/OpsGy2tflrQkwlM0TKQMDtyhUl7xF3s=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installFlags = [
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  postPatch = "sed -i '/depmod -A/d' Makefile";
}
