#ifndef MYTIMER_H
#define MYTIMER_H

#include <QtCore>

class MyTimer : public QObject
{
	Q_OBJECT

public:
	MyTimer();
	QTimer *timer;
	int number;

public slots:
	void MySlot();
};

#endif // MYTIMER_H