#ifndef UTILITIES_H
#define UTILITIES_H

#include <QtCore>

class Utilities : public QObject
{
    Q_OBJECT
public:
    explicit Utilities(QObject *parent = 0);

    Q_INVOKABLE QJsonObject xmlToJson(const QString &xml);
    Q_INVOKABLE QStringList htmlGetImg(const QString &html);

    // test only
    Q_INVOKABLE QJsonObject test();

signals:

public slots:

};

#endif // UTILITIES_H
