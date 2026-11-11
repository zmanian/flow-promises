// Quint gives a sum type value as { Tag: payload }.
const tag = (value: object) => Object.keys(value)[0];

export const title = "Onboarding";

export const state = (v: { screen: object; saving: boolean }) =>
  v.saving ? `${tag(v.screen)}, saving` : tag(v.screen);

const steps: Record<string, string | null> = {
  YouPressGetStarted: "you press Get started",
  YouPressSave: "you press Save",
  TheSaveSucceeds: "the save succeeds",
  TheSaveFails: "the save fails",
  YouPressSendInvites: "you press Send invites",
  YouPressSkip: "you press Skip",
  Done: null,
};
export const step = (action: string) => steps[action] ?? action;
