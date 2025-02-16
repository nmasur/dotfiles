# Return a list of all hosts

{
  darwin-hosts = import ./darwin;
  linux-hosts = import ./nixos;
}
