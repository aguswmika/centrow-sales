import { Editor } from '@tiptap/core';
import StarterKit from '@tiptap/starter-kit';
import { Table, TableRow, TableCell, TableHeader } from '@tiptap/extension-table';
import TextAlign from '@tiptap/extension-text-align';
import Underline from '@tiptap/extension-underline';
import Link from '@tiptap/extension-link';
import Image from '@tiptap/extension-image';
// richtext-page/ is copied verbatim from centrow web/app/components/ui/richtext-page — do not edit here.
import { PagePagination } from './richtext-page/pagination';
import { resolvePageProfile, contentWidthPx } from './richtext-page/profiles';
import pageCss from './richtext-page/page.css';

const style = document.createElement('style');
style.textContent = pageCss;
document.head.appendChild(style);

window.Tiptap = {
  Editor,
  StarterKit,
  Table,
  TableRow,
  TableCell,
  TableHeader,
  TextAlign,
  Underline,
  Link,
  Image,
  PagePagination,
  resolvePageProfile,
  contentWidthPx,
};
