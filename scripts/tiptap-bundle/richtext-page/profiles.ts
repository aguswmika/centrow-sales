// Source of truth: centrow web/app/components/ui/richtext-page. centrow-sales copies this file into scripts/tiptap-bundle — copy, do not edit downstream.
// Margins mirror pkg/contractpdf/assets/base.gohtml (@page{margin:24mm 18mm 22mm}) for themed profiles,
// and pkg/richtext/html.go WrapPrintDocument (@page{size:A4;margin:20mm}) for plain.

export type PageProfileId =
    | "theme-1"
    | "theme-2"
    | "theme-3"
    | "theme-4"
    | "theme-5"
    | "plain";

export type PageProfile = {
    id: PageProfileId;
    widthMm: number;
    heightMm: number;
    marginMm: { top: number; right: number; bottom: number; left: number };
};

export type PageLayout =
    | { profile: "plain" }
    | { profile: "theme"; theme: number };

const A4_WIDTH_MM = 210;
const A4_HEIGHT_MM = 297;
const THEMED_MARGIN_MM = { top: 24, right: 18, bottom: 22, left: 18 };
// Mirrors WrapPrintDocument @page{size:A4;margin:20mm}; addendum PDFs carry a 20mm margin on every side.
const PLAIN_MARGIN_MM = { top: 20, right: 20, bottom: 20, left: 20 };

export const PAGE_PROFILES: Record<PageProfileId, PageProfile> = {
    "theme-1": {
        id: "theme-1",
        widthMm: A4_WIDTH_MM,
        heightMm: A4_HEIGHT_MM,
        marginMm: THEMED_MARGIN_MM,
    },
    "theme-2": {
        id: "theme-2",
        widthMm: A4_WIDTH_MM,
        heightMm: A4_HEIGHT_MM,
        marginMm: THEMED_MARGIN_MM,
    },
    "theme-3": {
        id: "theme-3",
        widthMm: A4_WIDTH_MM,
        heightMm: A4_HEIGHT_MM,
        marginMm: THEMED_MARGIN_MM,
    },
    "theme-4": {
        id: "theme-4",
        widthMm: A4_WIDTH_MM,
        heightMm: A4_HEIGHT_MM,
        marginMm: THEMED_MARGIN_MM,
    },
    "theme-5": {
        id: "theme-5",
        widthMm: A4_WIDTH_MM,
        heightMm: A4_HEIGHT_MM,
        marginMm: THEMED_MARGIN_MM,
    },
    plain: {
        id: "plain",
        widthMm: A4_WIDTH_MM,
        heightMm: A4_HEIGHT_MM,
        marginMm: PLAIN_MARGIN_MM,
    },
};

// 1mm = 96/25.4 CSS px at 96dpi.
export const MM_TO_PX = 96 / 25.4;

export function mmToPx(mm: number): number {
    return mm * MM_TO_PX;
}

const THEME_PROFILE_IDS = [
    "theme-1",
    "theme-2",
    "theme-3",
    "theme-4",
    "theme-5",
] as const;

export function resolvePageProfile(layout: PageLayout | undefined): PageProfile {
    if (!layout || layout.profile === "plain") {
        return PAGE_PROFILES.plain;
    }
    const index = Number.isInteger(layout.theme) ? layout.theme - 1 : -1;
    // Invalid or out-of-range theme falls back to theme-1.
    const id = THEME_PROFILE_IDS[index] ?? "theme-1";
    return PAGE_PROFILES[id];
}

export function contentHeightPx(p: PageProfile): number {
    return mmToPx(p.heightMm - p.marginMm.top - p.marginMm.bottom);
}

export function contentWidthPx(p: PageProfile): number {
    return mmToPx(p.widthMm - p.marginMm.left - p.marginMm.right);
}
