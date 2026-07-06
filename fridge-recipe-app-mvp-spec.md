# Fridge-to-Recipe App — Rebrand, Redesign & MVP Architecture

> Reference app: "Kouk" (com.bk.kouk) — core concept: enter ingredients you have → get matching recipes → view recipe detail with step-by-step video.
> This spec is a **clean-room rebuild**: same concept, new brand, new design, new codebase.

---

## 1. Product Recap (what the original does)

- **Ingredient input** — user selects/enters what's in their fridge/pantry
- **Recipe matching** — app returns recipes that can be made from those ingredients
- **Recipe detail** — steps + video, presumably ingredient quantities

Gaps worth improving in the rebuild:
- No visible personalization (diet, allergies, cuisine preference)
- No favorites/saved recipes, meal planning, or shopping list generation
- No account/sync across devices
- Only 10+ installs — likely limited due to a single language/region, and no growth loops (sharing, notifications)

---

## 2. Rebrand

### Name direction
Something evocative of "what's in your kitchen" without copying "Kouk":

| Name | Angle |
|---|---|
| **Fridgely** | Playful, English-first, easy to trademark-check |
| **PantryPal** | Friendly, assistant framing |
| **Yumleft** | "What's left → what's for dinner" |
| **Chefless** | "Be your own chef" positioning |
| **Ingrid** *(Ingredient + friendly name)* | Memorable, brandable mascot potential |

Pick one you can secure as a domain + app store name + trademark-clear in your target market before committing.

### Positioning
"Cook confidently with what you already have — no more staring into the fridge wondering what to make."

### Visual identity direction
- **Color palette**: warm, appetite-triggering but not generic-food-red — e.g. a burnt-orange/terracotta primary + a fresh sage-green accent (differentiates from every red/orange food app)
- **Typography**: a rounded, friendly sans (e.g. Inter/Poppins) for UI, a slightly editorial serif for recipe titles to feel more "recipe-book" than "utility app"
- **Iconography**: hand-drawn/illustrated ingredient icons rather than flat stock icons — reinforces warmth and food personality
- **Tone of voice**: casual, encouraging, zero-jargon ("You've got enough for 6 dinners tonight 🍲")

---

## 3. UX/UI Redesign

### Core flow (kept, but upgraded)
1. **Onboarding** (new) — quick diet/allergy/cuisine preferences (optional, skippable)
2. **My Kitchen** (was "ingredients") — searchable, category-grouped ingredient picker with visual chips + a barcode/photo-scan stretch goal
3. **Recipe feed** — recipes ranked by "% ingredients you already have," with a match-percentage badge, filters (time, difficulty, diet)
4. **Recipe detail** — hero image/video, ingredient checklist (auto-checks what you have vs. what you need to buy), step-by-step with embedded video, a "Cook Mode" (screen-stays-on, large text, timers)
5. **Saved/Favorites + Shopping List** (new) — missing ingredients from a recipe get pushed into a shopping list

### Screen list for MVP
- Splash/Onboarding
- My Kitchen (ingredient selection)
- Recipe Results (list/grid)
- Recipe Detail
- Favorites
- Shopping List
- Settings/Profile

I can generate actual high-fidelity mockups (Figma-style screens) as an interactive artifact if useful — just say the word.

---

## 4. MVP Technical Architecture

### 4.1 High-level approach
Two viable paths for the data layer — pick based on speed vs. control:

| Option | Description | Best for |
|---|---|---|
| **A. Third-party recipe API** (Spoonacular, Edamam, TheMealDB) | Use their "find by ingredients" + recipe detail endpoints | Fastest MVP, no content to maintain, costs scale with usage |
| **B. Custom backend + own DB** | You own/curate the ingredient & recipe dataset | Full control, no per-call cost long-term, more upfront work |

**Recommendation for MVP: Option A** (e.g. Spoonacular's `findByIngredients` + `recipeInformation` endpoints) behind your own thin backend, so you're never locked to their contract and can swap/blend in your own recipes later (hybrid path to B).

### 4.2 System diagram

```
┌─────────────────────┐         ┌──────────────────────┐        ┌───────────────────────┐
│   Flutter App        │  HTTPS  │  Your Backend (BFF)   │  HTTPS │  3rd-party Recipe API  │
│  (iOS/Android)        │ ──────▶ │  Node/Nest or         │ ─────▶ │  (Spoonacular/Edamam)  │
│                       │ ◀────── │  Firebase Functions   │ ◀───── │                        │
└─────────────────────┘         └──────────┬────────────┘        └───────────────────────┘
                                            │
                                   ┌────────▼────────┐
                                   │  Your DB          │
                                   │  (users, saved     │
                                   │  recipes, cache,   │
                                   │  shopping lists)   │
                                   └────────────────────┘
```

Why a backend-for-frontend (BFF) instead of calling the recipe API directly from Flutter:
- Hides your API key (never ship third-party keys in the app binary)
- Lets you cache/normalize responses, add your own ranking logic, and merge in your own recipes later without an app update
- Central point for auth, favorites, shopping list persistence

### 4.3 Suggested stack

| Layer | Choice | Why |
|---|---|---|
| Frontend | Flutter (Dart) | Reuses team's existing skill, cross-platform |
| State management | Riverpod (or Bloc if team prefers stricter separation) | Testable, scales well past MVP |
| Networking | `dio` + `retrofit` (typed clients) | Interceptors for auth/caching, typed API layer |
| Local cache | `hive` or `drift` (sqlite) | Offline "My Kitchen" list, cached last-seen recipes |
| Backend | NestJS (Node/TS) **or** Firebase Cloud Functions | Nest if you want a real service long-term; Firebase if you want zero-ops for MVP |
| Backend DB | PostgreSQL (Nest) or Firestore (Firebase) | Users, favorites, shopping lists, ingredient taxonomy |
| Auth | Firebase Auth or Supabase Auth | Fast to integrate, handles social login |
| Recipe data | Spoonacular API (MVP) | Mature "ingredients → recipes" endpoint, good detail payload |
| Media | Recipe API's provided video/image URLs initially; move to your own CDN once you add original content | |
| CI/CD | Codemagic or GitHub Actions + Fastlane | Flutter-native CI options |
| Analytics | Firebase Analytics / PostHog | Track ingredient→recipe conversion funnel |

### 4.4 Flutter project structure (feature-first)

```
lib/
├── app/                      # app bootstrap, routing, theming
├── core/
│   ├── network/              # dio client, interceptors, error handling
│   ├── storage/              # hive/drift setup
│   └── widgets/              # shared design-system components
├── features/
│   ├── kitchen/              # ingredient selection
│   │   ├── data/             # repository, DTOs
│   │   ├── domain/           # models, use-cases
│   │   └── presentation/     # screens, controllers/providers
│   ├── recipes/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── recipe_detail/
│   ├── favorites/
│   ├── shopping_list/
│   └── auth/
└── main.dart
```

### 4.5 Core API contracts (your BFF, not the 3rd-party one directly)

**GET `/ingredients`**
Returns the master ingredient list (for the picker), grouped by category.
```json
{
  "categories": [
    {
      "name": "Vegetables",
      "items": [
        { "id": "tomato", "label": "Tomato", "icon": "🍅" },
        { "id": "onion", "label": "Onion", "icon": "🧅" }
      ]
    }
  ]
}
```

**POST `/recipes/search`**
Body: `{ "ingredients": ["tomato", "onion", "egg"], "filters": { "maxTime": 30, "diet": "vegetarian" } }`
Returns ranked recipes.
```json
{
  "results": [
    {
      "id": "r_1023",
      "title": "Shakshuka",
      "image": "https://.../shakshuka.jpg",
      "matchPercent": 85,
      "missingIngredients": ["bell pepper"],
      "cookTimeMinutes": 25
    }
  ]
}
```

**GET `/recipes/:id`**
Full detail for the recipe screen.
```json
{
  "id": "r_1023",
  "title": "Shakshuka",
  "video": "https://.../shakshuka.mp4",
  "servings": 2,
  "ingredients": [
    { "name": "Tomato", "quantity": "4", "unit": "pcs", "have": true },
    { "name": "Bell pepper", "quantity": "1", "unit": "pc", "have": false }
  ],
  "steps": [
    { "order": 1, "text": "Dice the onions and peppers.", "timerSeconds": null },
    { "order": 2, "text": "Simmer for 10 minutes.", "timerSeconds": 600 }
  ]
}
```

Behind the scenes, `/recipes/search` and `/recipes/:id` call Spoonacular's `findByIngredients` and `recipeInformation` endpoints, normalize the payload into the shape above, and cache results (e.g. Redis or Postgres table with a TTL) to control API costs.

### 4.6 MVP build phases

| Phase | Scope |
|---|---|
| **0. Foundation** | Flutter app skeleton, design system/theme, navigation, BFF skeleton + recipe API integration |
| **1. Core loop** | My Kitchen picker → Recipe results → Recipe detail (no auth yet, local-only ingredient list) |
| **2. Persistence** | Auth, favorites, shopping list, sync kitchen list to backend |
| **3. Polish** | Filters (diet/time/difficulty), Cook Mode, onboarding preferences, analytics funnel |
| **4. Growth** | Push notifications ("You have ingredients for a great dinner tonight"), sharing, referral |

---

## 5. Next steps I can help with
- Generate actual UI mockups/interactive prototype for the redesigned screens
- Scaffold the real Flutter project (folder structure + starter code for the kitchen/recipes/detail features)
- Scaffold the BFF backend (NestJS or Firebase Functions) with the `/ingredients`, `/recipes/search`, `/recipes/:id` endpoints
- Draft brand assets (logo direction, color tokens, type scale)

Tell me which of these to start with, or if you'd rather I just start scaffolding the Flutter app directly.
