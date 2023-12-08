import "commonReactions/all.dsl";

context 
{
    // declare input variables here. phone must always be declared. name is optional 
    input endpoint: string;
    input name: string = "Michael"; 
    input email: string = ""; 
    input company: string = "BLAIR INC.";
    input date: string = "";

    // declare storage variables here 
    var1: string = "";
}

// declare external functions here 
external function function1(log: string): string;

// lines 28-42 start node 
start node root 
{
    do //actions executed in this node 
    {
        #connectSafe($endpoint); // connecting to the phone number which is specified in index.js that it can also be in-terminal text chat
        #waitForSpeech(1000); // give the person a second to start speaking 
        #sayText("Hello! Thank you for calling me. My name is Blair.");// and greet them
        goto ask_name; // switch state to another node without awaiting any event

    }
    transitions // specifies to which node the conversation goes from here AND on which condition 
    {
        ask_name: goto ask_name;
    }
}

node ask_name {
    do {
        #sayText("Can you please introduce yourself? May I have your name?");
        wait*; // instruct Dasha to wait for a user response
    }
    transitions // specifies to which node the conversation goes from here AND on which condition 
    {
        ask_email: goto ask_email on #messageHasData("name"); 
        // when Dasha identifies that the user's phrase contains "name" data, as specified in the named entities section of data.json, 
        // a transfer to node how_can_help happens 
    }
    // this section allows you to perform some additional work when exiting the current node
    // more details here: https://docs.dasha.ai/en-us/default/dasha-script-language/control-flow#onexit
    onexit 
    {
        default: do {
            //assign the variable $name with the value extracted from the user's previous statement 
            set $name = #messageGetData("name")[0]?.value??""; 
            #log($name);
        }
    }
}

// digression policy_check
// {
//     // below - the condition which activates the digression is 
//     // the intent "policy_check" being identified by Dasha 
//     // you can specify intents in data.json file 
//     // more about intents: https://dasha.ai/en-us/blog/intent-classification 
//     conditions { on #messageHasIntent("policy_check") priority 10; }
//     do 
//     {
//         if (#messageHasData("policy")) {
//             // if user utterance contains policy number, go to confirmation immediately
//             goto confirm_policy_number;
//         }
//         // otherwise, ask for policy number
//         goto ask_policy_number;
//     }
//     transitions
//     {
//         confirm_policy_number: goto confirm_policy_number;
//         ask_policy_number: goto ask_policy_number;
//     }
// }

node ask_email {
    do {
        #sayText("Yeah," + $name + ", it's Blair calling from " + $company + ". You were looking for business funding a while back and we never got together on the deal.");
        #sayText(" I want to send over our new guidelines so you can see what we’re doing over here. What's your best email?");
        wait*; // instruct Dasha to wait for a user response
    }
    transitions // specifies to which node the conversation goes from here AND on which condition 
    {
        confirm_receive: goto confirm_receive on #messageHasData("email"); 
        // when Dasha identifies that the user's phrase contains "name" data, as specified in the named entities section of data.json, 
        // a transfer to node how_can_help happens 
    }
    // this section allows you to perform some additional work when exiting the current node
    // more details here: https://docs.dasha.ai/en-us/default/dasha-script-language/control-flow#onexit
    onexit 
    {
        default: do {
            //assign the variable $name with the value extracted from the user's previous statement 
            set $email = #messageGetData("email")[0]?.value??""; 
            #log($email);
        }
    }
}

node confirm_receive {
  do {
    #sayText("Got it. I'll send that over now, let me know when you get it.");
    wait*;
  }
  transitions {
    ask_any_program: goto ask_any_program on #messageHasIntent("confirm_receive");
  }
}


node ask_any_program {
  do {
    #say("which_program");
    wait*;
  }
  transitions {
    make_connection: goto make_connection on #messageHasIntent("have_program_yes");
  }
}

node make_connection {
  do {
    #sayText("Excellent. I can connect you with a fund manager to discuss how much you may qualify for, as well as the up-to-date rates and terms. Do you have a few minutes to chat with them right now?");
    wait*;
  }
  transitions {
    yes: goto yes on #messageHasIntent("make_connection_yes");
    no: goto no on #messageHasIntent("make_connection_no");
  }
}


// lines 73-333 are our perfect world flow
node yes
{
    do 
    {
        // var result = external function1("test");    //call your external function
        #sayText("Okay, I’ll connect you right now. Stay on the line please.");
        wait*;
        exit;
    }
    transitions {
      // make_connection: goto make_connection on #messageHasIntent("yes");
    }
}

node no
{
    do 
    {
        #sayText("Okay, I'll send over a calendar link so you can pick the time that works best for you. Let me know when you got it.");
        wait*;
        // exit;
    }
    transitions {
      schedule_date: goto schedule_date on #messageHasIntent("schedulelink_receive");
    }
}

node schedule_date {
    do {
        #sayText("Let me know what date and time you select and I'll double check on my end.");

        wait*; // instruct Dasha to wait for a user response
    }
    transitions // specifies to which node the conversation goes from here AND on which condition 
    {
        check_available: goto check_available on #messageHasData("schedule_date"); 
        // when Dasha identifies that the user's phrase contains "name" data, as specified in the named entities section of data.json, 
        // a transfer to node how_can_help happens 
    }
    onexit 
    {
        default: do {
            //assign the variable $name with the value extracted from the user's previous statement 
            set $date = #messageGetData("schedule_date")[0]?.value??""; 
            #log($date);
        }
    }
}

node check_available {
  do {
    #sayText("One sec.");
    #waitForSpeech(4000);
    #sayText("Yep, that works for us. I’ve got you scheduled for " + $date + ". I'll call you the day of, just as a reminder.");
    wait*;
  }
  transitions {
    okay_bye: goto okay_bye on #messageHasIntent("okay");
  }
}

node okay_bye {
  do {
    #sayText("Alright, that's it for today! Thanks, " + $name + ". ");
    #sayText("Talk soon. Bye.");
    exit;
  }
}
digression how_are_you
{
    conditions {on #messageHasIntent("how_are_you");}
    do 
    {
        #sayText("I'm well, thank you!", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}

digression how_much_can_get
{
    conditions {on #messageHasIntent("how_much_can_get");}
    do 
    {
        #sayText("That’s a good question. The funding manager will be able to go through the details and let you know a specific amount you’ll likely qualify for. Do you have a few minutes? I can transfer you over now. ", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression what_is_rate
{
    conditions {on #messageHasIntent("what_is_rate");}
    do 
    {
        #sayText("The rate, as always, is determined by a few different factors like time in business, industry, credit score, and more. A funding manager can get you more specific information that’s tailored to your business. Can you speak with them now?", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression what_is_term
{
    conditions {on #messageHasIntent("what_is_term");}
    do 
    {
        #sayText("We offer a few different programs that range from short term, like bridge funding for a few months, to long term - like sba funding for five or more years.", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression how_much
{
    conditions {on #messageHasIntent("how_much");}
    do 
    {
        #sayText("That’s really up to you and your business. We offer funding programs as low as $5,000 and some that are up into the millions. Would you like to discuss a real amount that you may qualify for? I can connect you to a funding manager real quick.", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression who_are_you
{
    conditions {on #messageHasIntent("who_are_you");}
    do 
    {
        #sayText("I’m Blair, from " + $company + " - where small business owners turn for funding.", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression how_got_information
{
    conditions {on #messageHasIntent("how_got_information");}
    do 
    {
        #sayText("At some point you requested information online. It could have been a while back but our programs are always updating, especially lately - with all the change that’s been going on in the market. ", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression not_interest
{
    conditions {on #messageHasIntent("not_interest");}
    do 
    {
        #sayText("No problem. That’s fine. I’ll just shoot over an email with our newest program guidelines so you’ll have all the information you need when the time is right. ", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression stop_calling
{
    conditions {on #messageHasIntent("stop_calling");}
    do 
    {
        #sayText("Yeah, I hear ya. I will add you to our company dnc list. If anything changes on your end, you’ll let us know, right? Because I won’t be able to call you again, even when we’re running special rates and promo deals. ", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
digression are_you_bot
{
    conditions {on #messageHasIntent("are_you_bot");}
    do 
    {
        #sayText("Well, technically, yes I am. I prefer the name Blair though. It stands for Business Loan Artificial Intelligence Representative.", repeatMode: "ignore"); 
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node 
        return; // go back to the node from which we got distracted into the digression 
    }
}
