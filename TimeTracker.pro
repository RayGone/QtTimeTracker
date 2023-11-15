QT += quick

SOURCES += \
        main.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    TimeTracker.qrc

win32:RC_ICONS += app-icon.ico

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    SQL/Database.qml \
    Templates/HeadTitle.qml \
    Templates/Ink.qml \
    Templates/MainWindow/MainWindow.qml \
    Templates/MainWindow/StartJobPrompt.qml \
    Templates/TextTemplate.qml \
    config.xml \
    Templates/CloseWindow.qml \
    Templates/DumpReport.qml \
    Templates/Images.qml \
    Templates/Main.qml \
    Templates/MinimizeWindow.qml \
    Templates/MoveWindow.qml \
    Templates/Random.qml \
    Templates/ReportView.qml \
    Templates/SQL/Database.qml \
    Templates/TemplateBody.qml \
    Templates/TrackerDisplay.qml \
    Templates/TrackerFunctions.qml \
    Templates/WindowPeripheral.qml

