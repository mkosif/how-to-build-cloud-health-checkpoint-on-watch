# How To Build Cloud Health Checkpoint On Watch

This project is a wearable watch application built for **HarmonyOS NEXT** wearable devices, developed using **ArkTS**. It demonstrates the full **CloudFoundationKit** lifecycle from a power-constrained watch: daily health checkpoints (steps, heart rate, sleep score) are persisted in Cloud Database, weekly trend and anomaly analysis runs on the server through a Cloud Function, and report files are exchanged with the default Cloud Storage bucket.

The how-to-build-cloud-health-checkpoint-on-watch sample is intentionally scoped to CloudFoundationKit behavior and wearable UI.

# Use Cases

The following are the application's featured use cases:

1. The user can see the latest daily checkpoint, the current cloud connection state, and a one-tap entry point for each cloud module.
2. The user can adjust steps, heart rate, and sleep score on the Add Checkpoint screen and upsert the record into Cloud Database.
3. The user can list the last seven checkpoints from Cloud Database and optionally seed a deterministic mock week for the codelab.
4. The user can invoke the `analyzeWeeklyHealth` Cloud Function and view the returned trend, averages, anomalies, and summary.
5. The user can export the current checkpoints as a JSON file and upload it to Cloud Storage, then download the server-generated PDF summary report.

# Tech Stack

- **Languages**: ArkTS
- **Frameworks**: HarmonyOS SDK 6.0.0(20)
- **Tools**: DevEco Studio 6.x
- **Libraries**: @kit.CloudFoundationKit, @kit.ArkUI, @kit.AbilityKit, @kit.CoreFileKit, @kit.BasicServicesKit

# Directory Structure

The project structure is as follows:

   ```
entry/src/main/ets/
|---components
|---|---WatchCard
|---models
|---|---HealthCheckpoint
|---|---WeeklyAnalysisResult
|---services
|---|---CloudDatabaseService
|---|---CloudFunctionService
|---|---CloudStorageService
|---|---MockHealthDataService
|---utils
|---|---DateUtils
|---|---FileReportUtils
|---pages
|---|---Index
|---|---AddCheckpoint
|---|---History
|---|---Analysis
|---|---Reports
|---entryability
|---|---EntryAbility
|---entrybackupability
|---|---EntryBackupAbility
   ```

# Constraints and Restrictions

## Supported Devices

- Huawei Watch 5

## Device Capability Notes

`@kit.CloudFoundationKit` requires `SystemCapability.DeviceCloudGateway.CloudFoundation` and an AppGallery Connect project bound to the application bundle name. The `HealthCheckpointZone` zone, the `HealthCheckpoint` object type, the `analyzeWeeklyHealth` cloud function, and the default Cloud Storage bucket must be provisioned in AppGallery Connect for the end-to-end flow to succeed. `ohos.permission.INTERNET` is declared in `module.json5`. Sensor inputs are produced by a deterministic seed so the codelab is reproducible on the emulator.

# License

Cloud Health Checkpoint is distributed under the terms of the MIT License.
See the [LICENSE](./LICENSE) for more information.
