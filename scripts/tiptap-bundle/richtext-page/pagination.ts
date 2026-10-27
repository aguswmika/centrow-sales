// Source of truth: centrow web/app/components/ui/richtext-page. centrow-sales copies this file into scripts/tiptap-bundle — copy, do not edit downstream.
// Visual page breaks as ProseMirror decorations. Stored JSON is never changed.
import { Extension } from "@tiptap/core";
import type { Node as PMNode } from "@tiptap/pm/model";
import { Plugin, PluginKey, type PluginView } from "@tiptap/pm/state";
import { Decoration, DecorationSet, type EditorView } from "@tiptap/pm/view";
import {
    PAGE_PROFILES,
    contentHeightPx,
    mmToPx,
    type PageProfile,
    type PageProfileId,
} from "./profiles";

// Height of the grey gap between two sheets. Matches .rt-page-gap in page.css.
// Widget heights are measured from the DOM, so this value is informational.
export const PAGE_GAP_PX = 24;

const TOL = 0.5; // px tolerance for fit checks
const LINE_TOL = 1; // px: coordsAtPos tops closer than this are the same line
const MAX_SCAN = 500; // bounded forward scan for a line start
const MAX_STREAK = 3; // initial dispatch + 2 re-dispatches per reset
const MIN_LINES = 2; // orphans/widows: lines kept on each side of a paragraph split

export type PagePaginationOptions = { profile: PageProfileId };
export type PagePaginationStorage = { profile: PageProfile; pageCount: number };

type PaginationMeta = { decorations?: DecorationSet; remeasure?: boolean };
type PaginationState = { decorations: DecorationSet; remeasure: boolean };
type Cut = { pos: number; block: boolean; filler: number };
type Plan = { cuts: Cut[]; trailingFiller: number; signature: string };

// flow = top of the unit with every break widget above it removed (px).
type Unit = {
    pos: number;
    node: PMNode;
    dom: HTMLElement;
    rect: DOMRect;
    flow: number;
    bottom: number;
};

export const pagePaginationKey = new PluginKey<PaginationState>("pagePagination");

declare module "@tiptap/core" {
    interface Commands<ReturnType> {
        pagePagination: {
            setPageProfile: (id: PageProfileId) => ReturnType;
        };
    }
}

function applyProfileVars(dom: HTMLElement, profile: PageProfile): void {
    const m = profile.marginMm;
    dom.style.setProperty("--rt-margin-top", `${mmToPx(m.top)}px`);
    dom.style.setProperty("--rt-margin-right", `${mmToPx(m.right)}px`);
    dom.style.setProperty("--rt-margin-bottom", `${mmToPx(m.bottom)}px`);
    dom.style.setProperty("--rt-margin-left", `${mmToPx(m.left)}px`);
}

function buildSheetChrome(
    tag: "div" | "span",
    filler: number,
    label: string,
): HTMLElement[] {
    const fillerEl = document.createElement(tag);
    fillerEl.className = "rt-page-filler";
    fillerEl.style.height = `${filler}px`;

    const number = document.createElement("span");
    number.className = "rt-page-number";
    number.textContent = label;

    const footer = document.createElement(tag);
    footer.className = "rt-page-footer";
    footer.append(number);

    return [fillerEl, footer];
}

// Block break: filler + footer + gap + header-space, in one non-editable block.
// Inline break: same parts as spans, used inside a paragraph or list item.
function buildBreakWidget(filler: number, label: string, inline: boolean): HTMLElement {
    const tag = inline ? "span" : "div";
    const root = document.createElement(tag);
    root.className = inline ? "rt-page-break rt-page-break--inline" : "rt-page-break";
    root.contentEditable = "false";
    root.setAttribute("aria-hidden", "true");

    const gap = document.createElement(tag);
    gap.className = "rt-page-gap";
    const header = document.createElement(tag);
    header.className = "rt-page-header-space";

    root.append(...buildSheetChrome(tag, filler, label), gap, header);
    return root;
}

// Trailing widget closes the last sheet. Filler + footer only.
function buildEndWidget(filler: number, label: string): HTMLElement {
    const root = document.createElement("div");
    root.className = "rt-page-end";
    root.contentEditable = "false";
    root.setAttribute("aria-hidden", "true");
    root.append(...buildSheetChrome("div", filler, label));
    return root;
}

function buildDecorations(doc: PMNode, plan: Plan): DecorationSet {
    const total = plan.cuts.length + 1;
    const decos = plan.cuts.map((cut, index) =>
        Decoration.widget(
            cut.pos,
            () => buildBreakWidget(cut.filler, `${index + 1} / ${total}`, !cut.block),
            {
                side: -1,
                ignoreSelection: true,
                key: `rt-break-${index}-${cut.filler}-${total}`,
            },
        ),
    );
    decos.push(
        Decoration.widget(
            doc.content.size,
            () => buildEndWidget(plan.trailingFiller, `${total} / ${total}`),
            {
                side: 1,
                ignoreSelection: true,
                key: `rt-end-${plan.trailingFiller}-${total}`,
            },
        ),
    );
    return DecorationSet.create(doc, decos);
}

function lineHeightPx(dom: HTMLElement, fallback: number): number {
    const lh = parseFloat(getComputedStyle(dom).lineHeight);
    return Number.isFinite(lh) && lh > 0 ? lh : fallback;
}

// First position after `from` whose line top is lower. Bounded scan.
// side 1: at a soft-wrap boundary, report the line that starts there.
function nextLineStart(view: EditorView, from: number, limit: number): number {
    const top = view.coordsAtPos(from, 1).top;
    const end = Math.min(limit, from + MAX_SCAN);
    for (let p = from + 1; p <= end; p++) {
        if (view.coordsAtPos(p, 1).top > top + LINE_TOL) return p;
    }
    return -1;
}

// Finds a line-level cut inside a paragraph or list item so the piece before
// it fits on the sheet, keeping at least MIN_LINES on each side (orphans/widows).
// Returns null when that is impossible.
function findLineSplit(
    view: EditorView,
    u: Unit,
    startFlow: number,
    targetFlow: number,
    unitFlowAt: (u: Unit, y: number) => number,
    viewportAt: (u: Unit, flow: number) => number,
): { pos: number; flow: number } | null {
    const first = u.pos + 1;
    const last = u.pos + u.node.nodeSize - 1;
    const x = u.rect.left + 1;
    const y = viewportAt(u, targetFlow);
    const lh = lineHeightPx(u.dom, 16);

    // Probe the middle of a line, never its edge: at a line boundary posAtCoords
    // returns the start of the next line and the "line above" probe never moves.
    const hit = view.posAtCoords({ left: x, top: y - lh / 2 });
    if (!hit || hit.pos < first || hit.pos > last) return null;

    let pos = hit.pos;
    const probeLine = view.coordsAtPos(pos, 1);
    if (probeLine.bottom > y + TOL) {
        // The probe line crosses the sheet bottom, so use the line above it.
        const above = view.posAtCoords({ left: x, top: probeLine.top - lh / 2 });
        if (!above || above.pos < first || above.pos >= pos) return null;
        pos = above.pos;
    }

    let cut = nextLineStart(view, pos, last);
    if (cut < 0) return null;

    // Line counts in flow coordinates, so break widgets inside the unit never count as lines.
    let flow = unitFlowAt(u, view.coordsAtPos(cut, 1).top);
    let linesBefore = Math.round((flow - startFlow) / lh);
    let linesAfter = Math.round((u.bottom - flow) / lh);

    // Widows: move the cut up a line at a time until enough lines follow it.
    while (linesAfter < MIN_LINES && linesBefore > MIN_LINES) {
        const prevTop = view.coordsAtPos(cut - 1, -1).top;
        const prev = view.posAtCoords({ left: x, top: prevTop + lh / 2 });
        if (!prev || prev.pos < first || prev.pos >= cut) break;
        cut = prev.pos;
        flow = unitFlowAt(u, view.coordsAtPos(cut, 1).top);
        linesBefore -= 1;
        linesAfter += 1;
    }
    if (linesBefore < MIN_LINES || linesAfter < MIN_LINES) return null;

    return flow > startFlow ? { pos: cut, flow } : null;
}

// Measures on the unpaginated layout: every page widget is hidden while measuring and
// restored before the frame paints, so the plan never depends on the widgets it produced
// (measuring the paginated layout made line splits oscillate across passes).
function planPages(view: EditorView, profile: PageProfile): Plan {
    const pageWidgets = view.dom.querySelectorAll<HTMLElement>(".rt-page-break, .rt-page-end");
    pageWidgets.forEach((el) => {
        el.style.display = "none";
    });
    try {
        return planUnpaginated(view, profile);
    } finally {
        pageWidgets.forEach((el) => {
            el.style.display = "";
        });
    }
}

// Read-only pass: measures every unit, then walks them into sheets.
function planUnpaginated(view: EditorView, profile: PageProfile): Plan {
    const H = contentHeightPx(profile);
    const root = view.dom;
    const padTop = parseFloat(getComputedStyle(root).paddingTop) || 0;
    const base = root.getBoundingClientRect().top + padTop;
    const widgets = Array.from(root.querySelectorAll<HTMLElement>(".rt-page-break"), (el) =>
        el.getBoundingClientRect(),
    );

    const sumHeights = (rects: DOMRect[]): number =>
        rects.reduce((sum, r) => sum + r.height, 0);
    const insideUnit = (w: DOMRect, rect: DOMRect): boolean =>
        w.top >= rect.top - TOL && w.bottom <= rect.bottom + TOL;

    // Flow position of a unit's local y, with widgets inside that unit removed.
    const unitFlowAt = (u: Unit, y: number): number =>
        u.flow +
        (y - u.rect.top) -
        sumHeights(widgets.filter((w) => insideUnit(w, u.rect) && w.bottom <= y + TOL));

    // Inverse of unitFlowAt, solved by a short fixed-point iteration.
    const viewportAt = (u: Unit, flow: number): number => {
        const direct = u.rect.top + (flow - u.flow);
        let y = direct;
        for (let k = 0; k < 3; k++) {
            y =
                direct +
                sumHeights(widgets.filter((w) => insideUnit(w, u.rect) && w.bottom <= y + TOL));
        }
        return y;
    };

    // Units: top-level blocks, list items for lists, tables as one unit.
    const units: Unit[] = [];
    const pushUnit = (pos: number, node: PMNode): void => {
        const dom = view.nodeDOM(pos);
        if (!(dom instanceof HTMLElement)) return;
        const rect = dom.getBoundingClientRect();
        const above = sumHeights(widgets.filter((w) => w.bottom <= rect.top + TOL));
        const flow = rect.top - base - above;
        units.push({ pos, node, dom, rect, flow, bottom: 0 });
    };
    view.state.doc.forEach((node, offset) => {
        const isList = node.type.name === "bulletList" || node.type.name === "orderedList";
        if (!isList) {
            pushUnit(offset, node);
            return;
        }
        node.forEach((item, childOffset) => pushUnit(offset + 1 + childOffset, item));
    });
    for (const u of units) {
        u.bottom = unitFlowAt(u, u.rect.bottom);
    }

    // Walk units into sheets. pageTop and contentEnd are flow positions.
    const cuts: Cut[] = [];
    let pageTop = 0;
    let contentEnd = 0;
    const pushCut = (pos: number, block: boolean, end: number): void => {
        cuts.push({ pos, block, filler: Math.max(0, Math.round(H - (end - pageTop))) });
    };

    let i = 0;
    while (i < units.length) {
        const u = units[i];
        if (u.bottom - pageTop <= H + TOL) {
            contentEnd = u.bottom;
            i++;
            continue;
        }

        // Where the part of this unit that is still unplaced begins.
        const start = Math.max(u.flow, pageTop);
        const isText = u.node.type.name === "paragraph" || u.node.type.name === "listItem";
        if (isText) {
            const split = findLineSplit(view, u, start, pageTop + H, unitFlowAt, viewportAt);
            if (split) {
                pushCut(split.pos, false, split.flow);
                pageTop = split.flow;
                contentEnd = pageTop;
                continue; // retry the same unit from the split line
            }
        }

        if (start - pageTop > TOL) {
            // Keep-with-next: a heading that closes this sheet moves with the block.
            let cutIndex = i;
            let end = contentEnd;
            const prev = units[i - 1];
            const beforePrev = units[i - 2];
            if (
                prev &&
                prev.node.type.name === "heading" &&
                prev.flow > pageTop + TOL &&
                beforePrev &&
                beforePrev.bottom > pageTop + TOL
            ) {
                cutIndex = i - 1;
                end = beforePrev.bottom;
            }
            pushCut(units[cutIndex].pos, true, end);
            pageTop = units[cutIndex].flow;
            contentEnd = pageTop;
            i = cutIndex;
            continue;
        }

        // Already at the top of a sheet: accept the overflow (spec: oversized blocks).
        contentEnd = u.bottom;
        i++;
    }

    const trailingFiller = Math.max(0, Math.round(H - (contentEnd - pageTop)));
    const signature =
        cuts.map((c) => `${c.pos}:${c.filler}`).join(",") + `|${trailingFiller}`;
    return { cuts, trailingFiller, signature };
}

function createPaginationView(view: EditorView, storage: PagePaginationStorage): PluginView {
    let frame = 0;
    let destroyed = false;
    let resetPending = true; // doc, profile, width or fonts changed
    let streak = 0; // dispatches since the last reset
    let lastSignature = "";
    let lastWidth = -1;

    const measure = (): void => {
        frame = 0;
        if (destroyed || view.composing) return; // compositionend re-schedules
        if (resetPending) {
            resetPending = false;
            streak = 0;
            // A doc change maps the current DecorationSet, so its positions can be stale
            // even when the new signature matches the last dispatch. Force one dispatch.
            lastSignature = "";
        }
        const plan = planPages(view, storage.profile);
        storage.pageCount = plan.cuts.length + 1;
        // Stability guard: stop once the break set repeats or the streak is spent.
        if (plan.signature === lastSignature || streak >= MAX_STREAK) return;
        streak += 1;
        lastSignature = plan.signature;
        view.dispatch(
            view.state.tr
                .setMeta(pagePaginationKey, {
                    decorations: buildDecorations(view.state.doc, plan),
                } satisfies PaginationMeta)
                .setMeta("addToHistory", false),
        );
    };

    const schedule = (reset: boolean): void => {
        if (reset) resetPending = true;
        if (!frame && !destroyed) frame = requestAnimationFrame(measure);
    };

    // Our own widgets change the height of view.dom, so this fires after each
    // dispatch. Only a width change counts as a reset.
    const resizeObserver = new ResizeObserver((entries) => {
        const entry = entries[0];
        if (!entry) return;
        const width = entry.contentRect.width;
        const widthChanged = width !== lastWidth;
        lastWidth = width;
        schedule(widthChanged);
    });

    const onCompositionEnd = (): void => schedule(true);

    applyProfileVars(view.dom, storage.profile);
    resizeObserver.observe(view.dom);
    view.dom.addEventListener("compositionend", onCompositionEnd);
    void document.fonts.ready.then(() => schedule(true));
    schedule(true);

    return {
        update(editorView, prevState) {
            const state = pagePaginationKey.getState(editorView.state);
            if (state?.remeasure) applyProfileVars(editorView.dom, storage.profile);
            // Selection-only transactions must not remeasure.
            if (state?.remeasure || !editorView.state.doc.eq(prevState.doc)) {
                schedule(true);
            }
        },
        destroy() {
            destroyed = true;
            cancelAnimationFrame(frame);
            resizeObserver.disconnect();
            view.dom.removeEventListener("compositionend", onCompositionEnd);
        },
    };
}

export const PagePagination = Extension.create<PagePaginationOptions, PagePaginationStorage>({
    name: "pagePagination",

    addOptions() {
        return { profile: "plain" };
    },

    addStorage() {
        return { profile: PAGE_PROFILES[this.options.profile], pageCount: 1 };
    },

    addCommands() {
        return {
            setPageProfile:
                (id: PageProfileId) =>
                ({ tr, view, dispatch }) => {
                    this.storage.profile = PAGE_PROFILES[id];
                    applyProfileVars(view.dom, this.storage.profile);
                    if (dispatch) {
                        dispatch(tr.setMeta(pagePaginationKey, { remeasure: true }));
                    }
                    return true;
                },
        };
    },

    addProseMirrorPlugins() {
        const storage = this.storage;
        return [
            new Plugin<PaginationState>({
                key: pagePaginationKey,
                state: {
                    init: () => ({ decorations: DecorationSet.empty, remeasure: false }),
                    apply(tr, value) {
                        const meta = tr.getMeta(pagePaginationKey) as PaginationMeta | undefined;
                        const mapped = tr.docChanged
                            ? value.decorations.map(tr.mapping, tr.doc)
                            : value.decorations;
                        return {
                            decorations: meta?.decorations ?? mapped,
                            remeasure: meta?.remeasure === true,
                        };
                    },
                },
                props: {
                    decorations: (state) => pagePaginationKey.getState(state)?.decorations,
                },
                view: (editorView) => createPaginationView(editorView, storage),
            }),
        ];
    },
});
