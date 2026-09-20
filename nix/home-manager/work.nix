{ pkgs, ... }:
let
  # For ips-minilab/leeroy/deploy-mma.sh
  # We need Ansible 2.18; Ansible 11.3 bundles community.general 10.4.0.
  ipsDeployPython = pkgs.python312.override {
    packageOverrides = _: prev: {
      ansible = prev.ansible.overridePythonAttrs {
        version = "11.3.0";
        src = pkgs.fetchPypi {
          pname = "ansible";
          version = "11.3.0";
          hash = "sha256-kLQJ9jDcbVWCJECaOUgxTt4bzabbLQPBdwjO9hF6YQM=";
        };
      };
      ansible-core = prev.ansible-core.overridePythonAttrs {
        version = "2.18.3";
        src = pkgs.fetchPypi {
          pname = "ansible_core";
          version = "2.18.3";
          hash = "sha256-jE6spAhFI44mAbm8nb+9T27TUCy4smMnifdc5Hir/e4=";
        };
      };
    };
  };
in
{
  home.packages = with pkgs; [
    curl
    dbeaver-bin
    docker-client
    # # https://github.com/NixOS/nixpkgs/issues/182856#issuecomment-3009621304
    # (google-cloud-sdk.withExtraComponents (
    #   with google-cloud-sdk.components;
    #   [
    #     gke-gcloud-auth-plugin
    #   ]
    # ))
    jetbrains.idea
    jetbrains.pycharm
    kubectl
    kubelogin-oidc
    kube-capacity
    k9s
    minikube
    postgresql
    stern
    rsync

    (ipsDeployPython.withPackages (ps: [
      ps.ansible-core
      ps.jinja2
      ps.kubernetes
      ps.pyyaml
    ]))
  ];

  home.sessionVariables.DEVRUN_PI_PROFILE = "work";
}
