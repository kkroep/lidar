MAINFILES=bootstrap.C
SOURCES=fx3stream.C fx3utils.C ccframework.C

CPP=g++
CFLAGS=-std=c++11 -g -Wall `pkg-config gtkmm-3.0 --cflags`
LDLIBS=`pkg-config gtkmm-3.0 --libs` `pkg-config gthread-2.0 --libs` -lusb-1.0
DEFINES=

MAINOBJECTS=$(patsubst %.C,%.o, $(MAINFILES))
OBJECTS=$(patsubst %.C,%.o, $(SOURCES))
DEPFILES=$(patsubst %.C,%.dep, $(SOURCES))
DEPFILES+=$(patsubst %.C,%.dep, $(MAINFILES))
EXECUTABLES=$(patsubst %.C,%, $(MAINFILES))

all: $(EXECUTABLES)

%: %.o $(OBJECTS)
	$(CPP) -o $@ $< $(OBJECTS) $(LDLIBS)

clean:
	rm -f $(MAINOBJECTS)
	rm -f $(OBJECTS)
	rm -f $(DEPFILES)

%.o: %.C
	$(CPP) $(CFLAGS) $(DEFINES) -c -o $@ $<

include ${DEPFILES}

%.dep: %.C
	@set -e; rm -f $@; \
	$(CPP) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$ \

