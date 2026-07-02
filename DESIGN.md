# BooBoo Design System

## Register

product

## Theme

**"Dark Immersive Ghostly"** — a self-illuminated privacy world. The UI is a space Ghostly inhabits, not a surface with a character pasted on. Purple-black voids with ectoplasm glow, fluid rounded forms, and Ghostly as the living center of every screen.

### Visual Metaphor

The app is a *lantern in the dark*. Ghostly's world is black velvet — elements appear because they glow, not because they're lit from above. Backgrounds swallow light. UI elements emit their own inner illumination. Ghostly is the brightest thing in the room.

- No drop shadows — use inner glow and bloom effects
- No sharp corners on the window or major containers
- The window itself has no chrome — it's a floating portal into Ghostly's dimension

## Color Palette

### Surface Colors (Dark — Primary Mode)

| Token | Hex | Usage |
|-------|-----|-------|
| `booBackground` | `#0A0612` | Main background — deep haunted purple-black |
| `booBackgroundElevated` | `#140E32` | Cards, sheets, elevated surfaces |
| `booBackgroundHover` | `#1E1530` | Hover state, active filter background |
| `booBackgroundGlow` | (new) `#1A0E2E` | Ghostly's ambient glow radius background |

### Surface Colors (Light — Secondary Mode)

| Token | Hex | Usage |
|-------|-----|-------|
| `booLightBackground` | `#F8F4FF` | Lavender-tinted white surface |
| `booLightBackgroundElevated` | `#EEE6F8` | Elevated light card |
| `booLightBackgroundHover` | `#E0D4F0` | Light hover |

### Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `booTextPrimary` | `#F0E6FF` | Primary text — ghost white with violet tint |
| `booTextSecondary` | `#B8A8E8` | Secondary text — dim ghost |
| `booTextTertiary` | `#7A6A9A` | Muted, captions, metadata |
| `booLightTextPrimary` | `#1A1028` | Light mode primary text |
| `booLightTextSecondary` | `#4A3858` | Light mode secondary |

### Accent & Ghostly Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `booAccent` | `#8B7FD6` | Primary accent — ectoplasm purple, buttons, active states |
| `booAccentBright` | `#B8A8FF` | Bright ectoplasm — hover, highlight, glow |
| `booSpectral` | `#60F0E0` | Spectral cyan — secondary accent, info, Ghostly's eyes |
| `booWisp` | `#FFD6A5` | Warm amber — warnings, "coming soon" tags |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `booSuccess` | `#8FDD8F` | Passed checks, positive states — slime green |
| `booWarning` | `#FFB84D` | Warnings, caution — amber |
| `booDanger` | `#FF6B6B` | Failures, critical alerts — blood red |

### Border & Stroke Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `booBorder` | `#B496DC` at 15% opacity | Subtle borders on cards |
| `booBorderStrong` | `#B496DC` at 30% opacity | Active border, focus ring |

### Proposed Additions for Ghostly UI

| Token | Hex | Usage |
|-------|-----|-------|
| `booGlowPurple` | (new) | Ghostly's default body glow — radial gradient from `booAccent` to transparent |
| `booGlowGreen` | (new) — `#7BED9F` | Ectoplasm green — Ghostly's happy/celebration glow |
| `booGlowBlue` | (new) — `#7BC4ED` | Ectoplasm blue — Ghostly's info/curious glow |
| `booGlowRed` | (new) — `#ED7B7B` | Ectoplasm red — Ghostly's alert/alarm glow |
| `booGlowAmber` | (new) — `#FFD6A5` | Ghostly's sleepy/relaxed glow |

## Typography

**Family**: SF Pro Rounded across all UI. Single family, weight-driven hierarchy. No display fonts, no pairing.

| Token | System Style | Weight | Usage |
|-------|-------------|--------|-------|
| `booLargeTitle` | `.largeTitle` rounded | Semibold | Page titles, hero Ghostly quotes |
| `booTitle` | `.title` rounded | Semibold | Section headers |
| `booTitle2` | `.title2` rounded | Medium | Subsection headers |
| `booTitle3` | `.title3` rounded | Regular | Card headers, panel titles |
| `booHeadline` | `.headline` rounded | Semibold | Button text, emphasis |
| `booBody` | `.body` rounded | Regular | Primary content text |
| `booCallout` | `.callout` rounded | Regular | Secondary text, descriptions |
| `booSubheadline` | `.subheadline` rounded | Regular | Tighter secondary text |
| `booFootnote` | `.footnote` rounded | Regular | Footnotes, metadata |
| `booCaption` | `.caption` rounded | Regular | Labels, timestamps, badges |
| `booCaption2` | `.caption2` rounded | Regular | Tiny labels, severity pills |
| `booMonoBody` | `.body` monospaced | Regular | Paths, commands, IDs |
| `booMonoCaption` | `.caption` monospaced | Regular | Log output, file paths |
| `booMonoFootnote` | `.footnote` monospaced | Regular | Smaller monospaced text |

### Proposed Ghostly Dialogue Typography

| Token | Style | Usage |
|-------|-------|-------|
| `booGhostlySpeech` | `.title3` rounded, italic | Ghostly's spoken dialogue bubbles |
| `booGhostlyThought` | `.callout` rounded, italic, `booTextTertiary` | Ghostly's idle thoughts/ambient text |

## Spacing & Layout

**Grid**: 4-point system.

| Token | Value | Usage |
|-------|-------|-------|
| `BooSpacing.xsmall` | 4pt | Icon padding, tight grouping |
| `BooSpacing.small` | 8pt | Inline spacing, label gaps |
| `BooSpacing.medium` | 16pt | Card padding, section gaps |
| `BooSpacing.large` | 24pt | Section headers, form groups |
| `BooSpacing.xlarge` | 32pt | Page margins, major sections |
| `BooSpacing.xxlarge` | 48pt | Hero spacing, major dividers |

### Corner Radii

| Token | Value | Usage |
|-------|-------|-------|
| `BooRadius.small` | 4pt | Pills, tags, severity badges |
| `BooRadius.input` | 6pt | Text fields, search bars |
| `BooRadius.button` | 8pt | Buttons |
| `BooRadius.card` | 12pt | Cards, sheets, elevated panels |
| `BooRadius.window` | 10pt | Window corners |

**Proposed**: Increase `BooRadius.window` to **16pt** for the new chrome-less window (more fluid, less boxy).

### Layout Constants

| Token | Value | Usage |
|-------|-------|-------|
| `BooLayout.sidebarWidth` | 240 | Sidebar width (if sidebar retained) |
| `BooLayout.toolbarHeight` | 44 | Toolbar height |
| `BooLayout.statusBarHeight` | 28 | Status bar height |
| `BooLayout.ghostTinySize` | 16 | Ghostly's smallest presence (checkmark, badge) |
| `BooLayout.ghostSmallSize` | 48 | Ghostly in compact areas, Settings |
| `BooLayout.ghostMediumSize` | 80 | Ghostly in secondary views, Assistant |
| `BooLayout.ghostLargeSize` | 120 | Ghostly hero presence, onboarding, Dashboard |

## Components

### Current State (to be evolved)

#### StatCard
- Icon + large value + label stacked vertically
- Filled rounded rect with border stroke
- Max width flexible, equal grid
- Current icon: SF Symbols (generic)
- **Target**: Ghostly-themed card — Ghostly peeks from the corner, value text glows, icon replaced by Ghostly mini-expression

#### SeverityLabel
- Colored text pill with 15% opacity background
- Maps severity to color (critical→danger, high→warning, medium→wisp, low→secondary, info→tertiary)
- **Target**: Ghostly-themed pills — small ghost face tinted to severity color, animated glow

#### StatusBadge
- Circle dot + text label (Passed/Failed/Warning/Unknown)
- **Target**: Ghostly expressions — tiny happy/concerned/sleepy Ghostly face instead of dot

#### GhostPlaceholder
- Current: SF Symbol `ghost.fill` at 50% of container size
- **Target**: Custom Ghostly vector rendering — the actual character, not a system icon. Multiple expression variants.

#### AnimatedGhost (WelcomeView)
- Current: `ghost.fill` with float+pulse+wobble animations
- **Target**: Full Ghostly character — drawn body, animated eyes, glowing aura, idle float. Expression states mapped to UI context.

### Proposed New Components

#### GhostlyCharacter
The living ghost. Replaces `AnimatedGhost` and `GhostPlaceholder` completely.

**Props**:
- `expression`: `.idle` `.curious` `.happy` `.concerned` `.alarmed` `.sleepy` `.mischievous`
- `size`: `.tiny` `.small` `.medium` `.large`
- `glowColor`: matches current emotional state
- `state`: `.floating` `.reacting` `.celebrating` `.waiting`

**Visual spec**:
- Custom drawn body (not SF Symbol) — fluid ghost silhouette
- Eyes that track UI state, blink, widen, squint
- Mouth that smiles, frowns, gasps
- Ambient float animation (gentle sine wave, 3-4s period)
- Glow aura behind body (radial gradient matching ghostly mood)

#### GhostlyDialogue
Speech bubble from Ghostly that appears during onboarding, milestones, or when Ghostly has something to say.

**Props**:
- `text`: String
- `position`: `.topLeading` `.topTrailing` `.bottomCenter` `.floating`
- `intent`: `.greeting` `.tip` `.warning` `.celebration` `.teasing`
- `autoDismiss`: TimeInterval (optional)

**Visual spec**:
- Rounded pill/bubble with ghostly tail pointing at Ghostly
- Inner glow matching intent color
- Text in `booGhostlySpeech` style
- Fade in/out with float animation

#### CompliancePulse
The main dashboard widget showing overall status through Ghostly's mood.

**Visual states**:
- Ghostly floating lazily with soft green glow → all clear
- Ghostly sitting up, amber glow → minor issues
- Ghostly alert, red glow, faster float → critical issues
- Ghostly celebrating with particles → milestone/streak reached

No numeric score displayed as primary — Ghostly's mood IS the score. Numeric detail is one click away.

#### RewardBurst
Particle celebration effect for milestones.

**Props**:
- `intensity`: `.subtle` `.moderate` `.maximal`
- `color`: matches achievement type
- `duration`: 0.5–2.0s

**Visual spec**:
- Ectoplasm-colored particles (circles, stars, mini ghosts)
- Particles emit from Ghostly's position, drift upward and fade
- Optional haptic feedback on macOS

#### StreakIndicator
Daily compliance streak display.

**Visual spec**:
- Row of ghost icons — filled (active day) / dimmed (missed) / glowing (today)
- Ghostly reacts when streak grows (happier, bigger glow)
- Milestone markers at 7, 30, 60, 90 days with special Ghostly reaction

#### AmbientParticles
Continuous background particle system for the main UI surfaces.

**Visual spec**:
- Tiny floating light motes (ectoplasm-colored dots)
- Slow drift upward with gentle horizontal wander
- Density varies by screen — dense on Dashboard, sparse on Compliance list
- Ghostly can "disturb" particles when reacting (particles scatter)

## Screen Architecture

### Current Structure (to replace)

```
Window (standard chrome)
└── NavigationSplitView
    ├── Sidebar (240pt)
    │   ├── Ghost icon + "BooBoo" header
    │   └── Tab list: Dashboard, Compliance, About, Settings
    └── Detail view
        └── NavigationStack
            └── {DashboardView, RuleListView, AboutView, SettingsView}
```

### Target Structure

```
Floating Portal (no chrome, no titlebar, no close/min/zoom, no dock icon)
└── GhostlyPortalView
    ├── AmbientParticles (background layer)
    ├── GhostlyCharacter (omnipresent, always visible)
    │   └── Reacts to every state change
    ├── GhostlyDialogue (contextual speech bubbles)
    ├── MainContentArea
    │   ├── Dashboard (Ghostly's room — compliance pulse, streaks, stats)
    │   ├── Compliance (rules list with Ghostly peeking at each row)
    │   ├── Settings (Ghostly sleepy/hovering nearby)
    │   └── About (Ghostly shows you around)
    └── Navigation (ghost-themed, not sidebar list)
        └── Floating tabs or Ghostly-guided navigation
```

### Screen-by-Screen Direction

#### Dashboard — "Ghostly's Room"
- Ghostly is center stage — large, expressive, mood reflects overall compliance
- Surrounding elements orbit Ghostly: stat orbs, streak row, quick-action buttons
- Score shown as Ghostly's glow intensity and mood, not a percentage
- Tap/click Ghostly to hear a thought, see streak progress, or get a tip
- "Run Scan" button is a floating ectoplasm orb Ghostly nudges toward
- **Current**: Standard sidebar with score card and grid of stat cards
- **Target**: Ghostly-centered immersive dashboard

#### Compliance — "The Watchtower"
- List of rules, each row has a tiny Ghostly expression showing pass/fail status
- Ghostly floats near relevant sections — concerned near failing rules, relaxed near passed ones
- Search bar is framed by Ghostly peering into it
- Filter pills are ghost-themed tag bubbles
- **Current**: Standard list with sidebar, search bar, filter pills
- **Target**: Ghostly-present list with character reactions per section

#### Onboarding — "Meeting Ghostly"
- Full-screen experience, Ghostly introduces itself, shows you around
- Ghostly walks you through each major feature with dialogue and reactions
- You "earn" Ghostly's trust as you complete onboarding steps
- **Current**: Sheet with basic tour steps using ghost icon
- **Target**: Immersive character-led onboarding with Ghostly dialogue

#### Assistant — "Talk to Ghostly"
- Ghostly is the assistant — chat UI with Ghostly as the other participant
- Ghostly's expression changes as conversation progresses
- Ghostly reacts to your questions (curious at complex questions, proud when you understand)
- **Current**: Standard chat interface with animated ghost in header
- **Target**: Ghostly is the interface, not just the header icon

#### Settings — "The Workshop"
- Ghostly is present but quieter — reading over your shoulder
- Settings grouped into ghost-themed sections (spells = rules, potions = scan config)
- Ghostly offers tips about settings you're configuring
- **Current**: Standard GroupBox-based settings form
- **Target**: Ghostly-attended settings with contextual tips

#### About — "Ghostly's Story"
- Ghostly introduces itself properly — lore, personality, the story of BooBoo
- Version info and license presented as "the fine print" behind Ghostly
- **Current**: Static about page with version info
- **Target**: Character page with Ghostly's bio + behind-the-scenes info

## Motion Design

### Ghostly Idle Motion
- Continuous gentle floating: Y-axis sine wave, 3-4s period, ±8px amplitude
- Subtle rotation wobble: ±3deg, 2s period
- Glow pulse: opacity 0.7→1.0→0.7, 4s period
- Eyes blink every 4-6s (50ms closure)

### Ghostly Reaction Motion
- Quick dip + return on new information (150ms)
- Celebration bounce: rapid Y oscillation with increasing amplitude, 500ms
- Alarm: sharp upward motion + faster float, 200ms
- Curiosity: tilt head, approach (scale up to 1.1x), 300ms

### Functional Transitions
- View changes: 200ms easeInOut
- Card hover: 150ms easeOut
- Modal/sheet presentation: 300ms spring (damping 0.7)
- Ghostly expression change: 200ms crossfade

### Particle Motion
- Ambient: 60s drift from bottom to top, 100px horizontal wander
- Celebration: 0.5–1.5s burst from center, fade out at peak
- Disturbance: particles scatter away from Ghostly's position on reaction

## Window & Presentation

### Current
- Standard `WindowGroup` with full macOS chrome
- Title bar, close/min/zoom buttons, resize handle
- Default menu bar with standard commands
- Dock icon visible

### Target
- **No window chrome** — hide titlebar, traffic lights, resize indicator
- **Floating portal** — custom window shape with larger radius (16pt), no border
- **Dock icon hidden** — app lives in the background, summoned via hotkey or menu bar
- **Menu bar presence** — optional minimal icon for summoning the window
- **Appearance**: Window has a subtle "inner glow" border instead of standard shadow — as if the window frame itself emits light

## Ghostly Character — Visual Spec

### Silhouette
- Classic ghost shape but distinct from SF Symbol: wider top, narrow wavy bottom
- Smooth curves, no sharp angles
- Two simple glowing eyes (white oval, 10pt × 14pt)
- Mouth that can form expressions: smile (crescent), frown, O-shape (surprise), wavy (nervous)
- Optional small blush dots for happy states

### Expression States

| Expression | Eyes | Mouth | Body | Glow Color | Float Speed |
|-----------|------|-------|------|------------|-------------|
| Idle | Normal open, soft blink | Gentle smile | Slow float, relaxed | Purple (`booAccent`) | Normal |
| Curious | One eye slightly larger, tilt | Small o-shape | Leans forward, tilts | Blue (`booGlowBlue`) | Normal+ |
| Happy | Squinted crescents | Wide smile | Bouncy float, sways | Green (`booGlowGreen`) | Faster |
| Concerned | Lowered brows, slight squint | Wavy line | Hover lower, less motion | Amber (`booGlowAmber`) | Slower |
| Alarmed | Wide open, larger pupils | O-shape, open | Jumps up, faster float | Red (`booGlowRed`) | Fast, erratic |
| Sleepy | Half-closed, slow blink | Small wavy | Droops lower, slow sway | Dim purple | Very slow |
| Mischievous | One raised brow, one squint | Side-smirk | Tilted, extra wobble | Purple-pink | Bouncy |
| Celebrating | Wide, star-shaped pupils | Huge smile | Spins, bounces, multiplies | Bright green burst | Maximum |

### Ghostly Size Variants

| Size | Frame | Use Case |
|------|-------|----------|
| `.tiny` | 20×20 | Status dot, badge replacement |
| `.small` | 48×48 | Secondary views, settings, list rows |
| `.medium` | 80×80 | Assistant, dialogue companion, secondary screens |
| `.large` | 120×120 | Dashboard hero, onboarding primary |
| `.hero` | 180+ | Welcome screen, milestone celebrations |

## Icon & Branding

### App Icon
- Ghostly's face centered on dark background (not a system icon)
- Glow aura extending past icon bounds
- Expression: mischievous smile with one eye squinted
- Colors: `#0A0612` background, `#8B7FD6` ghost body, `#B8A8FF` highlight

### Dock Icon
- Ghostly silhouette (simplified, no detail at small sizes)
- No text — Ghostly's face is the brand
- Consider: **no dock icon** (consistent with hidden-window philosophy) — optional

## Anti-References

What BooBoo deliberately avoids:

- **Standard macOS app look** — no unified titlebar/toolbar, no traffic lights, no sidebar list style
- **Flat minimalism** — this is not a Linear/Raycast-clone dark UI. BooBoo is atmospheric, not minimal
- **Generic security app** — no shields, locks, checkmarks as primary visual language. Those are secondary. Ghostly is primary
- **Overly cute** — Ghostly is playful but not saccharine. The humor has edge (playful trickster, not cute mascot)
- **Skeuomorphic** — no simulated textures, no leather/wood/metallic. Everything is self-illuminated digital
- **Windows-style widgets** — no flat rectangles with data. Everything has glow and life

## Accessibility

- Motion: Respect "Reduce Motion" — Ghostly's idle float becomes static, reactions become opacity transitions
- Transparency: Respect "Reduce Transparency" — reduce glow effects, solid backgrounds
- Contrast: All text meets WCAG AA on `booBackground`. Ghostly's glow states are informational, not the only indicator
- Color blindness: Ghostly's expression and position convey state, not just glow color. Mood is communicated through multiple channels (expression + glow + position + dialogue)
- VoiceOver: Ghostly has accessibility labels that describe its current mood and state. Dialogue is read as notifications
- Focus: Custom focus ring using `booBorderStrong` glow effect, visible on dark backgrounds
- Text size: Dynamic Type support through SF Text Styles (already in use)

## Implementation Priority

1. **GhostlyCharacter component** — replace AnimatedGhost and GhostPlaceholder with custom-drawn character
2. **Window chrome removal** — hide titlebar, traffic lights, portal styling
3. **Dashboard overhaul** — Ghostly-centered with CompliancePulse, StreakIndicator, AmbientParticles
4. **Navigation redesign** — ghost-themed navigation replacing sidebar list
5. **Compliance list with Ghostly** — Ghostly present per-section, expression-based status
6. **Onboarding as meeting Ghostly** — character-led walkthrough
7. **Assistant with Ghostly character** — Ghostly is the chat interface
8. **Settings and About ghost-ification** — ghost-themed sections, Ghostly's story
9. **App icon and dock** — custom Ghostly icon, consider hidden dock
10. **DMG rebuild** — package with new app
