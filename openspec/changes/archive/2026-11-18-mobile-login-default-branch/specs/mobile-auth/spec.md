## Purpose

Defines how a sales user signs in to the sales app and how the session's active company and branch, chosen by the server, are carried and shown in the app.

## ADDED Requirements

### Requirement: Login with email and password only
The system SHALL authenticate users by sending only `email` and `password` to `POST /api/v1/auth/login` with the `X-App-Client: sales` header, and SHALL NOT send `branch_id` or request any branch list before login. The login screen SHALL NOT show a branch selection control, and the login form SHALL be submittable once the email is well formed and a password is entered. When login fails with 400, 401 or 403, the system SHALL show the server's `message` when the response has one, and otherwise its current fallback text for that status.

#### Scenario: Successful login
- **WHEN** a sales user submits a valid email and password
- **THEN** the system receives HTTP 200, stores the tokens and the user, including the returned `branch {id, name}` and `company {id, name}`, and opens the main screen

#### Scenario: No branch picker
- **WHEN** the user opens the login screen
- **THEN** only the email and password fields are shown, and no request to `GET /api/v1/branches` is made

#### Scenario: Server message on 403
- **WHEN** the login is rejected with HTTP 403 and message "Akun tidak memiliki akses cabang aktif"
- **THEN** the screen shows "Akun tidak memiliki akses cabang aktif"

#### Scenario: 403 without a message
- **WHEN** the login is rejected with HTTP 403 and no message
- **THEN** the screen shows "Akun ini tidak memiliki akses ke aplikasi ini."

### Requirement: Active company and branch in the session
The system SHALL keep the active branch id and name and the active company id and name from the login response (`branch`, `company`) and from `GET /api/v1/auth/me` in the session user. It SHALL persist them with the stored user so they survive an app restart, and SHALL show the company and branch names in the navigation rail's user menu, below the user's email. A name that is empty SHALL be shown as "-".

#### Scenario: User menu shows company and branch
- **WHEN** Budi, whose session is in Kupang of PT Nohama, opens the user menu in the navigation rail
- **THEN** the menu shows "PT Nohama" and "Kupang" below his email

#### Scenario: After restart
- **WHEN** the app is restarted with a stored session
- **THEN** the user menu shows the same company and branch without logging in again

#### Scenario: Refreshed by /me
- **WHEN** `GET /api/v1/auth/me` returns `company.name` = "PT Nohama" for the stored session
- **THEN** the stored user and the user menu show "PT Nohama"
