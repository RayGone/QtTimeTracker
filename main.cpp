#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSharedMemory>
#include <QCryptographicHash>
#include <QDate>
#include <QSettings>
#include <QDebug>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QDate date = QDate::currentDate();
    QString seed = date.toString(Qt::ISODate);

    QSharedMemory shared(QCryptographicHash::hash(seed.toUtf8(),QCryptographicHash::Sha3_512));
    if( !shared.create( 512, QSharedMemory::ReadWrite) )
    {
        qWarning() << "Can't start more than one instance of the application.";
        exit(0);
    }

    QSettings settings;
    //settings.clear();

    qInfo() << QCryptographicHash::hash(seed.toUtf8(),QCryptographicHash::Sha3_512);

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
