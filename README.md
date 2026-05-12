> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# How to Build Cloud Health Checkpoint on Watch

Cloud Health Checkpoint is a HarmonyOS wearable sample that demonstrates the full **CloudFoundationKit** lifecycle from a watch. The app stores daily health checkpoints (steps, heart rate, sleep score) in Cloud Database, invokes a Cloud Function with a JSON payload to compute weekly trend and anomaly analysis on the server side, and uploads/downloads report files with Cloud Storage.

In this guide, you will learn how to initialize a `DatabaseZone`, upsert and query a `DatabaseObject`, invoke a serverless function with `cloudFunction.call()`, and transfer files between the watch and the default Cloud Storage bucket — all without burdening the watch CPU.

# Preview

<div>
  <img src="screenshots/1.png" width="24%" >
  <img src="screenshots/2.png" width="24%" >
  <img src="screenshots/3.png" width="24%" >
  <img src="screenshots/4.png" width="24%" >
</div>

# Use Cases

1. Persist daily wellness check-ins from a watch into a cloud database with zone-scoped operations.
2. Offload weekly aggregation and anomaly detection to a serverless cloud function instead of computing on-device.
3. Upload small JSON exports from the watch and download server-generated PDF summary reports.
4. Demonstrate a watch participating in a cloud-native architecture without draining its battery.
5. Show graceful UI states for cloud-backed actions (idle, busy, ok, err) on a circular wearable viewport.

# Technology

## Stack

- **Languages**: ArkTS, ArkUI
- **Frameworks**: HarmonyOS 6.0.0(20)
- **Tools**: DevEco Studio 6.x, Hvigor
- **Libraries**:
  - `@kit.CloudFoundationKit`
  - `@kit.ArkUI`
  - `@kit.AbilityKit`
  - `@kit.CoreFileKit`
  - `@kit.BasicServicesKit`

## Required Permissions

- `ohos.permission.INTERNET`
  > Required by Cloud Database, Cloud Function, and Cloud Storage to reach AppGallery Connect.

# Directory Structure

```
├───components
│       WatchCard.ets
│
├───entryability
│       EntryAbility.ets
│
├───entrybackupability
│       EntryBackupAbility.ets
│
├───models
│       HealthCheckpoint.ets
│       WeeklyAnalysisResult.ets
│
├───pages
│       Index.ets
│       AddCheckpoint.ets
│       History.ets
│       Analysis.ets
│       Reports.ets
│
├───services
│       CloudDatabaseService.ets
│       CloudFunctionService.ets
│       CloudStorageService.ets
│       MockHealthDataService.ets
│
└───utils
        DateUtils.ets
        FileReportUtils.ets
```

# Constraints and Restrictions

## Supported Device

- Huawei Watch 5

## Limitations

- Cloud Database, Cloud Function, and Cloud Storage flows cannot be exercised on the Previewer; a HarmonyOS 6.x wearable emulator or a real device with an AppGallery Connect project is required.
- The `HealthCheckpointZone` zone, the `HealthCheckpoint` object type, the `analyzeWeeklyHealth` cloud function, and the default Cloud Storage bucket must be provisioned in AppGallery Connect before the app can succeed end-to-end.
- `agconnect-services.json` must be placed under `entry/src/main/resources/rawfile/` (it is git-ignored) and a debug auth token or anonymous sign-in must be enabled in AGC.
- Sensor inputs (`steps`, `heartRate`, `sleepScore`) are mocked by a deterministic seed so the codelab is reproducible on the emulator; integration with real HMS Health sensors is intentionally out of scope.
- PDF report generation runs server-side. The watch only downloads the artefact; an empty placeholder file at `reports/<userId>/weekly-summary.pdf` is recommended for the first run.
- Network access is required for every cloud action.

# License

**How to Build Cloud Health Checkpoint on Watch** is distributed under the terms of the MIT License.

See the [LICENSE](LICENSE) for more information.
