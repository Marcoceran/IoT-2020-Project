#define NEW_PRINTF_SEMANTICS
#include "printf.h"
enum{
	AM_MY_MSG = 6,
};

configuration KeepYDAppC {
}

implementation {
	components MainC, KeepYDC as App;
	components new TimerMilliC();
	components PrintfC;
	components SerialStartC;
	components new AMSenderC(AM_MY_MSG);
	components new AMReceiverC(AM_MY_MSG);
	components ActiveMessageC;
	//Boot interface
	App.Boot -> MainC.Boot;
	//Timer
	App.Timer -> TimerMilliC;
	//Send and Receive interfaces
	App.Receive -> AMReceiverC;
	App.AMSend -> AMSenderC;
	//Radio Control
	App.AMControl -> ActiveMessageC;
	//Interfaces to access package fields
	App.Packet -> AMSenderC;
}

