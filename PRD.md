Product Requirements Document (PRD)

Labour Party – Offline Labour & Trip Management App

Android Only • Flutter • Material 3 • Hive + BLoC • Clean Architecture


---

1. Project Overview

App Name

Labour Party

Purpose

Labour Party is a fully offline Android application for managing daily labour work trips, tractor trips, labour attendance, work tracking, and trip-wise labour management.

The application is designed for:

Personal use

Fast real-world data entry

Ultra-simple workflow

Industry-level premium UI/UX

High performance on low-end Android devices

Minimal screens with powerful workflow


The app must avoid unnecessary complexity while maintaining professional enterprise-grade UX quality.


---

2. Core Product Vision

The app should feel like:

A premium industrial operations app

Extremely fast and smooth

Visually modern and polished

Minimal but powerful

Built for real daily usage in harsh environments

One-hand friendly

Zero internet dependency

Zero login/authentication

Zero cloud dependency



---

3. Technical Requirements

Platform

Android only


Framework

Flutter (latest stable)


Architecture

Clean Architecture

BLoC Pattern

Repository Pattern

Service Layer

Feature-first modular structure


Local Database

Hive


State Management

flutter_bloc


Dependency Injection

get_it


Routing

go_router



---

4. Target APK Size

Required APK Size

Target: 5 MB – 10 MB


Optimization Requirements

Use vector assets only where possible

Avoid heavy packages

Avoid unnecessary animations libraries

Use Lottie only for selected animations

Enable:

R8

Proguard

Tree shaking

Split debug symbols




---

5. Application Package ID

Recommended Package IDs

Primary

com.roshan.labourparty

Alternative

com.labour.party

Alternative Professional

com.roshan.labourparty.offline


---

6. Design System

Design Language

Material Design 3

Glassmorphism

Industrial premium UI

Smooth micro-interactions

Modern shadows

Frosted cards

Soft blur overlays

Dynamic elevation

Motion-based navigation



---

7. Required UI Libraries

Primary UI

Material 3

Flutter Material 3 system

Additional Professional UI Libraries

1. flutter_animate

For:

Smooth transitions

Entry animations

Micro interactions


2. glassmorphism_ui

For:

Frosted cards

Premium dashboard sections

Overlay surfaces



---

8. Theme System

Theme Type

Dark Theme (Primary)

Light Theme (Optional)


Color Palette

Primary

Industrial Blue #246BFD

Accent

Electric Cyan #00D2FF

Success

#00C853

Error

#FF3B30

Background

#0F172A

Surface

#1E293B


---

9. Typography

Font Family

Primary

Poppins

Secondary

Inter


---

10. Animation Requirements

Required Animations

Smooth screen transitions

Button press ripple physics

Floating add button expansion

Card elevation animation

Swipe actions

Animated list insertion

Skeleton shimmer loading

Glass blur transitions

Hero transitions


Animation Duration

150ms to 350ms

Never slow



---

11. Navigation System

Navigation Type

Bottom Navigation Bar

Bottom Tabs

1. Dashboard


2. Details


3. Settings




---

12. Back Navigation Rules

Required Back Arrow

ALL secondary screens must include:

Top-left back arrow


Behavior

Priority order:

1. Close dialog


2. Close overlay


3. Close bottom sheet


4. Navigate back




---

13. Screen Architecture

Total Screens (Minimal Professional Structure)

Screen	Purpose

Splash Screen	Branding & initialization
Dashboard Screen	Main operations
Add/Edit Work Screen	Trip management
Details Screen	Full records table
Trip Details Screen	Detailed day breakdown
Settings Screen	Backup/theme/reset



---

14. Complete Workflow

Splash
   ↓
Dashboard
   ↓
Add/Edit Work
   ↓
Save Trip
   ↓
Auto Update Dashboard
   ↓
Details Table
   ↓
Trip Detail View


---

15. Dashboard Screen (Main Screen)

Purpose

Primary operational screen for daily usage.


---

Dashboard Layout

Top App Bar

Contains

App logo

Current date

Quick statistics

Search icon



---

Dashboard Sections

1. Today's Summary Card

Shows

Current date

Morning trip count

Evening trip count

Total trips

Total labour count


UI

Glassmorphism premium card.


---

2. Quick Trip Counter

Components

Minus button

Trip count

Plus button


Behavior

When + pressed

Automatically create next trip

Auto copy previous labour list

Auto increment trip count

Open edit sheet


When - pressed

Remove latest trip safely

Confirmation required



---

3. Add Work Floating Button

Large Premium Floating Button

Gradient

Glow effect

Animated pulse


On Click

Open Add/Edit Work Screen.


---

4. Recent Trips List

Shows

Trip number

Work type

Time

Tractor

Driver

Labour count


Swipe Actions

Edit

Delete



---

16. Add/Edit Work Screen

Purpose

Main data entry screen.


---

Header Section

Auto Date Detection

Automatically detect:

Current date

Morning/evening

Current time



---

Fields Structure

1. Date

Default

Auto current date

Editable

Yes


---

2. Time Session

Options

Morning

Evening


Auto Detection Logic

Time	Session

4 AM – 12 PM	Morning
12 PM – 11 PM	Evening



---

3. Work Type

Default Options

Sand (Bali)


Custom Add

Allowed


---

4. Place

Text input


---

Trip Section Structure

Trip 1
 ├ Tractor
 ├ Driver
 ├ Labour List


---

Tractor Selection

Options

Sonalika

JohnDeere


Dropdown chips UI.


---

Driver Name

Autocomplete text field.


---

Labour List System

Features

Add labour

Remove labour

Mark absent

Auto copy from previous trip



---

Labour Card UI

Each labour row contains:

Name

Status indicator

Minus button



---

Absent Labour Logic

If labour absent:

Red left border

Red glow dot

Label: "Not working this trip"



---

Trip Auto-Copy Logic

When New Trip Added

Automatically copy:

Labour names

Tractor

Driver


User can edit changes.


---

Trip Counting Logic

Morning Logic

Example:

Morning:
Trip 1
Trip 2
Trip 3
Trip 4

Evening Logic

If morning exists:

Evening:
Trip 5
Trip 6

If no morning work:

Evening:
Trip 1
Trip 2


---

17. Details Screen

Purpose

Professional industrial-level table view.


---

UI Style

Sticky headers

Smooth scroll

Search

Filter chips

Export-ready structure



---

Table Columns

Column	Description

Date	Work date
Time	Morning/Evening
Trip	Trip number
Work	Work type
Tractor	Tractor used
Driver	Driver name
Labour Count	Present labour
Place	Location



---

Row Interaction

Tap

Open Trip Details Screen.

Swipe

Edit

Delete



---

18. Trip Details Screen

Purpose

Detailed breakdown of single work day.


---

Sections

Work Info

Date

Time

Place

Work type


Trip Timeline

Timeline UI for:

Trip 1

Trip 2

Trip 3


Labour Status

Present/Absent indicators.


---

19. Settings Screen

Minimal Settings Only

Options

Backup database

Restore database

Reset app

Theme mode

About app



---

20. Database Structure

Hive Boxes

1. work_box

Fields

id
date
session
workType
place
createdAt
updatedAt


---

2. trip_box

Fields

id
workId
tripNumber
tractor
driverName
createdAt


---

3. labour_box

Fields

id
name
phoneOptional
createdAt


---

4. trip_labour_box

Fields

id
tripId
labourId
isPresent


---

21. Clean Architecture Structure

lib/
 ├ core/
 ├ config/
 ├ features/
 │   ├ dashboard/
 │   ├ work/
 │   ├ details/
 │   ├ settings/
 │
 ├ shared/
 ├ services/
 ├ routes/
 ├ theme/
 └ main.dart


---

22. BLoC Structure

Required BLoCs

BLoC	Purpose

DashboardBloc	Dashboard state
WorkBloc	Work CRUD
TripBloc	Trip operations
LabourBloc	Labour management
SettingsBloc	Settings



---

23. Required States

Every feature MUST contain:

States

Initial

Loading

Loaded

Empty

Error

Success



---

24. Skeleton Loading

Required

All screens must support:

Skeleton cards

Shimmer table rows

Animated placeholders



---

25. Empty States

Example

Dashboard Empty State

Illustration + text: "No work added today"

CTA

"Add First Trip"


---

26. Error States

Required Error Handling

Database Error

Retry button


Validation Error

Inline field validation.

Unexpected Error

Error dialog with recovery.


---

27. Required Permissions

Android Permissions

Storage

READ_EXTERNAL_STORAGE
WRITE_EXTERNAL_STORAGE

Android 13+

READ_MEDIA_IMAGES


---

28. Android Configuration

Minimum SDK

24

Target SDK

Latest stable

Kotlin

Latest stable


---

29. Performance Requirements

App Launch

< 2 seconds

Scroll Performance

60 FPS

Database Operations

< 100ms


---

30. Security

Requirements

Fully offline

No analytics

No internet permission

No tracking



---

31. Real Data Requirements for AI Coding Agent

STRICT RULES

NEVER USE

Mock data

Fake repositories

Dummy services

Placeholder business logic

Static hardcoded lists

Fake loading



---

Required Real Logic

Dashboard

Must read actual Hive data.

Trip Count

Must calculate from database.

Labour Copy

Must clone previous trip data.

Morning/Evening

Must detect using actual device time.

Details Table

Must use real query/filter logic.


---

32. Required AI Coding Agent Instructions

Mandatory Development Instructions

State Handling

Every API/database call MUST support:

loading

empty

success

failure



---

Validation Rules

Driver Name

Cannot be empty.

Trip

Must contain at least one labour.

Work Type

Cannot be empty.


---

Data Safety

Prevent accidental deletion

Use confirmation dialogs

Auto-save drafts



---

33. UX Rules

One-Hand Friendly

Critical buttons reachable by thumb.

Fast Input

Minimum typing required.

Large Touch Targets

Minimum 48dp.


---

34. UI Components

Required Components

Component	Style

Cards	Glassmorphism
Buttons	Gradient elevated
Inputs	Filled M3
Dialogs	Frosted blur
Chips	Animated
FAB	Premium glowing



---

35. Accessibility

Requirements

Proper contrast

Large text support

Screen reader labels



---

36. Backup & Restore

Backup Type

Hive database export.

File Format

.labourbackup


---

37. Recommended Packages

flutter_bloc
equatable
hive
hive_flutter
path_provider
go_router
get_it
flutter_animate
glassmorphism_ui
intl
lottie
flutter_screenutil


---

38. App Icon Design

Style

Industrial

Minimal

Strong

Blue gradient

Tractor/labour symbolic icon



---

39. Splash Screen

Elements

App logo

Smooth fade animation

Minimal loading indicator


Duration

1.5 seconds max


---

40. UI/UX Quality Requirements

The final application must feel comparable to:

Premium logistics apps

Industrial ERP mobile modules

Modern Material 3 enterprise applications


The UI should NOT look:

Basic

Template-based

Beginner-level

Overcrowded

Old Material 2 style



---

41. Final Product Goals

The application should achieve:

Fast daily operations

Minimal taps

Clear labour tracking

Easy trip management

Professional premium experience

Reliable offline operation



---

42. Future Upgrade Ready Architecture

Architecture should support future additions:

PDF reports

Cloud sync

Multi-user

Wage calculations

Analytics

Voice input

Local notifications


Without major refactoring.


---

43. Final Development Notes

Priority Order

1. Stability


2. Speed


3. Offline reliability


4. UX quality


5. Animation polish



NOT:

Complex features

Excessive screens

Heavy dependencies



---

44. Deliverables

Required Final Deliverables

Flutter source code

Hive database implementation

BLoC architecture

Material 3 UI system

Responsive layouts

Dark theme

Offline logic

Professional animations

Backup/restore

Production-ready structure



---

45. Final Product Summary

Labour Party is a:

Small

Powerful

Offline-first

Premium industrial Flutter app


focused on:

labour trip management

fast daily operations

smooth real-world usability

modern enterprise-grade UX


while remaining:

lightweight

minimal

fast

maintainable

scalable for future upgrades.
