// Onboarding: Welcome, then a profile you save, then invites, then Home.
module onboarding {
  type Screen = Welcome | Profile | Invite | Home

  var screen: Screen
  var saving: bool
  var profileSaved: bool

  // The controls each mock frame shows, in the mock's words.
  pure def controls(s: Screen, busy: bool): Set[str] = match s {
    | Welcome => Set("Get started", "Skip")
    | Profile => if (busy) Set("Skip") else Set("Save", "Skip")
    | Invite => Set("Send invites", "Skip")
    | Home => Set()
  }

  pure def shows(control: str, s: Screen, busy: bool): bool = control.in(controls(s, busy))

  action init = all { screen' = Welcome, saving' = false, profileSaved' = false }

  action YouPressGetStarted = all {
    shows("Get started", screen, saving),
    screen' = Profile, saving' = saving, profileSaved' = profileSaved,
  }
  action YouPressSendInvites = all {
    shows("Send invites", screen, saving),
    screen' = Home, saving' = saving, profileSaved' = profileSaved,
  }
  action YouPressSkip = all {
    shows("Skip", screen, saving),
    screen' = Home, saving' = saving, profileSaved' = profileSaved,
  }
  action YouPressSave = all {
    shows("Save", screen, saving),
    screen' = screen, saving' = true, profileSaved' = profileSaved,
  }
  action TheSaveSucceeds = all {
    saving, screen' = Invite, saving' = false, profileSaved' = true,
  }
  action TheSaveFails = all {
    saving, screen' = screen, saving' = false, profileSaved' = profileSaved,
  }
  action Done = all {
    screen == Home, not(saving),
    screen' = screen, saving' = saving, profileSaved' = profileSaved,
  }

  action step = any {
    YouPressGetStarted, YouPressSave, TheSaveSucceeds, TheSaveFails,
    YouPressSendInvites, YouPressSkip, Done,
  }

  val vars = (screen, saving, profileSaved)

  /// You can skip onboarding from every onboarding screen.
  val SkipAlwaysShown = screen != Home implies shows("Skip", screen, saving)

  /// If you keep pressing Skip, you reach Home.
  temporal YouCanAlwaysFinish =
    weakFair(YouPressSkip, vars) implies eventually(screen == Home)

  /// Once you reach Home, onboarding never pulls you back.
  temporal HomeIsFinal = always(screen == Home implies always(screen == Home))
}
