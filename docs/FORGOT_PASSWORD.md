# Forgot Password Feature Documentation

## Overview
The **Forgot Password** feature allows users to request a password reset email if they have forgotten their login credentials for their email-based account. This feature is integrated directly into the `LoginScreen` via a modal dialog.

## User Flow
1.  **Initiation**:
    *   On the **Login Screen**, the user taps the **"Forgot Password?"** text button located above the Login button.
2.  **Input**:
    *   A custom-styled modal dialog appears with a hint: *"If you signed up using Google, please continue with Google."*
    *   The dialog prompts the user to enter their registered **Email Address**.
    *   The email field is pre-filled if the user had already typed it in the main login form.
3.  **Action**:
    *   The user clicks the **"Send Reset Link"** button.
    *   The button enters a loading state to prevent double-submissions.
4.  **Feedback**:
    *   **Success (Privacy Protected)**: The dialog closes, and a **green SnackBar** appears at the bottom of the screen confirming: *"If an account exists for this email, a reset link has been sent."*
        *   **Note**: This message is shown even if the user is not found, to prevent email enumeration attacks.
    *   **Failure (Network/System)**: If a network error or unrelated exception occurs, the dialog **stays open**, and a **red SnackBar** displays the error message so the user can retry.
5.  **Resolution**:
    *   If the account exists and uses Email/Password, Firebase sends an automated email with a reset link.

## Technical Implementation

### 1. UI Layer (`LoginScreen.dart`)
The UI is implemented using a `StatefulBuilder` within `showDialog` to manage local loading state.

*   **Widget**: Custom `Dialog` with rounded corners (`BorderRadius.circular(24)`).
*   **Components**:
    *   `_AeroTextField`: Reused from the main form for consistent styling.
    *   `Icons.lock_reset_outlined`: Visual indicator.
    *   `ElevatedButton`: Triggers the async send action with a loading indicator.
*   **Logic**:
    *   **Throttling**: Disables the button while a request is in flight.
    *   **Privacy Handling**: Catches `user-not-found` exceptions and treats them as success to protecting user privacy.
    *   **Error Handling**: Only closes the dialog on "success" cases. Network errors keep the dialog open.

### 2. State Management (`AuthProvider.dart`)
The `AuthProvider` acts as the intermediary between the UI and the Data Layer.

```dart
Future<void> sendPasswordResetEmail(String email) async {
  try {
    await _authRepository.sendPasswordResetEmail(email);
  } catch (e) {
    rethrow; // Passes error back to UI for display
  }
}
```

### 3. Data Layer (`AuthRepositoryImpl.dart`)
The repository interacts directly with the Firebase Auth SDK.

**Architectural Note**: The repository intentionally propagates all exceptions (including `user-not-found`) to the caller. It remains "pure" and responsible only for data operations. The decision to mask specific errors for privacy is handled at the **UI Layer**.

```dart
@override
Future<void> sendPasswordResetEmail(String email) async {
  await _firebaseAuth.sendPasswordResetEmail(email: email);
}
```

## Security & Constraints
*   **Email Enumeration Protection**: The UI never reveals if an email is registered or not. It always shows a generic success message.
*   **Google Auth Users**: Users who signed up via Google cannot reset their password this way. A hint text is provided in the dialog to guide them.
*   **Rate Limiting**: Firebase enforces backend rate limits. The UI additionally throttles requests by disabling the button during loading.
*   **Email Validation**: The input requires a valid email format.

## Future Improvements
*   Add a "Resend" timer to prevent accidental spam clicking in the UI (beyond simple button disabling).
