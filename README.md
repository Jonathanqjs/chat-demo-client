# Chat Demo Client

## Overview

Chat Demo Client is a cross-platform instant messaging application built using the Flutter framework. It allows users to register, log in, add friends, and engage in real-time text and image communication. The application runs on Android and ios platforms, offering a seamless user experience.

## Features

1. **User Registration and Login**
   - Users can create new accounts and log in to the application.
   - Uses JWT (JSON Web Token) to authenticate user sessions.

2. **Friend Management**
   - Add and manage a list of friends within the app.

3. **Real-time Messaging**
   - Send and receive text and image messages in real time.
   - Supports offline message synchronization.

4. **Responsive UI**
   - Dynamic layouts adapt to different screen sizes for a better user experience.

5. **Local Data Storage**
   - Stores JWT tokens and user information locally to persist sessions.

## Application Structure

The application follows a modular structure for scalability and maintainability:

- **UI Layer**:
  - Includes user-friendly pages for login, registration, friend list, and chat interfaces.
- **Network Layer**:
  - Manages HTTP requests for registration and login.
  - Handles WebSocket connections for real-time messaging.
- **Data Layer**:
  - Stores user data and tokens locally using Flutter’s secure storage.

## Setup and Installation

1. **Prerequisites**
   - Install [Flutter SDK](https://flutter.dev/docs/get-started/install).
   - Configure your environment for Flutter development (Android/iOS/web).
   - Ensure the Chat Demo Server is running.

2. **Clone the Repository**
  
   ```bash
   git clone https://github.com/Jonathanqjs/chat-demo-client.git
   cd chat-demo-client
   ```

3. **Install Dependencies**

   ```bash
   flutter pub get
   ```

4. **Run the Application**

    For android

    ```bash
    flutter run -d android
    ```

    For ios

    ```bash
    flutter run -d ios
    ```
