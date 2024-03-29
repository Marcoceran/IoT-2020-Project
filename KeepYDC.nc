#include "printf.h"
#include "Timer.h"
typedef nx_struct my_msg {	//this is the type of the messages that we are sending
	nx_uint8_t topic;	//number of the mote that entered proximity area
} my_msg_t;

nx_uint8_t last;		//those two variables keep track of the last two motes
nx_uint8_t secondlast;		//that each mote got in touch with

module KeepYDC {
	uses {
		interface Boot;			// to boot the system
		interface Receive;		// to receive packets
		interface AMSend;		// to send packets
		interface SplitControl as AMControl;	//control interface
		interface Packet;		// to handle packets
		interface Timer<TMilli>;	// timer interface
	}
}
implementation {
	message_t packet; 			//packet
	event void Boot.booted() {
		last = 0;				//we initialize the two
		secondlast = 0;				//storage variables
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err){
		if(err == SUCCESS){
			dbg("Mote", "Mote started!\n");
			call Timer.startPeriodic(500);
		} else{
			dbgerror("Mote err", "Mote error, restart mote\n")
			call AMControl.start();
		}
	}
	
	event void AMControl.stopDone(error_t err) {
	}
	
	event void Timer.fired() {
		my_msg_t* prox_msg = (my_msg_t*)call Packet.getPayload(&packet, 1);
		prox_msg -> topic = TOS_NODE_ID;	// we write the id of the mote that entered proximity area in the packet
	 	if(call AMSend.send(AM_BROADCAST_ADDR, &packet, 1) == SUCCESS){
	 		dbg("radio_send", "Mote #%d: Sending message \n", TOS_NODE_ID);
		}
	}
	
	event void AMSend.sendDone(message_t* buf, error_t err){
	}
	
	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
		my_msg_t* recm = (my_msg_t*)payload;
		if (recm->topic != last) {
			secondlast = last;	//each time a message is received the storage variables are updated, but
			last = recm->topic;	//we skip this step if a mote gets consecutive messages from the same mote
		}
		if(len != 1){
			return buf;
		}
		printf("Mote #%u in proximity area\n", recm-> topic);	// prints the alarm string, that gets forwarded to nodered
		printfflush();						// flushes the print queue
		return buf;
	}
}
