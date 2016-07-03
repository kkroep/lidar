#ifndef MYTIMER_H
#define MYTIMER_H

#include <QtCore>

class MyTimer : public QObject
{
	Q_OBJECT

public:
	MyTimers();
//	QTimer *timer;

public slots:
	void MySlot();
};

#endif // MYTIMER_H