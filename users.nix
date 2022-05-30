{ ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    extraGroups = [
      "networkmanager"

      # Enable ‘sudo’ for the user.
      "wheel"
    ];
    isNormalUser = true;
  };

}
