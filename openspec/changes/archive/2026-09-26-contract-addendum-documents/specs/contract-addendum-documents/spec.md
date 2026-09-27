## Purpose

Enables sales representatives to create, preview, edit via rich text, and export PDF agreement documents for contract addendums on mobile devices.

## ADDED Requirements

### Requirement: List active addendum templates
The system SHALL provide a list of currently active addendum templates available for seeding new addendum documents.

#### Scenario: Retrieve active templates successfully
- **WHEN** user requests active templates when seeding a fresh addendum document
- **THEN** the system displays all active addendum templates with their titles and identifiers for selection

#### Scenario: No active templates available
- **WHEN** user requests active templates and none are marked active on the server
- **THEN** the system informs the user that no active addendum templates are available

### Requirement: Retrieve contract addendum document
The system SHALL retrieve the document for a given contract addendum, either as a persisted document or as a template-seeded preview if no document has been saved yet.

#### Scenario: Document already exists
- **WHEN** user opens the addendum document page for an addendum that has already been saved
- **THEN** the system loads the persisted document content without requiring a template ID and renders it in the editor

#### Scenario: Document does not exist and template is selected
- **WHEN** user opens the addendum document for an addendum that has not been saved yet and provides an active template ID
- **THEN** the system loads a template-seeded preview of the document with the template content and title

#### Scenario: Document does not exist and no template is selected
- **WHEN** user attempts to open an unsaved addendum document without specifying a template ID
- **THEN** the system prompts the user to select an active template from the template picker sheet before loading the document

### Requirement: Edit and save contract addendum document
The system SHALL allow authorized users to edit the addendum document's rich-text content using a Tiptap editor and persist the changes back to the server.

#### Scenario: First save with template ID
- **WHEN** user saves an unsaved addendum document preview with edited content and the chosen template ID
- **THEN** the system sends the Tiptap JSON content and template ID to the server, marks the document as persisted, and displays a success notification

#### Scenario: Subsequent save of existing document
- **WHEN** user edits and saves an already persisted addendum document
- **THEN** the system updates the document content on the server and preserves the original template association

### Requirement: Render and download contract addendum document PDF
The system SHALL allow users to render and download or share the contract addendum document as a formatted PDF file.

#### Scenario: Download PDF for saved document
- **WHEN** user triggers PDF download for a saved contract addendum document
- **THEN** the system fetches the generated PDF binary from the server and opens the file preview or system share dialog

#### Scenario: Download PDF for unsaved addendum with template
- **WHEN** user triggers PDF download for an unsaved addendum and provides the active template ID
- **THEN** the system generates and downloads the preview PDF based on the selected template content
