Flutter Health Connect Realtime Dashboard

This project is a hiring task to build a high-performance, real-time dashboard for displaying Steps and Heart Rate data from Health Connect on Android, with zero network I/O.

App Starting Step -> Lib / main.dart

1. Setup and Installation
   A. Device Requirements (Constraints)
   Device: Android 33+ (Android 14/SDK 34 recommended).
   Prerequisites: The Android device must have Health Connect installed and active.

   B. Health Connect Setup (Crucial Step)
   Grant Permissions: Upon first launch, the app will navigate to the Permissions Screen. Tap "Grant Access" to open the Health Connect system dialog.
   Verify Data Source: Ensure a fitness app (e.g., Samsung Health or Google Fit) is connected to Health Connect and has granted permission to write Steps and Heart Rate data.
   Simulation Source (SimSource): For testing and development, you can toggle the play/stop icon in the AppBar to activate the internal SimSource, which generates fake data for deterministic testing.


2. Architecture and Technical Decisions

    A. State Management
   Choice: [State Management Library you used, Provider].
   Reasoning: A single DashboardController (ChangeNotifier) manages all application state (steps, heart rate, chart data). This separates all business logic (data processing, aggregation) from the UI, ensuring a clean and testable architecture.

    B. Realtime Data Flow
   Method Used: Polling (via Platform Channels)
   Implementation:
   A Flutter EventChannel is used to create a bridge to the native Android side.
   The native MainActivity.kt implements a continuous coroutine loop (startPollingHealthData).
   This loop runs every 10 seconds (delay(10000)), checking Health Connect for new data.
   It uses the startTime of the last successful read to only fetch new data records, preventing duplication and ensuring minimal latency (Target: ≤ 10s).
   The correct, official HealthConnectClient.getSdkPermissionController() is used for the permission flow.

    C. Dashboard UI and Charts (Constraints)
   Custom Chart Solution: The charts were built from scratch using CustomPainter. Third-party charting libraries were strictly avoided to meet the project constraints.
   Interactivity: Charts support pan (drag), pinch-to-zoom (scale), and a dedicated tooltip that shows the exact timestamp/value upon tapping.
   Anti-Plagiarism / Authenticity: The project includes a projectSalt constant in "lib/app_constant.dart", derived from SHA256("${packageName}:${firstGitCommitHash}"), as required for authenticity verification. 


4. Quality Assurance and Testing
   To ensure the reliability, visual integrity, and performance of the application, a full test suite was implemented, covering unit, golden, and integration testing requirements.
   Unit Test, Golden Test, Integration Test.
    Result:- All tests pass successfully,


   
