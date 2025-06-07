with import <nixpkgs> { };
(python3.withPackages (ps: [
  ps.ipython
  ps.numpy
  ps.toolz
  ps.matplotlib
  ps.pyqt5
])).env
