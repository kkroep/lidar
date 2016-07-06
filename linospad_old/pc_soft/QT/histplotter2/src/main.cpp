#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    MainWindow w;

    //QIcon icon(":icon/icon.ico");
    //w.setWindowIcon(icon);
    //w.showMaximized();
    w.show();

    return a.exec();
}
