#include <QGuiApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setApplicationName(QString("Time Tracker"));
    app.setOrganizationName(QString("GrayAtom"));
    app.setOrganizationDomain(QString("grayatom.com"));

    //For Implementing System Tray Icon
    app.setQuitOnLastWindowClosed(false);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/TimeTracker/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);


    return app.exec();
}
