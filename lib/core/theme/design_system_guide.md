# TB Check Design System Guide

This guide establishes the official design tokens and coding patterns for the **TB Check** application's user interface. Following this system prevents "design gaps"—where different screens use slightly off colors, fonts, or alignments—ensuring a unified, premium user experience.

---

## 🎨 Color Palette

We use a clean, modern color palette split into Primary, Secondary, Accent, and Neutral domains. Access all colors programmatically using the `AppColors` class in `app_theme.dart`.

### 1. Primary Colors (Steel Blue)
The core brand identity color, conveying trust, professionalism, and clinical precision.
* **Primary**: `0xFF4E7BA7` (Steel Blue) — Main branding, primary buttons, active states, active tab highlights.
* **Dark (Hover/Active)**: `0xFF3D6285` (Deep Steel Blue) — Secondary hover, pressed state overlay.
* **Light (Background/Mist)**: `0xFFE8EEF5` (Sky Mist) — Light input backgrounds, container fills, light icon backdrops.

### 2. Secondary Colors (Royal Lavender)
Used for secondary actions, interactive toggles, and supporting UI components.
* **Secondary**: `0xFF7B519C` (Royal Lavender) — Secondary actions, chips, filters.
* **Dark**: `0xFF5F3A80` (Deep Lavender) — Lavender hover or pressed states.
* **Light**: `0xFFF3E8FF` (Soft Lavender) — Decorative backgrounds, highlight cards.

### 3. Accent Colors (Sage Green / Success)
Used for positive actions, completions, and successful medical inference.
* **Success**: `0xFF5F8C4F` (Sage Green) — Checked states, success messages, complete states.
* **Dark**: `0xFF4E7340` (Forest Sage) — Success hovers, dark alerts.
* **Light**: `0xFFE6F4EA` (Mint Sage) — Success snackbars, background highlights.

### 4. Neutral Colors
The structural backbone of the UI, managing layout hierarchy, text readability, and screen depth.
* **Background**: `0xFFF8FAFC` — App canvas background.
* **Surface**: `0xFFFFFFFF` — Cards, text fields, headers, dialogues.
* **Border**: `0xFFE2E8F0` — Thin dividers, inactive input borders, subtle frames.
* **Text Primary**: `0xFF1E2D3D` — Header labels, field values, readable text.
* **Text Secondary**: `0xFF7E97A6` — Hint placeholder text, subtitles, muted descriptors.

---

## ✍️ Typography Scales

All typography uses **Plus Jakarta Sans** for a contemporary, legible, and premium appearance. Access these styles via `AppTextStyles` or standard Flutter `Theme.of(context).textTheme`.

| Style Name | Font Size | Font Weight | Line Height | Usage |
| :--- | :---: | :---: | :---: | :--- |
| `AppTextStyles.h1` | 90 | Bold (w700) | 1.17 | Massive display statistics |
| `AppTextStyles.h3` | 75 | Bold (w700) | 1.40 | Large layout displays |
| `AppTextStyles.h4` | 54 | Bold (w700) | 1.66 | Sub-display / main page titles |
| `AppTextStyles.h5` | 34 | Bold (w700) | 1.26 | Page headers |
| `AppTextStyles.headingSubtitle` | 32 | Bold (w700) | 1.34 | Large sections, main header callouts |
| `AppTextStyles.smallSubtitle` | 32 | Medium (w500) | 1.34 | Secondary main text |
| `AppTextStyles.bodyLarge` | 16 | Normal (w400) | Auto | Main input labels, main body text |
| `AppTextStyles.bodyMedium` | 14 | Normal (w400) | Auto | Standard body text, hints, checklists |
| `AppTextStyles.bodySmall` | 12 | Normal (w400) | Auto | Muted descriptive text |
| `AppTextStyles.labelLarge` | 16 | Bold (w700) | Auto | Primary button labels, tabs |
| `AppTextStyles.labelMedium` | 14 | Bold (w700) | Auto | Action labels, mini buttons |
| `AppTextStyles.small` | 12 | Medium (w500) | 1.66 | Under-labeled hints, error warnings |

---

## 🛠️ Code Rules of Engagement

To prevent "design gaps," developers must strictly follow these rules:

### Rule 1: No Hardcoded hex colors in widgets
> ❌ **INCORRECT**:
> ```dart
> color: const Color(0xFF4A78A4)
> ```
> 
> ✅ **CORRECT**:
> ```dart
> color: AppColors.primary
> ```

### Rule 2: No direct `GoogleFonts.someFont(...)` imports inside Page code
Always import `google_fonts` inside `app_theme.dart` and expose typography scales via `AppTextStyles` or standard theme contexts. This allows switching fonts globally in one single place.
> ❌ **INCORRECT**:
> ```dart
> Text('Sign up', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold))
> ```
> 
> ✅ **CORRECT**:
> ```dart
> Text('Sign up', style: AppTextStyles.h5) // Or customized using copyWith:
> Text('Sign up', style: AppTextStyles.h5.copyWith(color: AppColors.primary))
> ```

### Rule 3: Leverage context theme lookups for structural widgets
Let MaterialApp structure handle dynamic colors or localized styling properties.
> ✅ **CORRECT**:
> ```dart
> Scaffold(
>   backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Resolves to AppColors.background
>   body: Text('Hello', style: Theme.of(context).textTheme.bodyMedium),
> )
> ```

### Rule 4: Handle brand colors as standard constants (if external)
Third-party platform colors (e.g., Apple, Facebook, Google) that are outside the app brand palette should be handled as specific external icon/asset colors, not mixed with branding tokens.
