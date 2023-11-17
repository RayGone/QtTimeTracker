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
    QML/Controls/CloseWindow.qml \
    QML/Controls/Divider.qml \
    QML/Controls/DumpReport.qml \
    QML/Controls/HeadTitle.qml \
    QML/Controls/HistoryTable.qml \
    QML/Controls/Images.qml \
    QML/Controls/Ink.qml \
    QML/Controls/MinimizeWindow.qml \
    QML/Controls/MoveWindow.qml \
    QML/Controls/TextTemplate.qml \
    QML/Controls/TrackerDisplay.qml \
    QML/Images.qml \
    QML/MainWindow/MainWindow.qml \
    QML/MainWindow/StartJobPrompt.qml \
    QML/Random.qml \
    QML/ReportView.qml \
    QML/TemplateBody.qml \
    QML/TrackerFunctions.qml \
    QML/TrackerView.qml \
    QML/WindowPeripheral.qml \

