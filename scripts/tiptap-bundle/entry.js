import { Editor } from '@tiptap/core';
import StarterKit from '@tiptap/starter-kit';
import { Table, TableRow, TableCell, TableHeader } from '@tiptap/extension-table';
import TextAlign from '@tiptap/extension-text-align';
import Underline from '@tiptap/extension-underline';
import Link from '@tiptap/extension-link';
import Image from '@tiptap/extension-image';

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
};
