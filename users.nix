{ ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sahar = {
    extraGroups = [
      "adbusers"

      "docker"

      "networkmanager"

      # Enable ‘sudo’ for the user.
      "wheel"
    ];
    isNormalUser = true;
  };

}
