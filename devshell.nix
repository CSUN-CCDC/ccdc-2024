{ pkgs ? import <nixpkgs> { }, pkgs-vagrant }:

let

  # Vagrant 2.4.1 build that works (newer nix builds are broken), but is BSL rather than FOSS
  #   pkgs-vagrant = import (fetchTarball {
  #     url = "https://github.com/nixos/nixpkgs/archive/05bbf675397d5366259409139039af8077d695ce.tar.gz";
  #     sha256 = "1r26vjqmzgphfnby5lkfihz6i3y70hq84bpkwd43qjjvgxkcyki0";
  #
  #     }) {
  #         config.allowUnfree = true;
  #         system = "${pkgs.system}";};
  my-python-packages = ps: with ps; [
    ansible
    ansible-core
    molecule
    molecule-plugins
    dnspython
    jmespath
    pywinrm
    sqlalchemy
    mysqlclient
    psycopg2
    requests
    pyopenssl
    pymongo
    # other python packages
  ];
  #vagrantPackage = if builtins.pathExists /etc/wsl.conf then "" else "vagrant";
  vagrantDefaultProvider = if builtins.pathExists /etc/wsl.conf then "virtualbox" else "libvirt";

in
with pkgs;
mkShell {
  LC_ALL = "C.UTF-8";
  LANG = "C.UTF-8";
  ANSIBLE_HOST_KEY_CHECKING = "False";
  # PYTHONPATH = "${pkgs.python312.withPackages my-python-packages}/bin/python"; 
  VAGRANT_WSL_ENABLE_WINDOWS_ACCESS = "1";
  VAGRANT_DEFAULT_PROVIDER = "${vagrantDefaultProvider}";
  TEST_ENV = "${system}";
  buildInputs = [
    podman
    podman-compose
    pkgs-vagrant.legacyPackages.${system}.vagrant
    openssh
    sshpass
    sshs
    (pkgs.python312.withPackages my-python-packages)
    ansible-lint
  ];
}
