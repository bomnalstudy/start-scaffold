import type { Role } from "./types";

export type Language = "ko" | "en";

type TextKey =
  | "title" | "eyebrow" | "search" | "searchPlaceholder" | "language" | "roles" | "all"
  | "flow" | "details" | "generated" | "filesScanned" | "components" | "references"
  | "summary" | "files" | "localRefs" | "incoming" | "outgoing" | "live" | "loading" | "error"
  | "workspace" | "map" | "favorites" | "pureChaos" | "responsibilities" | "relationships"
  | "terms" | "evidence" | "workflow" | "progress";

const ko = {
  title: "\ucf54\ub4dc \ud50c\ub85c\uc6b0 \ub9f5",
  eyebrow: "Vibe coding map",
  search: "\uac80\uc0c9",
  searchPlaceholder: "\ub178\ub4dc, \ud30c\uc77c, \uc5ed\ud560",
  language: "\uc5b8\uc5b4",
  roles: "\uc5ed\ud560",
  all: "\uc804\uccb4",
  flow: "\ud750\ub984",
  details: "\uc0c1\uc138",
  generated: "\uc0dd\uc131\ub428",
  filesScanned: "\uc2a4\uce94\ud55c \ud30c\uc77c",
  components: "\ucef4\ud3ec\ub10c\ud2b8",
  references: "\ucc38\uc870",
  summary: "\uc694\uc57d",
  files: "\ud30c\uc77c",
  localRefs: "\ub85c\uceec \ucc38\uc870",
  incoming: "\ub4e4\uc5b4\uc634",
  outgoing: "\ub098\uac10",
  live: "\uc2e4\uc2dc\uac04 \uac10\uc2dc",
  loading: "\uad00\uacc4\ub3c4\ub97c \ubd88\ub7ec\uc624\ub294 \uc911\uc785\ub2c8\ub2e4.",
  error: "\uad00\uacc4\ub3c4\ub97c \ubd88\ub7ec\uc624\uc9c0 \ubabb\ud588\uc2b5\ub2c8\ub2e4.",
  workspace: "\uc791\uc5c5 \uacf5\uac04",
  map: "\ub9f5",
  favorites: "\uc8fc\uc694 \uc5ed\ud560",
  pureChaos: "\uc804\uccb4 \uad6c\uc870",
  responsibilities: "\ud558\ub294 \uc77c",
  relationships: "\uad00\uacc4 \uc124\uba85",
  terms: "\uc6a9\uc5b4 \ud480\uc774",
  evidence: "\uadfc\uac70",
  workflow: "\uc791\ub3d9 \ud750\ub984",
  progress: "\ubd84\uc11d \uc9c4\ud589",
  roleNames: {
    automation: "\uc2e4\ud589 \uc2a4\ud06c\ub9bd\ud2b8",
    backend: "\ubc31\uc5d4\ub4dc",
    config: "\uc124\uc815",
    database: "\ub370\uc774\ud130\ubca0\uc774\uc2a4",
    domain: "\uc5c5\ubb34 \ub85c\uc9c1",
    docs: "\ubb38\uc11c",
    entrypoint: "\uc571 \uc2dc\uc791\uc810",
    orchestration: "\uc624\ucf00\uc2a4\ud2b8\ub808\uc774\uc158",
    repository: "\ub370\uc774\ud130 \uc811\uadfc",
    security: "\ubcf4\uc548",
    skill: "\uc2a4\ud0ac",
    service: "\uc11c\ube44\uc2a4 \ub85c\uc9c1",
    ui: "UI",
    verification: "\ud14c\uc2a4\ud2b8/\uac80\uc99d",
    project: "\ud504\ub85c\uc81d\ud2b8",
  },
};

const en = {
  title: "Code Flow Map",
  eyebrow: "Vibe coding map",
  search: "Search",
  searchPlaceholder: "node, file, role",
  language: "Language",
  roles: "Roles",
  all: "All",
  flow: "Flow",
  details: "Details",
  generated: "Generated",
  filesScanned: "Files scanned",
  components: "Components",
  references: "References",
  summary: "Summary",
  files: "Files",
  localRefs: "Local refs",
  incoming: "incoming",
  outgoing: "outgoing",
  live: "Live watch",
  loading: "Loading code flow.",
  error: "Could not load code flow.",
  workspace: "Workspace",
  map: "Map",
  favorites: "Favorites",
  pureChaos: "Full structure",
  responsibilities: "Responsibilities",
  relationships: "Relationships",
  terms: "Terms",
  evidence: "Evidence",
  workflow: "Workflow",
  progress: "Progress",
  roleNames: {
    automation: "run scripts",
    backend: "backend",
    config: "config",
    database: "database",
    domain: "domain logic",
    docs: "docs",
    entrypoint: "app entrypoint",
    orchestration: "orchestration",
    repository: "data access",
    security: "security",
    skill: "skill",
    service: "service logic",
    ui: "UI",
    verification: "tests/checks",
    project: "project",
  },
};

const text = { ko, en } satisfies Record<Language, Record<TextKey, string> & { roleNames: Record<Role | "project", string> }>;

export function createTranslator(language: Language) {
  return {
    t: (key: TextKey) => text[language][key],
    role: (role: Role | "project") => text[language].roleNames[role] ?? role,
  };
}

export function roleSummary(role: Role | "project", language: Language) {
  const koSummary: Record<Role | "project", string> = {
    automation: "\uc0ac\ub78c\uc774 \uc190\uc73c\ub85c \ubc18\ubcf5\ud558\uae30 \ubc88\uac70\ub85c\uc6b4 \uc2e4\ud589, \uc0dd\uc131, \uc810\uac80 \uc791\uc5c5\uc744 \ub300\uc2e0 \ub3cc\ub9ac\ub294 \uc2a4\ud06c\ub9bd\ud2b8 \uc601\uc5ed\uc785\ub2c8\ub2e4.",
    backend: "\uc694\uccad \ucc98\ub9ac\uc640 \uc11c\ubc84 \ucabd \uae30\ub2a5\uc744 \ub2f4\ub2f9\ud558\ub294 \uc601\uc5ed\uc785\ub2c8\ub2e4.",
    config: "\ub3c4\uad6c\uc640 \uc2e4\ud589 \ud658\uacbd\uc758 \uc124\uc815\uac12\uc744 \uad00\ub9ac\ud569\ub2c8\ub2e4.",
    database: "\ub370\uc774\ud130 \uad6c\uc870, \uc800\uc7a5\uc18c, \uc2a4\ud0a4\ub9c8\uc640 \uac00\uae4c\uc6b4 \uc601\uc5ed\uc785\ub2c8\ub2e4.",
    domain: "\uc11c\ube44\uc2a4, \ud654\uba74, \uc800\uc7a5\uc18c\ub85c \ub531 \ub098\ub258\uc9c0 \uc54a\ub294 \ud504\ub85c\uc81d\ud2b8 \uace0\uc720\uc758 \uc5c5\ubb34 \uaddc\uce59\uacfc \ucc98\ub9ac \ub85c\uc9c1\uc785\ub2c8\ub2e4.",
    docs: "\ud504\ub85c\uc81d\ud2b8 \uc758\ub3c4, \uaddc\uce59, \uc0ac\uc6a9\ubc95\uc744 \uc124\uba85\ud558\ub294 \ubb38\uc11c \uc601\uc5ed\uc785\ub2c8\ub2e4.",
    entrypoint: "\uc571\uc774 \ucc98\uc74c \uc2dc\uc791\ub420 \ub54c \uc2e4\ud589\ub418\ub294 \ud30c\uc77c\uc774\ub098 \ucd08\uae30 \uc5f0\uacb0\uc744 \ub2f4\ub2f9\ud558\ub294 \uc601\uc5ed\uc785\ub2c8\ub2e4.",
    orchestration: "\uc791\uc5c5 \uc21c\uc11c, \uc0c1\ud0dc \uc804\ub2ec, \uc5d0\uc774\uc804\ud2b8 \ud750\ub984\uc744 \uc870\uc728\ud569\ub2c8\ub2e4.",
    repository: "\ub370\uc774\ud130\ubca0\uc774\uc2a4\ub098 \uc800\uc7a5\uc18c\uc5d0\uc11c \ub370\uc774\ud130\ub97c \uc77d\uace0 \uc4f0\ub294 \uc811\uadfc \uacc4\uce35\uc785\ub2c8\ub2e4.",
    security: "\uc2dc\ud06c\ub9bf, \uc778\uc99d, \uad8c\ud55c, \uc548\uc804\ud55c \uae30\ubcf8\uac12\uc744 \ub2e4\ub8f9\ub2c8\ub2e4.",
    skill: "AI \uc5d0\uc774\uc804\ud2b8\uac00 \ud2b9\uc815 \uc791\uc5c5\uc744 \ub354 \uc798 \uc218\ud589\ud558\ub3c4\ub85d \uc815\uc758\ud55c \uc2a4\ud0ac \uc124\uba85 \ud30c\uc77c\uc785\ub2c8\ub2e4.",
    service: "\uc694\uccad\uc744 \ubc1b\uc740 \ub4a4 \uc2e4\uc81c \uc77c\uc744 \ucc98\ub9ac\ud558\uace0 \ub2e4\ub978 \uacc4\uce35\uc744 \uc5f0\uacb0\ud558\ub294 \uc2e4\ud589 \ub85c\uc9c1\uc785\ub2c8\ub2e4.",
    ui: "\uc0ac\uc6a9\uc790\uac00 \ubcf4\ub294 \ud654\uba74\uacfc \uc0c1\ud638\uc791\uc6a9\uc744 \ub2f4\ub2f9\ud569\ub2c8\ub2e4.",
    verification: "\ubcc0\uacbd \ud6c4 \uae30\ub2a5\uc774 \uae68\uc9c0\uc9c0 \uc54a\uc558\ub294\uc9c0 \ud655\uc778\ud558\ub294 \ud14c\uc2a4\ud2b8\uc640 \uac80\uc99d \uc601\uc5ed\uc785\ub2c8\ub2e4.",
    project: "\ud604\uc7ac \ucf54\ub4dc\ubca0\uc774\uc2a4 \uc804\uccb4\ub97c \ub098\ud0c0\ub0b4\ub294 \uc2dc\uc791\uc810\uc785\ub2c8\ub2e4.",
  };
  const enSummary: Record<Role | "project", string> = {
    automation: "Runs repeatable scripts for generation, checks, and maintenance.",
    backend: "Handles server-side request and feature behavior.",
    config: "Keeps tool and runtime configuration.",
    database: "Stays close to data structures, storage, and schema.",
    domain: "Contains project-specific business rules that do not fit a narrower layer.",
    docs: "Explains project intent, rules, and usage.",
    entrypoint: "Starts the app or wires up the first runtime connection.",
    orchestration: "Coordinates task order, state handoff, and agent flow.",
    repository: "Reads and writes data through storage-facing functions.",
    security: "Covers secrets, auth, permissions, and safer defaults.",
    skill: "Defines specialized AI-agent behavior for a particular type of work.",
    service: "Runs feature work and connects routes, data access, and workers.",
    ui: "Owns user-facing screens and interactions.",
    verification: "Owns tests, checks, harnesses, and validation rules.",
    project: "Start point for the current codebase.",
  };
  return (language === "ko" ? koSummary : enSummary)[role];
}
