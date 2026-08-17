# Centrow Design System

Unified reference for web (this repo, `centrow`) and mobile/tablet (`centrow-app`, Flutter). Two codebases, one visual language. Web = source of truth (older, richer token set); mobile ports subset.

---

## 1. Brand

Accent = indigo/blue. Neutral warm-gray base (`#F8F8F5`, not pure white/gray). Headings: Plus Jakarta Sans. Body: Inter.

---

## 2. Color Tokens

| Role | Web token (`main.css`) | Web hex | Mobile (`AppColors`) | Mobile hex |
|---|---|---|---|---|
| Canvas bg | `--color-page` / `bg-page` | `#F8F8F5` | `bg` | `#F8F8F5` |
| Surface/card | `--color-surface` / `bg-surface` | `#FFFFFF` | `card` | `#FFFFFF` |
| Alt surface | `--color-subtle` | `#F8F8F5` | `cardAlt` | `#F8F8F5` |
| Brand primary | `--color-brand-500` | `#1E40AF` | `accent` | `#6366F1` ⚠ mismatch |
| Brand hover | `--color-brand-600` | `#1D4ED8` | `accentDark` | `#4F46E5` |
| Brand light | `--color-brand-50/100` | rgba(30,64,175,.05/.1) | — | — |
| Text primary | `--color-primary` | `#181A19` | `text` | `#181A19` |
| Text secondary | `--color-secondary` / `-subtitle` | `#5A5D5A` | `textMuted` | `#5A5D5A` |
| Text muted | `--color-muted` | `#8C8E8B` | `textDim` | `#8A8D8A` |
| Text inverse | `--color-inverse` | `#FFFFFF` | — (`Colors.white`) | — |
| Border default | `--color-border-default` | `#E4E5DF` | `border` | `#E4E5DF` |
| Border strong | `--color-border-strong` | `#CBD5E1` | — | — |
| Success | `--color-success-500` | `#10B981` | `success` | `#10B981` |
| Warning | `--color-warning-500` | `#BC7B43` | `warning` | `#BC7B43` |
| Danger | `--color-danger-500` | `#EF4444` | `danger` | `#DC2626` ⚠ mismatch |
| Info | `--color-info-500` | `#3B82F6` | — | — |

⚠ **Known drift**: mobile `accent` (`#6366F1` indigo) and `danger` (`#DC2626`) don't match web's `brand-500` (`#1E40AF` blue) and `danger-500` (`#EF4444`). Align if a unified rebrand pass happens; not yet reconciled.

Mobile also has a full **dark mode** neutral set web has no equivalent for: `bgDark #0E0F0E`, `cardDark #181A19`, `cardAltDark #1F211F`, `borderDark #2A2C2A`, `textDark #F5F5F2`, `textMutedDark #9CA09C`, `textDimDark #6B6E6B`.

**Never hardcode hex in either codebase** — web uses Tailwind tokens (`bg-page`, `text-primary`, ...), mobile uses `AppColors.*`.

---

## 3. Typography

Both platforms: **Plus Jakarta Sans** (headings) + **Inter** (body). Web loads local `.ttf`; mobile via `google_fonts` package.

| Purpose | Web class | Mobile (`AppTypography`) | Size / weight |
|---|---|---|---|
| Display | — (custom) | `display()` | 52 / w800 |
| Large numeric | — | `numericLg()` | 40 / w800 |
| H1 | `font-jakarta text-3xl font-bold` | `heading1()` | 28 / w800 |
| H2 | `font-jakarta text-xl font-bold` | `heading2()` | 20 / w700 |
| H3 | `font-jakarta text-lg font-bold` | `heading3()` | 18 / w700 |
| Section title | `font-jakarta font-bold text-sm` | `sectionTitle()` | 15 / w700 |
| Body | `font-sans text-sm` | `bodyMd()` | 14 / w500 |
| Body small | `font-sans text-xs` | `bodySm()` | 12 / w500 |
| Label (caps) | `font-sans text-xs uppercase tracking-wide` | `labelCaps()` | 12 / w600, +0.72 tracking |
| Caption | `font-sans text-[11px]` | `caption()` | 11 / w500 |
| Button lg | — | `buttonLg()` | 16 / w700 |
| Button md | — | `buttonMd()` | 14 / w600 |
| Button sm | — | `buttonSm()` | 13 / w600 |
| Input text | — | `inputText()` | 14 / w400 |

No `font-mono` on web. Mobile has no monospace style either.

---

## 4. Spacing

Web: 8px grid, Tailwind arbitrary tokens.
```
--spacing-ds-1: 4px   --spacing-ds-2: 8px   --spacing-ds-3: 12px
--spacing-ds-4: 16px  --spacing-ds-5: 20px  --spacing-ds-6: 24px
--spacing-ds-7: 28px
```

Mobile (`AppSpacing`), same base scale, different naming, plus form-specific tokens:
```dart
xs 4  sm 8  md 12  lg 16  xl 20  xxl 24  xxxl 32  page 18
sectionGap 40  headlineGap 10  labelGap 6  fieldGap 14
inputPaddingH 14  inputPaddingV 13  buttonPaddingV 14
```
Roughly: web `ds-1..ds-6` ↔ mobile `xs..xxl`. Mobile's `page`/form-gap tokens have no direct web analogue (web spacing driven by Tailwind utility classes on a case-by-case basis, not a fixed page-padding token).

---

## 5. Radius

| Web (`--radius-ds-*`) | px | Mobile (`AppRadius`) | px |
|---|---|---|---|
| `sm` | 6 | `xs` | 6 |
| `md` | 10 | `sm` | 9 |
| `lg` | 14 | `md` | 12 |
| `xl` | 18 | `lg` | 16 |
| — | — | `xl` | 20 |
| `full` | 9999 | `pill` | 999 |

Not a clean 1:1 — mobile has one extra step (`xl`=20) and values don't numerically match web at each rung. Treat as "same intent, different scale," not interchangeable.

---

## 6. Elevation / Shadow

Web only — real shadow tokens:
```
--shadow-ds-sm: 0 1px 2px rgba(0,0,0,.04)
--shadow-ds-md: 0 2px 8px rgba(0,0,0,.06), 0 1px 3px rgba(0,0,0,.04)
--shadow-ds-lg: 0 8px 24px rgba(0,0,0,.08), 0 2px 8px rgba(0,0,0,.04)
--shadow-ds-brand: 0 4px 12px rgba(30,64,175,.20)
```
Mobile deliberately flat — `elevation: 0` everywhere in `AppTheme` (AppBar, Card, ElevatedButton). Depth on mobile comes from `border` color only, not shadow. Don't introduce mobile shadows without a deliberate design call — current mobile style is flat-by-convention.

---

## 7. Components

### Web (`@/components`, React + Tailwind)
Never write local variants of these — reuse only:
```
Button   variant: primary|secondary|danger|success|ghost   size: sm|md|lg
Badge    variant: success|warning|danger|info|brand|neutral   shape: pill|tag
Card     padding?: boolean (default true, p-5)
Input    label? hint? required? error?
Select   label? hint? required? error?  (native, simple only)
SearchableSelect<T>  value/onChange/options/label/hint/required/error/placeholder/isClearable/isSearchable/disabled
Avatar   name, size: sm|md|lg
StatusPill  status: active|offline|away|pending, label?
KPICard  label, value, trend, trendUp, icon, sub?, iconBg?, iconText?, barColor?, barPercent?
PageHeader  title, subtitle?, action?
AdminLayout title, description?, active, children
Table<T> columns, data, pagination?, highlightOnHover?
Dropdown
```
Icons: `react-feather`. Card default: `rounded-ds-lg border border-border-default bg-surface p-5 shadow-ds-sm`.

### Mobile (`lib/shared/widgets/`)
Much thinner shared kit — most screens compose Material widgets directly styled via `AppTheme`/`AppColors`/`AppTypography`, not a large custom component library:
```
ErrorView        — failure display + retry callback
AppBottomNav     — role-aware tab bar (employee vs manager item sets), flat (elevation 0),
                   selected = accent, unselected = textDim, icons via Icons.*_outlined
```
`ThemeData` centralizes: flat AppBar (`elevation 0`), flat bordered `CardThemeData` (`AppRadius.borderLg` + border side), borderless dense `InputDecorationTheme` (fields get visual chrome from wrapping widget, not the theme), flat `ElevatedButton` (accent bg, white text, `AppRadius.borderMd`, `buttonLg` text style).

**Gap**: mobile has no equivalent of web's `Badge`/`StatusPill`/`KPICard`/`SearchableSelect`/`Dropdown`/`Table` as reusable widgets yet — those are currently ad-hoc per screen. Extract to `shared/widgets/` before duplicating a pattern a 3rd time (matches the "3 similar lines > premature abstraction" rule — but 3+ Flutter screens rebuilding the same badge/pill is the trigger).

---

## 8. Cross-Platform Mapping Cheatsheet

| Concept | Web | Mobile |
|---|---|---|
| Token source | `web/app/main.css` `@theme` | `lib/shared/theme/app_*.dart` |
| Apply color | Tailwind class (`bg-page`, `text-primary`) | `AppColors.*` |
| Apply type | Tailwind class + `font-jakarta`/`font-sans` | `AppTypography.xxx(color)` |
| Apply spacing | Tailwind arbitrary/token classes | `AppSpacing.*` (EdgeInsets) |
| Apply radius | `rounded-ds-*` | `AppRadius.border*` |
| Dark mode | not implemented | implemented (`AppColors.*Dark`, `AppTheme.dark()`) |
| Language | Bahasa Indonesia (all UI text) | Bahasa Indonesia (all UI text, see nav labels: "Beranda", "Cuti", "Approval") |

---

## 9. Rules

1. Zero hardcoded hex/px in either codebase — tokens only.
2. Web: reuse `@/components`, never fork a local `Button`/`Table`/etc.
3. Mobile: reuse `AppColors`/`AppTypography`/`AppSpacing`/`AppRadius`; promote screen-local widgets to `shared/widgets/` on 3rd duplication.
4. Bahasa Indonesia for all user-facing copy, both platforms.
5. Flat mobile (no shadow, elevation 0) vs. shadowed web (`shadow-ds-*`) is intentional per-platform, not a bug — don't "fix" one to match the other without a design decision.
6. Brand/danger color mismatch (§2) is known drift, not spec — flag before treating either value as canonical.
