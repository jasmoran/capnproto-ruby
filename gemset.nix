{
  language_server-protocol = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gvb1j8xsqxms9mww01rmdl78zkd72zgxaap56bhv8j45z05hp1x";
      type = "gem";
    };
    version = "3.17.0.3";
  };
  prism = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pgxgng905jbhp0pr54w4w2pr4nqcq80ijj48204bj4x4nigj8ji";
      type = "gem";
    };
    version = "0.24.0";
  };
  ruby-lsp = {
    dependencies = ["language_server-protocol" "prism" "sorbet-runtime"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13i4kgp9k2rqcwgpxf5cnfizfxg0qc76mwgar0ch08v92i0zn801";
      type = "gem";
    };
    version = "0.16.4";
  };
  sorbet-runtime = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f8rdp71270a0vhccc8bh7wx0rr8l6xnvg5r9617pvn0czm8rmv5";
      type = "gem";
    };
    version = "0.5.11342";
  };
}
