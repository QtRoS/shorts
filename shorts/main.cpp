#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuick>

#include "CachingNetworkManagerFactory.h"
#include "xml2json/utilities.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("com.ubuntu.shorts");

    //qSetMessagePattern("%{file}- %{line}: %{function} M: %{message}");

    QQuickView view;

    CachingNetworkManagerFactory *managerFactory = new CachingNetworkManagerFactory();
    view.engine()->setNetworkAccessManagerFactory(managerFactory);

    Utilities *utilities = new Utilities();
    view.engine()->rootContext()->setContextProperty("utilities", utilities);

    view.setSource(QUrl(QStringLiteral("qrc:///qml/shorts-app.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}

