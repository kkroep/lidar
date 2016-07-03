#include "mytimer.h"
#include <QtCore>
#include <QDebug>

MyTimer::MyTimer()
{
	timer = new QTimer(this);
	connect(timer, SIGNAL(timeout()), this, SLOT(MySlot()));

	timer->start(1000);
}

void MyTimer::MySlot()
{
    // cerr << "Timer loop 1 sec" << endl;
}