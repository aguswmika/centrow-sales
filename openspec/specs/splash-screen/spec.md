## Purpose

Provides a cohesive branded launch screen experience across native platform startup and Flutter app initialization, gating user navigation based on session validity.

## Requirements

### Requirement: Display native launch screen
The system SHALL present a branded native launch screen immediately when the application process starts, before the Flutter framework initializes.

#### Scenario: App opened from cold start on Android or iOS
- **WHEN** a user opens the application from a cold start
- **THEN** the operating system displays a native splash screen featuring the brand background color and centered app logo until the Flutter engine paints the first frame

### Requirement: Display in-app splash screen
The system SHALL render an in-app splash view upon Flutter framework initialization, visually harmonized with the native launch screen to prevent jarring visual transitions.

#### Scenario: Flutter app mounts the initial route
- **WHEN** the application completes framework initialization and enters the router
- **THEN** the system mounts the splash view displaying the Centrow logo, a subtle loading indicator, and application branding

#### Scenario: Minimum display duration
- **WHEN** the app initialization and session checks finish in less than the minimum duration threshold (1.2 seconds)
- **THEN** the system holds the splash screen until the minimum duration elapsed to prevent visual flickering before navigating

### Requirement: Route unauthenticated users to login
The system SHALL redirect users with no stored authentication token directly to the login screen.

#### Scenario: No authentication token stored
- **WHEN** the startup check determines that no authentication token exists in local storage
- **THEN** the system redirects the user to the `/login` route upon completing the minimum splash duration

### Requirement: Validate stored session on launch
The system SHALL verify any existing stored authentication token against the remote authentication service before admitting the user to the application's main workspace.

#### Scenario: Stored token is valid
- **WHEN** a stored token exists and the remote profile endpoint (`/v1/auth/me`) confirms it is valid
- **THEN** the system updates the locally cached user profile and navigates to `/customers`

#### Scenario: Stored token is expired or invalid
- **WHEN** a stored token exists but the remote service responds with an unauthenticated (401) error
- **THEN** the system clears the stored authentication token and cached user data, and redirects the user to `/login`

#### Scenario: Network connection is unavailable during verification
- **WHEN** a stored token exists but the remote verification cannot complete due to a network connection failure
- **THEN** the system allows the user to proceed to `/customers` using the existing cached session state
