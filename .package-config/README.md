## Qt Installer Framework - Config and Packages for creating the app installer.

### App Deployment
- Copy the .exe file from {build-release} folder to {.package-config\packages\com.grayatom.timetracker\data}
```console
C:\> windeployqt --qmldir {path-to-qml: project-directory} "{path-to: .package-config}\packages\com.grayatom.timetracker\data\TimeTracker.exe"
```

### Installer File Creation
```console
{path-to-installer-framework}\bin\> binarycreator -p {path-to: .package-config}\packages -c "{path-to: .package-config}\config\config.xml" "{path-where-you-want-your-installer-to-be-saved}\TimeTracker.exe"
```
