{ lib, python3Packages }:

let
  pyproject = lib.importTOML ../pyproject.toml;
in
python3Packages.buildPythonApplication {
  pname = "spark-doctor";
  inherit (pyproject.project) version;
  pyproject = true;

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../pyproject.toml
      ../README.md
      ../LICENSE
      ../src
      ../tests
    ];
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    typer
    rich
    pydantic
    pyyaml
    psutil
  ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  pythonImportsCheck = [ "spark_doctor" ];

  # The collectors shell out to nvidia-smi, docker, journalctl and friends.
  # Those come from the host on purpose rather than being wrapped into PATH:
  # the tool diagnoses the system's own driver and runtime, and a pinned
  # copy from the Nix store would report on itself instead.

  meta = {
    description = pyproject.project.description;
    homepage = "https://github.com/joeynyc/spark-doctor";
    license = lib.licenses.mit;
    mainProgram = "spark-doctor";
    platforms = lib.platforms.linux;
  };
}
