# Return a list of all hosts

{
  darwin-hosts = import ./aarch64-darwin;
  linux-hosts = import ./x86_64-linux // import ./aarch64-linux;
}
