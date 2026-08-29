{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "yotux";
      user.email = "github@msgnate.com";
      init.defaultBranch = "main";
    };
  };
}
