{
  config,
  pkgs,
  ...
}: {
  users.users.user = {
    uid = 1001;
    isNormalUser = true;
    extraGroups = ["networkmanager" "transmission" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhpo7VxrrMzX3b8QZJpyApti/0ujjZZP7GdIF+uMc+ymr783Yry4eOgCJTe17PUgz5yCgxFsWUIA7ZASU8Efau2Th/OqbN0w/kj4x2vEPv6Fp8qAv+BEbeKHtBtrRw8CbZe247No+HA6V5W/hJkdy9XWOTQDP8WUUCTtNoX9XVd/+b7AhGf/FP2RuhA52CqsSh9wGVXmIrWONWRaYSyRZgsE/RKjJxm4DogBjIB8tJSAvSfC9c7s/4Zi5JQPQYIk1V48sEyA0LX77wWpe7MLJ4NbYFQSgX525cCkZJb8v2EnDHJmFj9ZS+HxfucmOijVNNuNVKeBjS8GMtQtIr8pK3 reinis@home-desktop-debian"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5SV9eWOEcf37wKPqz0G/2kwtd7Xpi/JkkjP8sZR324+J7ItxIxlD7Q9KHBS5VgVQZm0sIm/mmJfUHs5L4bWxgXLDBOGOojm2jpq16FFG3GIFd+8w3oPZ7KX1ivczAzZsm/ehrKxkApTTaicD5iZppNErppZXhwvehpcuqlh5rMgHLU0uphnAR/3euc7GRa2es97mHSHukBMe1zxoa+sZF4aWnMDVeRFmi04xE5dr2235vnL++16ObRUXmTLKfK/JnnkHY9neRdq56WcG28swa2w60wo8Y5ebAyt3l9FVY1yn1FmgI4alDpXzkE/rNkqKY4Uim6tYoMooCAXtaNVmkkmOpuD7Y96oPV9qiVez61OazXW3tcwsV9OMI9FSr4smVo9TQsnzQXDWpoRPSqmLFoFDvEd7Mdl34EzmZs61Kt99CKgUEKk1UfN7DTdlbjKb+qMSM1zHLWqdHkM5z2GVgfuFAJjW+MUyjbvlL4eZlTr4+FcT2qMjpHJY82CCB4RE= reinis@home-desktop-nixos"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$uGuICoNs0EtiuMV2$eAKUHjc5HyrrC/1PmSQpBhI32KHGGRn0b4Gs2bCeOcoPwAhIxv6aFst7WBSeIY3/3uw.ZuI0cGND2ild5gP7P/";
  };
}
