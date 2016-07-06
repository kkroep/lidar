#ifndef CCFRAMEWORK_H
#define CCFRAMEWORK_H

#include <string>
#include <gtkmm.h>

#define BUTTONS_H 4
#define BUTTONS_V 4

void fun0();
void fun1();
void fun2();
void fun3();
void fun4();
void fun5();
void fun6();
void fun7();
void fun8();
void fun9();
void fun10();
void fun11();
void fun12();
void fun13();
void fun14();
void fun15();

class ControlCenter : public Gtk::Window {
    Gtk::Grid buttonGrid;
    Gtk::Button buttons[BUTTONS_H*BUTTONS_V];

    ControlCenter();
    ControlCenter( const ControlCenter& );
    ControlCenter& operator=( const ControlCenter& );
    virtual bool on_key_press_event(GdkEventKey* event);
public:
    virtual ~ControlCenter();
    static ControlCenter& getInstance();
    void connectButton( unsigned int row, unsigned int col, const std::string& title, const sigc::slot<void>& func );
};

extern bool appSetup( int argc, char* argv[] );

class StringInputDialog : public Gtk::Dialog {
    Gtk::Entry input;
public:
    StringInputDialog( const std::string& title, Gtk::Window& parent, const std::string& preset = std::string(), const std::string& prompt = std::string() ) : Gtk::Dialog( title, parent, true ) {
        add_button(Gtk::Stock::OK, Gtk::RESPONSE_OK);
        add_button(Gtk::Stock::CANCEL, Gtk::RESPONSE_CANCEL);
        set_default_response(Gtk::RESPONSE_OK);
        input.set_activates_default();
        if( prompt.length() ) {
            get_content_area()->add(*Gtk::manage(new Gtk::Label(prompt)));
        }
        get_content_area()->add(input);
        if( preset.length() ) {
            input.set_text( preset );
        }
        show_all_children();
    }
    
    std::string get_text() {
        return input.get_text();
    }
};

#endif //CCFRAMEWORK_H

