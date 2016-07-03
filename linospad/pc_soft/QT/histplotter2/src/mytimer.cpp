#include "mytimer.h"
#include <QtCore>
#include <QDebug>

myTimer::myTimer()
{
	timer = new QTimer(this);
	connect(timer, SIGNAL(timeout()), this, SLOT(MySlot()));

	timer->start(1000);
}

void mytimer::MySlot()
{
    // cerr << "Timer loop 1 sec" << endl;
}