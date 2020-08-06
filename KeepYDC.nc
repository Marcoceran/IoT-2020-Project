#include "printf.h"
#include "Timer.h"
typedef nx_struct my_msg {
	nx_uint8_t topic;	//number of the mote that entered proximity area
} my_msg_t;


module KeepYDC {
	uses {
		interface Boot;
		interface Receive;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Packet;
		interface Timer<TMilli>;
	}
}

implementation {
	message_t packet; //packet
	event void Boot.booted() {
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
		prox_msg -> topic = TOS_NODE_ID;
	 	
	 	if(call AMSend.send(AM_BROADCAST_ADDR, &packet, 1) == SUCCESS){
	 		dbg("radio_send", "Mote #%d: Sending message \n", TOS_NODE_ID);
		}
	}
	
	event void AMSend.sendDone(message_t* buf, error_t err){
	}
	
	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
		my_msg_t* recm = (my_msg_t*)payload;
		if(len != 1){
			return buf;
		}
		printf("Mote #%u in proximity area\n", recm-> topic);
		printfflush();
		return buf;
	}
}
