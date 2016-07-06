#include "ccframework.h"

ControlCenter::ControlCenter() {
    for( unsigned row = 0; row < BUTTONS_V; ++row ) {
        for( unsigned col = 0; col < BUTTONS_H; ++col ) {
            buttonGrid.attach(buttons[row*BUTTONS_H+col], col, row, 1, 1);
        }
    }
    add(buttonGrid);
    show_all_children();
}

ControlCenter::~ControlCenter() {
}

bool ControlCenter::on_key_press_event(GdkEventKey* event) {
    if(event->keyval == GDK_KEY_Escape)
    {
        //close the window, when the 'esc' key is pressed
        hide();
        return true;
    }
    //if the event has not been handled, call the base class
    return Gtk::Window::on_key_press_event(event);
}

ControlCenter& ControlCenter::getInstance() {
    static ControlCenter cc;
    return cc;
}

void ControlCenter::connectButton( unsigned int row, unsigned int col, const std::string& label, const sigc::slot<void>& func ) {
    if( row >= BUTTONS_V || col >= BUTTONS_H ) return;
    buttons[row*BUTTONS_H+col].set_label( label );
    buttons[row*BUTTONS_H+col].signal_clicked().connect( func );
}

int main( int argc, char* argv[] ) {
    int gtkmm_argc = 1; //forward all args to application
    Glib::RefPtr<Gtk::Application> app = Gtk::Application::create(gtkmm_argc, argv, "org.gtkmm.example");
    if( appSetup( argc, argv ) )
        return app->run(ControlCenter::getInstance());
    else
        return 0;
}

