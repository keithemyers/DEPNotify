# DEPNotify

Items that must be installed in a specific order are configured here, then executed in order while displaying status to the user.

- Prevents race conditions
- Allows certain items to complete prior to end-user usage
- Highly customizable

## Added Features
Several features have been added by i-Tech
- Once the policy array has been iterated, each critical component is double checked
- Re-runs associated policy if the condition isn't met
- Generates a checklist for the school tech and saves it locally
- Creates a launch agent to display the checklist in full screen after the initial reboot
- An alert can be played to get the user's attention if needed
- Checks for the existence of a SecureToken and adds this to the checklist 
