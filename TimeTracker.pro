QT += quick

SOURCES += \
        main.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    TimeTracker.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    templates/CloseWindow.qml \
    templates/DumpReport.qml \
    templates/Images.qml \
    templates/Main.qml \
    templates/MinimizeWindow.qml \
    templates/MoveWindow.qml \
    templates/Random.qml \
    templates/ReportView.qml \
    templates/TemplateBody.qml \
    templates/TrackerDisplay.qml \
    templates/WindowPeripheral.qml

