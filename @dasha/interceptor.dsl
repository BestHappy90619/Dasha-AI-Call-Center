
// DONT EDIT THIS CODE!
// AUTOGENERATED BY DASHA STUDIO

library

context {
  input _sandbox_interceptorEnabled: boolean = false;
}

external function _sandbox_interceptorFunction(message: string, ctx: unknown): { 
  messages: string[], 
  transition: string,
  error: boolean,
};

preprocessor digression _sandbox_interceptorNode {
  conditions {
    on $._sandbox_interceptorEnabled == true priority 100000000;
  }

  do {
    var text = #getMessageText();
    #log(text);
    var result = external _sandbox_interceptorFunction(text, $);

    for (var msg in result.messages) {
      #sayText(msg);
    }

    if (result.error) {
      return;
    }

    
if (result.transition == "dont_understand_hangup") {
  goto dont_understand_hangup;
}


if (result.transition == "repeat_or_ping_hangup") {
  goto repeat_or_ping_hangup;
}


if (result.transition == "root") {
  goto root;
}


if (result.transition == "ask_name") {
  goto ask_name;
}


if (result.transition == "ask_email") {
  goto ask_email;
}


if (result.transition == "confirm_receive") {
  goto confirm_receive;
}


if (result.transition == "ask_any_program") {
  goto ask_any_program;
}


if (result.transition == "make_connection") {
  goto make_connection;
}


if (result.transition == "yes") {
  goto yes;
}


if (result.transition == "no") {
  goto no;
}


if (result.transition == "schedule_date") {
  goto schedule_date;
}


if (result.transition == "check_available") {
  goto check_available;
}


if (result.transition == "okay_bye") {
  goto okay_bye;
}


    return;
  }

  transitions {
    dont_understand_hangup: goto dont_understand_hangup;
repeat_or_ping_hangup: goto repeat_or_ping_hangup;
root: goto root;
ask_name: goto ask_name;
ask_email: goto ask_email;
confirm_receive: goto confirm_receive;
ask_any_program: goto ask_any_program;
make_connection: goto make_connection;
yes: goto yes;
no: goto no;
schedule_date: goto schedule_date;
check_available: goto check_available;
okay_bye: goto okay_bye;
  }
}