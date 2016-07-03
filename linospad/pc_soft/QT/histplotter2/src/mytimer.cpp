#include "mytimer.h"
#include <QTCore>
#include <QDebug>

mytimer::mytimer()
{
	timer = new QTimer(this);
	connect(timer, SIGNAL(timeout()), this, SLOT(MySlot()));

	timer->start(1000);
}

void mytimer::MySlot()
{
    // cerr << "Timer loop 1 sec" << endl;
}