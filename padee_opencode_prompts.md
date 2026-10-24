# Padee – opencode Prompt Pack

## အသုံးပြုပုံ (မြန်မာလို)

- Prompt တွေကို **အင်္ဂလိပ်လို** ရေးထားတယ်။ Free AI model တွေက အင်္ဂလိပ် instruction ကို ပိုတိတိကျကျ လိုက်နာလို့ပါ။ App ထဲမှာ ပေါ်မယ့် စာတွေကိုတော့ မြန်မာလို သတ်မှတ်ပေးထားတယ်။
- **တစ်ခါမှာ prompt တစ်ခုပဲ** ပေးပါ။ ပြီးရင် `flutter analyze` ပြီး app ကို run ကြည့်ပါ။ အဆင်ပြေမှ နောက် prompt ကိုသွားပါ။ Error ရှိရင် error စာကို အကုန် copy ကူးပြီး "Fix these errors" ဆိုပြီး AI ကို ပြန်ပေးပါ။
- Prompt 0 ကို project root မှာ `AGENTS.md` ဖိုင်အဖြစ် သိမ်းထားပါ။ opencode က ဒီဖိုင်ကို အမြဲဖတ်ပေးတယ်။ ဒါဆို prompt တိုင်းမှာ အကြောင်းအရာ ပြန်ရှင်းစရာ မလိုတော့ဘူး။
- Firebase ချိတ်တဲ့အဆင့် (Prompt 8) ကို မစခင် **ခင်ဗျားကိုယ်တိုင်** `flutterfire configure` လုပ်ပြီးမှ AI ကို ခိုင်းပါ။ အဲဒီအဆင့်ကို AI မလုပ်စေပါနဲ့။
- ဒီ prompt တွေ စီမံထားတဲ့ အစီအစဉ်:
  0. AGENTS.md (project rules)
  1. File ခွဲခြင်း (refactor, behavior မပြောင်း)
  2. Theme + Navigation + Plan list UI
  3. Counter screen UI
  4. Plan create/edit (benefits, author, reminder fields ပါ)
  5. ရက်ပြည့်ပြီးနောက် confirm flow
  6. History
  7. Reminder (local notification)
  8. Firebase စတင်ချိတ်ခြင်း + Auth
  9. Plan ကို public တင်ခြင်း
  10. Explore (public plans) + download + participants
  11. Reviews / အကျိုးထူးမှတ်တမ်း comments
  12. Firestore security rules
  13. (Optional) ကိုယ့် plan/progress ကို cloud backup

---

## Prompt 0 — AGENTS.md (project root မှာ သိမ်းပါ)

```markdown
# Project: Padee (Flutter app)

A Burmese Buddhist chanting / prayer-bead counter app. The user taps the screen; every tap = one bead count.

## Core concepts
- Plan: has a name and a list of Days.
- Day (DayTask): has `phrases` (List<String>), `beadsPerRound` (int, taps in one round), `rounds` (int).
  - Each tap advances to the next phrase: phrase shown = phrases[bead % phrases.length].
  - When bead reaches beadsPerRound -> round++ and bead = 0.
  - When round reaches rounds -> the day is complete (confetti).
- Progress per plan: day (0-based current day), round (completed rounds), bead (taps in current round).

## Rules for every task
1. Do ONLY what the current prompt asks. Do not refactor or restyle unrelated code.
2. Do not add any package that the prompt does not name. If a package is named, add it with `flutter pub add <name>`.
3. Keep all UI text in Burmese (Myanmar Unicode). Never translate existing Burmese strings into English.
4. Never break existing saved data. When adding fields to a model, `fromJson` must use safe defaults (`json['x'] ?? default`).
5. All local data stays in SharedPreferences (JSON). Keys already used: `plans_v2`, `progress_v2`, `current_plan_v2`.
6. After each task run `flutter analyze` and fix every error and warning you introduced.
7. Use null-safe Dart, `const` where possible, and `if (!mounted) return;` after every `await` that precedes using BuildContext.
8. Use Material 3. Do not use deprecated `withOpacity`; use `withValues(alpha: x)`.
9. At the end of each task, reply with: (a) list of files changed, (b) how to manually test it.
```

---

## Prompt 1 — File ခွဲခြင်း (behavior မပြောင်းရ)

```text
Read AGENTS.md first.

TASK: Refactor lib/main.dart (currently one big file) into several files WITHOUT changing any behavior or look.

Create this structure under lib/:
- main.dart                      -> only `main()` and `TallyApp` (MaterialApp)
- models/day_task.dart           -> class DayTask (+ toJson/fromJson)
- models/tally_plan.dart         -> class TallyPlan (+ toJson/fromJson, totalTaps getter)
- models/progress.dart           -> class Progress (+ toJson/fromJson)
- data/default_plans.dart        -> the 24-line gatha list and `List<TallyPlan> defaultPlans()`
- services/storage_service.dart  -> class StorageService with: Future<List<TallyPlan>> loadPlans(), Future<void> savePlans(List<TallyPlan>), Future<Map<String,Progress>> loadProgress(), Future<void> saveProgress(Map<String,Progress>), Future<String?> loadCurrentPlanId(), Future<void> saveCurrentPlanId(String)
- pages/tally_page.dart          -> the counter page (TallyPage + state)
- pages/plan_editor_page.dart    -> PlanEditorPage and its _DayDraft helper (make _DayDraft public as DayDraft)

Rules:
- Copy the existing logic exactly. Only move code and fix imports.
- TallyPage must use StorageService instead of calling SharedPreferences directly.
- Keep the SharedPreferences keys exactly: plans_v2, progress_v2, current_plan_v2.

Done when: `flutter analyze` is clean and the app behaves exactly the same as before (tap counting, confetti, plan list, plan editor, saved progress after restart).
```

---

## Prompt 2 — Theme + Bottom Navigation + Plan list UI

```text
Read AGENTS.md first.

TASK: Add a design system and redesign the plan list. Do not change counting logic.

A) Myanmar font + theme
1. Tell me (in your reply) to download "Noto Sans Myanmar" (Regular, Medium, Bold) into assets/fonts/ — do not try to download it yourself. Register it in pubspec.yaml as family "NotoSansMyanmar" and use it as the default font in ThemeData (fontFamily: 'NotoSansMyanmar').
2. Create lib/theme/app_theme.dart with `ThemeData lightTheme()` and `ThemeData darkTheme()` using Material 3 and these colors:
   - seed/primary: saffron gold 0xFFE0A030
   - deep maroon 0xFF7A1D12 as secondary / accent
   - light background 0xFFFFF8EC, dark background 0xFF1B0F0A
   - Cards: radius 20, elevation 0, subtle border, no heavy shadow.
   - Text: generous line height (1.5) because Myanmar script needs vertical space.
3. MaterialApp uses themeMode: ThemeMode.system.

B) Bottom navigation
Create lib/pages/home_shell.dart: a Scaffold with a NavigationBar (Material 3) with 4 destinations, in this order, labels in Burmese:
 1. "ကျွန်ုပ်၏ Plan" (icon: Icons.self_improvement) -> MyPlansPage (task C)
 2. "ရှာဖွေရန်" (icon: Icons.explore) -> placeholder page with centered text "မကြာမီ ရောက်လာပါမယ်"
 3. "မှတ်တမ်း" (icon: Icons.history) -> placeholder page, same text
 4. "ဆက်တင်" (icon: Icons.settings) -> placeholder page, same text
Use IndexedStack so page state is kept. main.dart home becomes HomeShell.

C) MyPlansPage (lib/pages/my_plans_page.dart) — replaces the old "plan list dialog"
- AppBar title "ကျွန်ုပ်၏ Plan" and a FloatingActionButton.extended "Plan အသစ်" that opens the existing PlanEditorPage.
- Body: ListView of PlanCard widgets (lib/widgets/plan_card.dart).
- PlanCard shows: plan name (bold), "N ရက် • စုစုပေါင်း X ကြိမ်", a circular progress ring on the left (overall % = completed taps / plan.totalTaps), the line "ယနေ့: ရက် D / N" and a gold "ဆက်စိပ်မည်" FilledButton. If the plan is finished show "ပြီးမြောက်ပြီ ✅" instead.
- Tapping "ဆက်စိပ်မည်" sets that plan as current and opens TallyPage (push). Back button returns to the list.
- Three-dot menu on each card: "ပြင်မည်" (opens PlanEditorPage with the plan), "အစကပြန်စမည်" (confirm dialog, then reset progress), "ဖျက်မည်" (confirm dialog; disallow deleting the last remaining plan).
- Empty state is not needed (there is always at least one plan).
- Load/save data through StorageService. Use a small shared controller (e.g. ChangeNotifier `PlansController`) so MyPlansPage and TallyPage see the same plans/progress without reloading. Create lib/state/plans_controller.dart and use it in both pages (provide it via an InheritedNotifier or pass it through constructors; do NOT add the provider package).

Done when: app opens on the plan list with the new cards; ▶ continue opens the counter and progress is kept after going back; edit/reset/delete work; dark mode looks correct.
```

---

## Prompt 3 — Counter screen UI

```text
Read AGENTS.md first.

TASK: Redesign only the look of lib/pages/tally_page.dart. Do NOT change counting logic, saving, or confetti triggers.

Layout (top to bottom), inside a SafeArea, whole screen is still one big tappable area (HitTestBehavior.opaque):
1. Top bar: back arrow, plan name (center, small), undo icon button (right). Remove the old reset/list/add icons from this page (they now live on the plan list).
2. Day header: "ရက် D / N" as a pill.
3. Big phrase card in the center: rounded 28 card with soft gold gradient, the phrase in 28sp bold, centered, line height 1.7. Animate phrase changes with AnimatedSwitcher (fade + slight scale, 150 ms).
4. Bead ring: a CustomPaint circle made of `beadsPerRound` small dots when beadsPerRound <= 36, otherwise a simple circular arc progress. The first `bead` dots are filled gold, the rest are faint. Put the numbers "bead / beadsPerRound" in the ring center in 40sp.
5. Two small stat chips under the ring: "ပတ် r / R" and "ယနေ့ x / total".
6. A thin LinearProgressIndicator for the whole plan at the very bottom with the text "စုစုပေါင်း done / planTotal".
7. Hint text "(မျက်နှာပြင်ကို နှိပ်၍ ပုတီးစိပ်ပါ)" in grey under everything.

Tap feedback: scale-pulse the ring (1.0 -> 1.04 -> 1.0, 100 ms) on each tap; keep the existing short vibration.
Move reusable pieces into lib/widgets/ (bead_ring.dart, phrase_card.dart).
Plan-finished state: show a centered 🎉, the plan name, and a "အစကပြန်စမည်" button (same logic as before).

Done when: it looks good in light and dark mode on a small phone (360x640) without overflow, and tapping/counting/undo behave exactly as before.
```

---

## Prompt 4 — Plan create/edit (benefits, author, reminder fields)

```text
Read AGENTS.md first.

TASK: Extend the Plan model and the plan editor. (The reminder will only be STORED in this task; scheduling comes in a later prompt.)

A) Model changes in lib/models/tally_plan.dart — add these fields, all optional with safe defaults in fromJson/toJson:
- String? description        (short intro)
- String? benefits           ("ဘယ်လိုအကျိုးထူးမလဲ" – author's text)
- String? authorName         ("ရေးသားသူ")
- bool isPublic = false
- String? publicId           (id of the public copy, null if never published)
- String? sourcePublicId     (set when this plan was downloaded from the public list)
- ReminderSettings? reminder
- int createdAt              (millisecondsSinceEpoch; default = now when missing)
Create class ReminderSettings in lib/models/reminder_settings.dart: bool enabled, int hour, int minute, List<int> weekdays (1=Mon..7=Sun, default [1,2,3,4,5,6,7]); toJson/fromJson with defaults enabled=false, hour=6, minute=0.

B) Redesign PlanEditorPage as a 3-step wizard using a Stepper or PageView with a progress indicator at the top and "နောက်သို့ / နောက်ပြန်" buttons:
 Step 1 "အခြေခံ": plan name (required), description (optional), benefits (optional, multiline, label "ဤ Plan ၏ အကျိုးထူးခြင်းများ (မထည့်လည်းရ)"), author name (optional, label "ရေးသားသူ (မထည့်လည်းရ)"). Pre-fill authorName from SharedPreferences key `author_name` if it exists.
 Step 2 "ရက်များ": the existing days editor (phrases multiline, beadsPerRound, rounds) but each day inside an ExpansionTile card titled "ရက် N • <first phrase shortened> • B×R". Add a "ဤရက်ကို ကူးယူမည်" (duplicate day) button and reorder with ReorderableListView.
 Step 3 "သတိပေးချက်": Switch "နေ့စဉ် သတိပေးမည်", time picker button (showTimePicker) and 7 weekday ChoiceChips (တနင်္လာ … တနင်္ဂနွေ). Disabled controls when the switch is off.
- Validation: name required; at least one day with at least one phrase; beadsPerRound and rounds >= 1. Show errors inline in Burmese.
- Final button "သိမ်းဆည်းမည်" returns the TallyPlan.
- When saving an edited plan, keep id/createdAt/publicId/sourcePublicId. Also keep the previous behavior: editing a plan's days resets that plan's progress (ask a confirm dialog "ရက်များကို ပြင်ရင် Progress ပြန်စပါမယ်" ONLY if the days list actually changed).
- If the author name is non-empty, save it to SharedPreferences key `author_name`.

Done when: old saved plans still load, create/edit wizard works, new fields persist after restart.
```

---

## Prompt 5 — ရက်ပြည့်ပြီးနောက် confirm flow

```text
Read AGENTS.md first.

TASK: Change what happens when a day is completed. Currently the app immediately moves to the next day. New behavior below.

1. Add `String? lastCompletedOn` (format "yyyy-MM-dd", device local date) to Progress (default null, safe fromJson/toJson).
2. When the last tap of a day happens (round reaches rounds):
   - play confetti + long vibration + show the existing congratulation dialog (keep its text),
   - then set progress.day++, round = 0, bead = 0, and progress.lastCompletedOn = today's date string,
   - save progress.
   (If it was the last day of the plan, keep the existing "plan finished" behavior.)
3. On the counter page, compute `doneToday = progress.lastCompletedOn == todayString && plan is not finished`.
   - If doneToday is true: show a green banner under the day header: "ယနေ့အတွက် ပြီးပါပြီ ✅  — နောက်ရက်: ရက် N" and show the NEXT day's phrase dimmed.
   - A tap while doneToday is true must NOT count. Instead show an AlertDialog:
       title: "ယနေ့ ပြီးပြီးဖြစ်ပါသည်"
       content: "ယနေ့အတွက် ပြီးမြောက်ပြီးပါပြီ။ နောက်ရက် (ရက် N) ကို ဆက်လုပ်မလား?"
       buttons: "မလုပ်သေးပါ" (just close) and "ဆက်လုပ်မည်" (set lastCompletedOn = null, save, close; the tap that opened the dialog is not counted).
   - If doneToday is false (a new calendar day began), counting works normally with no dialog.
4. Day-change detection: when the page resumes (WidgetsBindingObserver didChangeAppLifecycleState resumed) or opens, recompute doneToday so the banner disappears after midnight.
5. Show the same "ယနေ့ပြီး ✅" small badge on PlanCard in the plan list when doneToday is true.

Put the date-string helper in lib/utils/date_utils.dart (`String todayKey([DateTime? d])`).

Done when: finishing a day -> confetti -> banner; tapping again the same day -> confirm dialog; choosing "ဆက်လုပ်မည်" lets counting continue with the next day; next calendar day counts normally without a dialog. (To test midnight, temporarily allow an override of todayKey, but remove the override before finishing.)
```

---

## Prompt 6 — History

```text
Read AGENTS.md first.

TASK: Add a History feature (local only).

1. Model lib/models/history_entry.dart: String id, String planId, String planName, int dayIndex (0-based), String dateKey ("yyyy-MM-dd"), int timestamp (ms), int taps (the day's totalTaps), int rounds. toJson/fromJson.
2. StorageService: `loadHistory()` and `addHistory(HistoryEntry)` using SharedPreferences key `history_v1` (JSON list, newest first, cap at 2000 entries).
3. In the day-complete code path (Prompt 5), create and save a HistoryEntry. The entry is written once per completed day. If the user resets the plan, do NOT delete history.
4. Replace the History placeholder page with HistoryPage (lib/pages/history_page.dart):
   - Top summary row of 3 stat cards: "စုစုပေါင်း ရက်ပြီး" (count of entries), "စုစုပေါင်း ကြိမ်" (sum of taps), "ဆက်တိုက် ရက်" (current streak = consecutive dates ending today or yesterday that have at least one entry).
   - Below: a simple 7-day bar row (last 7 days, each bar height = taps that date, weekday initials in Burmese below). Draw with plain Containers, no chart package.
   - Then entries grouped by date with a date header (e.g. "၂၀၂၆-၁၀-၂၃"), each entry a ListTile: plan name, "ရက် N • X ကြိမ်", time HH:mm.
   - Empty state: icon + "မှတ်တမ်း မရှိသေးပါ".
   - Tapping an entry opens a bottom sheet with its details; long-press -> confirm delete of that single entry.
5. HistoryPage refreshes when the tab becomes visible (use the shared controller or a ValueNotifier; no extra packages).

Done when: finishing a day adds an entry immediately visible in the History tab, stats are correct, restart keeps history.
```

---

## Prompt 7 — Reminder (local notifications)

```text
Read AGENTS.md first.

TASK: Make the plan's ReminderSettings (from Prompt 4) actually schedule notifications.

Packages (add with `flutter pub add`): flutter_local_notifications, timezone, flutter_timezone.

1. Create lib/services/reminder_service.dart (singleton):
   - `Future<void> init()` — initialize the plugin (Android icon '@mipmap/ic_launcher', iOS DarwinInitializationSettings with requestAlert/Badge/Sound false), initialize timezone data and set tz.local from flutter_timezone. Call it in main() before runApp.
   - `Future<bool> requestPermission()` — Android 13+ POST_NOTIFICATIONS and iOS permission request.
   - `Future<void> scheduleForPlan(TallyPlan plan)` — first cancel all notifications of this plan, then if plan.reminder?.enabled == true schedule one weekly-repeating notification per selected weekday at hour:minute using zonedSchedule with matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime and AndroidScheduleMode.inexactAllowWhileIdle (so no exact-alarm permission is needed).
   - `Future<void> cancelForPlan(String planId)`.
   - Notification id = a stable int from planId.hashCode combined with weekday (planId.hashCode.abs() % 100000 * 10 + weekday).
   - Notification title: plan.name. Body: "ယနေ့ ပုတီးစိပ်ရန် အချိန်ရောက်ပါပြီ 🙏".
2. Call scheduleForPlan after a plan is created/edited and when the app starts (for all plans), and cancelForPlan when a plan is deleted.
3. In the editor's reminder step (Prompt 4): when the user turns the switch on, call requestPermission(); if denied, turn the switch back off and show a SnackBar "Notification ခွင့်ပြုချက် လိုအပ်ပါသည်".
4. Platform config:
   - android/app/src/main/AndroidManifest.xml: add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` and `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` and the receivers required by flutter_local_notifications (ScheduledNotificationReceiver and ScheduledNotificationBootReceiver) exactly as in the package README. Enable core library desugaring in android/app/build.gradle(.kts) as the README says.
   - iOS: in ios/Runner/AppDelegate.swift add the UNUserNotificationCenter delegate line from the package README.
5. Show a small bell icon on PlanCard when a reminder is enabled, with the time (e.g. "🔔 06:00").

Done when: setting a reminder two minutes ahead on a real device shows the notification; editing/deleting the plan removes it. Mention in your reply anything I must do manually.
```

---

## Prompt 8 — Firebase စတင်ချိတ်ခြင်း + Auth

> ⚠️ **ဒီ prompt မခိုင်းခင် ခင်ဗျားကိုယ်တိုင်လုပ်ရမယ့်အရာ**
> 1. Firebase console မှာ project ဆောက်ပါ။ Authentication ထဲက **Anonymous** ကို Enable လုပ်ပါ။ Firestore Database ကို **production mode** နဲ့ ဆောက်ပါ (region တစ်ခုရွေးပါ)။
> 2. Project root မှာ `dart pub global activate flutterfire_cli` ပြီးရင် `flutterfire configure` run ပါ။ Android/iOS နှစ်ခုလုံး ရွေးပါ။ `lib/firebase_options.dart` ထွက်လာရမယ်။
> 3. iOS မှာ `GoogleService-Info.plist` ကို Xcode ထဲ Runner ထဲ ထည့်ထားရမယ် (flutterfire က များသောအားဖြင့် လုပ်ပေးတယ်)။

```text
Read AGENTS.md first.

PRECONDITION: I have already run `flutterfire configure`, so lib/firebase_options.dart exists. Do not run flutterfire yourself and do not edit firebase_options.dart.

TASK: Initialize Firebase and add anonymous authentication + a profile name.

1. `flutter pub add firebase_core firebase_auth cloud_firestore`.
2. In main(): `WidgetsFlutterBinding.ensureInitialized(); await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);` then ReminderService.init() (if it exists), then runApp. Wrap Firebase init in try/catch: if it fails the app must still start in offline/local mode.
3. Create lib/services/auth_service.dart:
   - `Future<User?> ensureSignedIn()` — if FirebaseAuth.instance.currentUser is null call signInAnonymously(); return the user; return null on any error (offline).
   - `String? get uid`.
   - `Future<String> getDisplayName()` / `Future<void> setDisplayName(String)` stored in SharedPreferences key `author_name` (same key as the plan editor) AND mirrored to Firestore doc `users/{uid}` field `displayName` (best effort, ignore errors).
4. Call ensureSignedIn() at app start (do not block the UI; fire and forget with a catch).
5. Replace the Settings placeholder page with SettingsPage:
   - Card "ကျွန်ုပ်၏ အမည်" with a TextField (label "ပြသမည့် အမည်") and a save button. Helper text: "Public Plan တင်ချိန်နှင့် Review ရေးချိန်တွင် ဤအမည်ကို ပြသပါမည်။"
   - Read-only row showing connection state: "အွန်လိုင်း ချိတ်ဆက်ထားသည် ✅" or "အော့ဖ်လိုင်း" depending on whether auth.uid != null.
   - Theme switch: "စနစ်အတိုင်း / အလင်း / အမှောင်" (SegmentedButton) saved in SharedPreferences key `theme_mode` and applied to MaterialApp.themeMode.
6. Everything that existed before must work with no internet and no Firebase.

Done when: first launch signs in anonymously (a user appears in Firebase console > Authentication), the display name saves, and airplane-mode launch still opens the app.
```

---

## Prompt 9 — Plan ကို public တင်ခြင်း

```text
Read AGENTS.md first.

TASK: Let the user publish their own plan to Firestore as a public plan.

Firestore data model (collection `publicPlans`, document id = auto id):
{
  ownerUid: string,
  authorName: string,          // from plan.authorName or the profile display name, may be "အမည်မဖော်ပြထားသူ"
  name: string,
  description: string,         // "" if none
  benefits: string,            // "" if none
  days: [ { phrases: [string], beadsPerRound: number, rounds: number } ],
  dayCount: number,
  totalTaps: number,
  participantCount: 0,
  reviewCount: 0,
  createdAt: serverTimestamp,
  updatedAt: serverTimestamp
}

1. Create lib/services/public_plan_service.dart with:
   - `Future<String> publish(TallyPlan plan)` — if plan.publicId == null create a new doc, otherwise update the existing doc (only the content fields + updatedAt; never overwrite participantCount, reviewCount, createdAt). Returns the doc id. Requires a signed-in user; if uid is null throw a readable Exception('အင်တာနက် ချိတ်ဆက်ပါ').
   - `Future<void> unpublish(TallyPlan plan)` — deletes the doc if the current user is the owner.
2. Add to the PlanCard three-dot menu:
   - If not public: "Public တင်မည်". If public: "Public ပြင်ဆင်မည် (Update)" and "Public မှ ဖယ်ရှားမည်".
   - Before the first publish show a confirm dialog explaining: "ဤ Plan ကို အခြားအသုံးပြုသူအားလုံး မြင်ရပါမည်။" with "မတင်တော့ပါ" / "တင်မည်".
   - On success: store plan.isPublic = true and plan.publicId = id, save locally, show SnackBar "Public တင်ပြီးပါပြီ 🙏". On error show the message.
   - Show a small "Public" chip on the PlanCard when plan.isPublic.
3. Plans that were downloaded from the public list (sourcePublicId != null) cannot be published again (hide the menu item) — this avoids copying others' work.
4. Show a CircularProgressIndicator dialog while publishing and always close it in `finally`.

Done when: publishing creates a document in Firestore with the exact fields above, updating re-publishes without resetting counts, and un-publishing removes it.
```

---

## Prompt 10 — Explore (public plans) + download + participants

```text
Read AGENTS.md first.

TASK: Build the "ရှာဖွေရန်" (Explore) tab that lists public plans and lets the user add one to "My plans".

1. Lib/services/public_plan_service.dart — add:
   - `Future<List<PublicPlanSummary>> fetchPage({DocumentSnapshot? startAfter, String sort = 'new'})` — 20 per page; sort 'new' = orderBy createdAt desc, 'popular' = orderBy participantCount desc. Create model PublicPlanSummary (lib/models/public_plan.dart) holding the document fields incl. id and the parsed `TallyPlan`-compatible days.
   - `Future<PublicPlanSummary?> fetchOne(String id)`.
   - `Future<bool> isJoined(String publicId)` — checks `publicPlans/{id}/participants/{uid}`.
   - `Future<TallyPlan> download(PublicPlanSummary p)` — in ONE Firestore transaction: create `publicPlans/{id}/participants/{uid}` (joinedAt: serverTimestamp) only if it does not exist yet, and if it was newly created increment participantCount by 1. Then return a local TallyPlan with a NEW local id, sourcePublicId = p.id, isPublic = false, publicId = null, authorName = p.authorName, description/benefits copied, reminder = null.
2. ExplorePage (lib/pages/explore_page.dart):
   - AppBar with title "ရှာဖွေရန်", a search TextField that filters the already loaded list by name/author (client-side), and a SegmentedButton "အသစ်" / "လူကြိုက်များ".
   - ListView of PublicPlanCard: plan name, "ရေးသားသူ: <authorName>", "N ရက် • X ကြိမ်", a people icon with "<participantCount> ဦး စိပ်နေသည်", a chat icon with "<reviewCount>", and a 2-line preview of `benefits` if present.
   - Pull-to-refresh (RefreshIndicator) and "load more" when scrolling to the end.
   - States: loading skeleton (simple shimmer-free grey boxes), error state with "ထပ်ကြိုးစားမည်" button, empty state "Public Plan မရှိသေးပါ".
   - If not signed in (offline) show a friendly offline message instead of crashing.
3. PublicPlanDetailPage (lib/pages/public_plan_detail_page.dart), opened by tapping a card:
   - Header: name, author, participant count.
   - Section "အကျိုးထူးခြင်းများ" showing `benefits` (or "ရေးသားသူက မဖော်ပြထားပါ").
   - Section "ရက်များ" listing each day: "ရက် N • first phrase • B × R = total ကြိမ်".
   - Bottom button: if not joined "ကျွန်ုပ်၏ Plan ထဲ ထည့်မည်", if already joined "ထည့်ပြီးသား ✅" (disabled). On press call download(), add the returned plan to the local plans via the shared controller, show SnackBar "ထည့်ပြီးပါပြီ", and update the button.
   - A reviews section placeholder: "Review များ (မကြာမီ)" — will be built in the next prompt.
4. The owner can also open their own public plan from Explore; nothing special.

Done when: plans published from another install/account appear in Explore, "add" copies the plan to My plans and increases participantCount by exactly 1 only the first time, and the app does not crash offline.
```

---

## Prompt 11 — Reviews / အကျိုးထူးမှတ်တမ်း comments

```text
Read AGENTS.md first.

TASK: Let users write and read reviews ("ဒီ Plan ကြောင့် ဘယ်လိုအကျိုးထူးခဲ့လဲ") on a public plan.

Firestore: subcollection `publicPlans/{planId}/reviews/{reviewId}` with fields:
{ uid: string, userName: string, text: string (1..1000 chars), createdAt: serverTimestamp }

1. In PublicPlanService add:
   - `Stream<List<Review>> watchReviews(String publicId)` — orderBy createdAt desc, limit 50. Create model lib/models/review.dart.
   - `Future<void> addReview(String publicId, String text)` — in a transaction/batch: add the review doc using the profile display name (or "အမည်မဖော်ပြထားသူ") AND increment parent field reviewCount by 1.
   - `Future<void> deleteReview(String publicId, String reviewId)` — only allowed for the review's own uid; batch delete the doc and decrement reviewCount by 1 (never below 0).
2. In PublicPlanDetailPage replace the placeholder with a real "Review များ" section:
   - A header with the count.
   - A multiline TextField + "ပို့မည်" button, labelled "ဤ Plan ကြောင့် ရရှိခဲ့သော အကျိုးကို မျှဝေပါ". Only enabled when the user has joined the plan (isJoined true) — otherwise show the hint "Plan ကို ထည့်ပြီးမှ Review ရေးနိုင်ပါသည်". Trim text, reject empty, max 1000 chars with a counter.
   - A list of review tiles: avatar circle with the first character of the name, userName, relative time in Burmese ("ယခုလေးတင်", "N မိနစ်က", "N နာရီက", "N ရက်က"), the text. A delete icon (with confirm dialog) on the user's own reviews only.
   - Empty state: "Review မရှိသေးပါ — ပထမဆုံး မျှဝေသူ ဖြစ်ပါစေ".
3. Update the PublicPlanCard review count so it reflects reviewCount from the plan document.
4. Prevent spam: after sending, disable the send button for 5 seconds.

Done when: a joined user can post a review that appears instantly for everyone, the count updates, only the author can delete their own review.
```

---

## Prompt 12 — Firestore security rules (ကိုယ်တိုင် Firebase console မှာ ထည့်ပါ)

AI ကို မခိုင်းဘဲ အောက်ပါ rules ကို Firebase console → Firestore → Rules ထဲ ကိုယ်တိုင် paste ပြီး Publish လုပ်ပါ။

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() { return request.auth != null; }

    match /publicPlans/{planId} {
      allow read: if signedIn();

      allow create: if signedIn()
        && request.resource.data.ownerUid == request.auth.uid
        && request.resource.data.name is string
        && request.resource.data.name.size() > 0
        && request.resource.data.name.size() <= 80
        && request.resource.data.participantCount == 0
        && request.resource.data.reviewCount == 0;

      // owner can edit everything; anyone signed in may only change the two counters
      allow update: if signedIn() && (
        resource.data.ownerUid == request.auth.uid ||
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['participantCount', 'reviewCount'])
      );

      allow delete: if signedIn() && resource.data.ownerUid == request.auth.uid;

      match /participants/{uid} {
        allow read: if signedIn();
        allow create, delete: if signedIn() && request.auth.uid == uid;
      }

      match /reviews/{reviewId} {
        allow read: if signedIn();
        allow create: if signedIn()
          && request.resource.data.uid == request.auth.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() > 0
          && request.resource.data.text.size() <= 1000;
        allow delete: if signedIn() && resource.data.uid == request.auth.uid;
      }
    }

    match /users/{uid}/{document=**} {
      allow read, write: if signedIn() && request.auth.uid == uid;
    }
  }
}
```

မှတ်ချက်: ဒီ rules အရ counter (`participantCount`, `reviewCount`) ကို signed-in user တစ်ယောက်က တိုက်ရိုက် ပြင်လို့ရတယ်။ Cloud Functions (free plan မှာ မရ) မသုံးဘဲ လုပ်ထားတာမို့ အဲဒီ အားနည်းချက်ရှိတယ်။ အစပိုင်း အသုံးပြုသူနည်းချိန်မှာ လက်ခံနိုင်ပေမယ့် user များလာရင် Cloud Functions ကို ပြောင်းသင့်တယ်။

---

## Prompt 13 — (Optional) ကိုယ့် Plan / Progress ကို cloud backup

```text
Read AGENTS.md first.

TASK: Add optional cloud backup of the user's own plans and progress, so data survives reinstalling the app. Local storage remains the source of truth while using the app.

Firestore:
- users/{uid}/plans/{planId}      -> the TallyPlan JSON + updatedAt (serverTimestamp)
- users/{uid}/progress/{planId}   -> the Progress JSON + updatedAt

1. Create lib/services/backup_service.dart:
   - `Future<void> backupAll(List<TallyPlan> plans, Map<String, Progress> progress)` — writes each plan and progress using a batched write (max 400 operations per batch).
   - `Future<BackupData?> fetchBackup()` — reads both collections.
   - `Future<void> deletePlanBackup(String planId)`.
2. SettingsPage: add a card "Cloud Backup":
   - Switch "အလိုအလျောက် Backup လုပ်မည်" saved in SharedPreferences `auto_backup`. When on, call backupAll (debounced 5 s) after any plan/progress change, and ignore errors silently.
   - Button "ယခု Backup လုပ်မည်" and button "Backup မှ ပြန်ယူမည်".
   - Restore flow: fetchBackup(); if empty show "Backup မရှိပါ". Otherwise show a confirm dialog: "ယခု ဖုန်းထဲက Plan များကို Backup နှင့် အစားထိုးမလား? / ပေါင်းထည့်မလား?" with 2 options: "ပေါင်းထည့်မည်" (add only plans whose id is not already local) and "အစားထိုးမည်". Save via StorageService and refresh the shared controller.
   - Show the last backup time ("နောက်ဆုံး Backup: ...").
3. Deleting a local plan also calls deletePlanBackup (best effort).

Done when: install on a second device/emulator with the same Firebase account (anonymous accounts do NOT carry over — note this limitation in your reply and suggest adding Google Sign-In later) or after clearing app data on the same account, restore brings the plans back.
```

---

## နောက်ဆုံးအကြံပြုချက်

- Prompt 2 နဲ့ 3 က design အတွက် အဓိကအဆင့်တွေ ဖြစ်တယ်။ Free model က ပထမအကြိမ်မှာ မလှရင် "Make the spacing larger, use the gold/maroon palette from AGENTS.md" လိုမျိုး အပိုင်းလေးတစ်ခုစီ ထပ်ခိုင်းပါ။
- Screenshot တွေကို AI ကို ပြပြီး "make it look like this" လို့ ပြောရင် design ပိုကောင်းတယ် (model က image ကို ပံ့ပိုးရင်)။
- ကိုယ့် App ရဲ့ UI ကို ကျွန်မက mockup ပုံ ဆွဲပေးစေချင်ရင်လည်း ပြောပါ။
