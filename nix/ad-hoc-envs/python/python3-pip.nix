with import <nixpkgs> { };
with pkgs.python3Packages;
stdenv.mkDerivation {
  name = "impurePythonEnv";
  buildInputs = [
    # these packages are required for virtualenv and pip to work:
    #
    python3Full
    python3Packages.virtualenv
    python3Packages.pip
    # the following packages are related to the dependencies of your python
    # project.
    # In this particular example the python modules listed in the
    # requirements.tx require the following packages to be installed locally
    # in order to compile any binary extensions they may require.
    #
    python3Packages.pillow
    python3Packages.opencv3
    numpy
    #dlib
    stdenv
    git
    cmake
  ];
  src = null;
  shellHook = ''
    # set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)
    export PYTHONPATH=venv/lib/python3.6/site-packages/:$PYTHONPATH
    virtualenv --no-setuptools venv
    export PATH=$PWD/venv/bin:$PATH
    pip install -r requirements.txt
  '';
}
