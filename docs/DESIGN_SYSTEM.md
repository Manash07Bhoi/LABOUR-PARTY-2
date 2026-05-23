# Design System

The UI/UX architecture of Labour Party revolves around a premium, industrial dark-theme interface utilizing **Material 3** guidelines tailored for outdoor, harsh lighting field readability.

## 1. Color Palette

- **Primary Color:** `#246BFD` (Vibrant Blue - utilized for primary actions, floating action buttons, and active states).
- **Secondary / Accent Color:** `#00D2FF` (Bright Cyan - used for highlights and subtle gradients).
- **Success Color:** `#00C853` (Vibrant Green - used for positive confirmations).
- **Error Color:** `#xFFFF3B30` (Vibrant Red - used for destructive alerts and error states).
- **Background Base:** `#0F172A` (Deep Slate - pure application background).
- **Surface Level:** `#1E293B` (Elevated Slate - used for Cards, Dialogs, and elevated sections).

## 2. Typography

We employ Google Fonts to strictly manage the application's typographic hierarchy.
- **Headings / Titles:** `Poppins` (Bold/Semi-bold weights) - Providing a clean, robust, mathematical aesthetic.
- **Body / Content:** `Inter` (Regular/Medium weights) - Ensures extreme legibility at small sizes, even in high glare environments.

## 3. Glassmorphism & Aesthetics

The application implements a restrained glassmorphism aesthetic:
- **Cards and Dialogs:** Cards are elevated securely but incorporate minimal border strokes (`Colors.white24`) against the dark surface colors to give depth.
- **Rule of Restraint:** Excessive blurring, over-animation, and visual noise are strictly prohibited. The transparency levels never obscure text.

## 4. Spacing and Geometry

- **Border Radius:** `12px` to `16px` bounds.
- **Padding:** Standardized around `16px` and `24px` margins. Information density must remain comfortably spaced to avoid accidental touches while wearing gloves or in moving vehicles.

## 5. Components

- **Inputs:** `InputDecorationTheme` features filled dark surfaces (`#1E293B`) without extreme outlines unless focused. Focused states illuminate the primary color (`#246BFD`).
- **Buttons:** Fully rounded edge buttons `borderRadius: 12` utilizing the primary color to pop against the dark background.
