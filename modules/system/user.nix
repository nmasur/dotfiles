{ user, ... }: {

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {

    # Create a home directory for human user
    isNormalUser = true;

    # Automatically create a password to start
    initialPassword = "changeme";

    extraGroups = [
      "wheel" # Sudo privileges
    ];

  };

}
